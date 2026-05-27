import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/domain/entity/flight_article.dart';
import 'package:flymap/domain/entity/gps_data.dart';
import 'package:flymap/domain/entity/route_region.dart';
import 'package:flymap/domain/policy/route_region_premium_gate_policy.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/subscription/paywall_source.dart';
import 'package:flymap/ui/screens/flight/viewmodel/flight_screen_cubit.dart';
import 'package:flymap/ui/screens/flight/viewmodel/flight_screen_state.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/geo_card/widgets/airport_inline_chip.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/geo_card/widgets/geo_awareness_blocking_overlay.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/geo_card/widgets/geo_awareness_region_details_sheet.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/geo_card/widgets/inline_label_chip.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/geo_card/widgets/region_inline_chip.dart';
import 'package:flymap/ui/map/map_utils.dart';
import 'package:flymap/ui/screens/shared/premium/route_premium_gate_interactions.dart';
import 'package:flymap/ui/screens/subscription/viewmodel/subscription_cubit.dart';
import 'package:flymap/utils/wikipedia_article_utils.dart';
import 'package:latlong2/latlong.dart';

class GeoAwarenessCard extends StatefulWidget {
  const GeoAwarenessCard({required this.onSelectedRegionChanged, super.key});

  final ValueChanged<RouteRegion?> onSelectedRegionChanged;

  @override
  State<GeoAwarenessCard> createState() => _GeoAwarenessCardState();
}

class _GeoAwarenessCardState extends State<GeoAwarenessCard> {
  static const _wrapAnimationDuration = Duration(milliseconds: 220);
  static const _chipSwapAnimationDuration = Duration(milliseconds: 180);
  static const _arrivingRadiusKm = 40.0;
  static const _arrivingProgressThreshold = 0.93;
  static const _arrivedRadiusKm = 10.0;
  static const _arrivedProgressThreshold = 0.97;
  static const _arrivedMaxSpeedKmh = 180.0;

  RouteRegion? _findRegion(List<RouteRegion> allRegions, String qid) {
    for (final region in allRegions) {
      if (region.qid == qid) return region;
    }
    return null;
  }

  List<RouteRegion> _regionsFromIds(
    List<String> ids,
    List<RouteRegion> allRegions,
  ) {
    final out = <RouteRegion>[];
    for (final id in ids) {
      final region = _findRegion(allRegions, id);
      if (region != null) out.add(region);
    }
    return out;
  }

  Future<void> _openRegionDetailsSheet(
    RouteRegion region, {
    FlightArticle? offlineArticle,
  }) async {
    widget.onSelectedRegionChanged(region);

    await showGeoAwarenessRegionDetailsSheet(
      context,
      region: region,
      offlineArticle: offlineArticle,
    );

    if (!mounted) return;
    widget.onSelectedRegionChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FlightScreenCubit, FlightScreenState>(
      buildWhen: (previous, current) {
        if (previous is FlightScreenLoaded && current is FlightScreenLoaded) {
          return previous.currentRegionIds != current.currentRegionIds ||
              previous.nextRegionId != current.nextRegionId ||
              previous.nextRegionEtaMinutes != current.nextRegionEtaMinutes ||
              previous.routeCoveredDistanceKm !=
                  current.routeCoveredDistanceKm ||
              previous.gps.status != current.gps.status ||
              previous.gps.lastFixAt != current.gps.lastFixAt ||
              previous.routeRegions != current.routeRegions;
        }
        return previous.runtimeType != current.runtimeType;
      },
      builder: (context, state) {
        if (state is! FlightScreenLoaded) {
          return const SizedBox.shrink();
        }
        if (state.gps.status == GpsStatus.off ||
            state.gps.status == GpsStatus.permissionsNotGranted) {
          return const SizedBox.shrink();
        }
        final isCurrentUserPro = context.select(
          (SubscriptionCubit cubit) => cubit.state.isPro,
        );
        final isProUser = isCurrentUserPro || state.flight.hasProAccess;
        final allRegions = state.routeRegions;
        if (allRegions.isEmpty) {
          return const SizedBox.shrink();
        }
        final orderedByDistance = RouteRegionPremiumGatePolicy.orderByDistance(
          allRegions,
        );
        final gateDecision = RouteRegionPremiumGatePolicy.evaluate(
          orderedRegions: orderedByDistance,
          isProUser: isProUser,
        );
        final premiumRegionIds = gateDecision.premiumRegionIds;
        final currentRegions = _regionsFromIds(
          state.currentRegionIds,
          allRegions,
        );
        final nextPrimary = state.nextRegionId == null
            ? null
            : _findRegion(allRegions, state.nextRegionId!);
        final arrivalLabelState = nextPrimary == null
            ? _arrivalLabelState(state)
            : null;
        final hideCurrentRegions =
            arrivalLabelState == _ArrivalLabelState.arriving ||
            arrivalLabelState == _ArrivalLabelState.arrived;
        final visibleCurrentRegions = hideCurrentRegions
            ? const <RouteRegion>[]
            : currentRegions;
        final showArrivalAsNext = arrivalLabelState != null;
        final hasRegionContent =
            visibleCurrentRegions.isNotEmpty ||
            nextPrimary != null ||
            showArrivalAsNext;
        if (!hasRegionContent) {
          return const SizedBox.shrink();
        }
        final isGpsSearching = state.gps.status == GpsStatus.searching;
        final showBlockingOverlay =
            isGpsSearching && state.gps.lastFixAt == null;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Card(
            margin: EdgeInsets.zero,
            color: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.95),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.t.flight.route.flyingOverLabel,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GeoAwarenessBlockingOverlay(
                    enabled: showBlockingOverlay,
                    message: isGpsSearching
                        ? context.t.flight.dashboard.gpsSearching
                        : context.t.common.loading,
                    child: AnimatedSize(
                      duration: _wrapAnimationDuration,
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topLeft,
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (visibleCurrentRegions.isNotEmpty)
                            InlineLabelChip(
                              text: '${context.t.flight.route.nowLabel}:',
                            ),
                          for (final region in visibleCurrentRegions)
                            RegionInlineChip(
                              region: region,
                              isLocked: premiumRegionIds.contains(region.qid),
                              onTap: () => _onRegionChipTap(
                                region,
                                offlineArticle:
                                    WikipediaArticleUtils.matchRegionArticle(
                                      region,
                                      state.flight.info.articles,
                                    ),
                                isLocked: premiumRegionIds.contains(region.qid),
                              ),
                            ),
                          if (nextPrimary != null || showArrivalAsNext)
                            InlineLabelChip(
                              text:
                                  '${_nextLabelText(context, arrivalLabelState)}:',
                            ),
                          if (nextPrimary != null || showArrivalAsNext)
                            AnimatedSwitcher(
                              duration: _chipSwapAnimationDuration,
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                final offsetAnimation = Tween<Offset>(
                                  begin: const Offset(0.08, 0),
                                  end: Offset.zero,
                                ).animate(animation);
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  ),
                                );
                              },
                              layoutBuilder: (currentChild, previousChildren) {
                                return Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    ...previousChildren,
                                    if (currentChild != null) currentChild,
                                  ],
                                );
                              },
                              child: _buildNextChip(
                                state: state,
                                nextPrimary: nextPrimary,
                                premiumRegionIds: premiumRegionIds,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNextChip({
    required FlightScreenLoaded state,
    required RouteRegion? nextPrimary,
    required Set<String> premiumRegionIds,
  }) {
    if (nextPrimary != null) {
      return RegionInlineChip(
        key: ValueKey('next-region:${nextPrimary.qid}'),
        region: nextPrimary,
        isNext: true,
        nextRegionEtaMinutes: state.nextRegionEtaMinutes,
        isLocked: premiumRegionIds.contains(nextPrimary.qid),
        onTap: () => _onRegionChipTap(
          nextPrimary,
          offlineArticle: WikipediaArticleUtils.matchRegionArticle(
            nextPrimary,
            state.flight.info.articles,
          ),
          isLocked: premiumRegionIds.contains(nextPrimary.qid),
        ),
      );
    }

    return AirportInlineChip(
      key: ValueKey('next-arrival:${state.flight.route.arrival.displayCode}'),
      airport: state.flight.route.arrival,
      isNext: true,
    );
  }

  String _nextLabelText(
    BuildContext context,
    _ArrivalLabelState? arrivalLabelState,
  ) {
    return switch (arrivalLabelState) {
      _ArrivalLabelState.arriving => context.t.flight.route.arrivingLabel,
      _ArrivalLabelState.arrived => context.t.flight.route.arrivedLabel,
      null || _ArrivalLabelState.next => context.t.flight.route.nextRegionLabel,
    };
  }

  _ArrivalLabelState? _arrivalLabelState(FlightScreenLoaded state) {
    final routeDistanceKm = state.flight.route.distanceInKm;
    if (!routeDistanceKm.isFinite || routeDistanceKm <= 0) return null;

    final progress = (state.routeCoveredDistanceKm / routeDistanceKm).clamp(
      0.0,
      1.5,
    );
    final gpsData = state.gps.data;
    final lat = gpsData?.latitude;
    final lon = gpsData?.longitude;
    if (lat == null || lon == null) {
      return state.routeCoveredDistanceKm < routeDistanceKm
          ? _ArrivalLabelState.next
          : null;
    }

    final distanceToArrivalKm = MapUtils.distanceKm(
      departure: state.flight.route.arrival.latLon,
      arrival: LatLng(lat, lon),
    );
    if (!distanceToArrivalKm.isFinite) {
      return state.routeCoveredDistanceKm < routeDistanceKm
          ? _ArrivalLabelState.next
          : null;
    }

    final speedKmh = _speedKmhFromGps(gpsData);
    final isArrived =
        distanceToArrivalKm <= _arrivedRadiusKm &&
        progress >= _arrivedProgressThreshold &&
        speedKmh != null &&
        speedKmh <= _arrivedMaxSpeedKmh;
    if (isArrived) {
      return _ArrivalLabelState.arrived;
    }

    final isArriving =
        distanceToArrivalKm <= _arrivingRadiusKm &&
        progress >= _arrivingProgressThreshold;
    if (isArriving) {
      return _ArrivalLabelState.arriving;
    }

    return state.routeCoveredDistanceKm < routeDistanceKm
        ? _ArrivalLabelState.next
        : null;
  }

  double? _speedKmhFromGps(GpsData? gpsData) {
    final speed = gpsData?.speed;
    final value = speed?.value;
    if (value == null || !value.isFinite || value < 0) {
      return null;
    }
    final unit = (speed?.unit ?? '').toLowerCase().trim();
    if (unit == 'km/h' || unit == 'kmh' || unit == 'kph') {
      return value;
    }
    if (unit == 'mph') {
      return value * 1.609344;
    }
    return null;
  }

  Future<void> _onRegionChipTap(
    RouteRegion region, {
    FlightArticle? offlineArticle,
    required bool isLocked,
  }) async {
    if (!isLocked) {
      await _openRegionDetailsSheet(region, offlineArticle: offlineArticle);
      return;
    }
    await RoutePremiumGateInteractions.onGateTap(
      context: context,
      source: PaywallSource.geoAwarenessGate,
      useOfflineInfoSheet: true,
    );
  }
}

enum _ArrivalLabelState { next, arriving, arrived }
