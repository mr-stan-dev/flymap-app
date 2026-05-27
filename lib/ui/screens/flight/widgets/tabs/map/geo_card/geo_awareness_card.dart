import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/domain/entity/gps_data.dart';
import 'package:flymap/domain/entity/route_region.dart';
import 'package:flymap/domain/policy/route_region_premium_gate_policy.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/subscription/paywall_source.dart';
import 'package:flymap/ui/screens/flight/viewmodel/flight_screen_cubit.dart';
import 'package:flymap/ui/screens/flight/viewmodel/flight_screen_state.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/geo_card/widgets/geo_awareness_blocking_overlay.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/geo_card/widgets/geo_awareness_region_details_sheet.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/geo_card/widgets/inline_label_chip.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/geo_card/widgets/region_inline_chip.dart';
import 'package:flymap/ui/screens/shared/premium/route_premium_gate_interactions.dart';
import 'package:flymap/ui/screens/subscription/viewmodel/subscription_cubit.dart';

class GeoAwarenessCard extends StatefulWidget {
  const GeoAwarenessCard({required this.onSelectedRegionChanged, super.key});

  final ValueChanged<RouteRegion?> onSelectedRegionChanged;

  @override
  State<GeoAwarenessCard> createState() => _GeoAwarenessCardState();
}

class _GeoAwarenessCardState extends State<GeoAwarenessCard> {
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

  Future<void> _openRegionDetailsSheet(RouteRegion region) async {
    widget.onSelectedRegionChanged(region);

    await showGeoAwarenessRegionDetailsSheet(context, region: region);

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
        final hasRegionContent =
            currentRegions.isNotEmpty || nextPrimary != null;
        if (!hasRegionContent) {
          return const SizedBox.shrink();
        }
        final isGpsSearching = state.gps.status == GpsStatus.searching;
        final showBlockingOverlay =
            isGpsSearching && state.gps.lastFixAt == null;
        final showStaleHint = isGpsSearching && state.gps.lastFixAt != null;

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
                  if (showStaleHint) ...[
                    const SizedBox(height: 4),
                    Text(
                      context.t.flight.dashboard.gpsShowingLastKnownData,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  GeoAwarenessBlockingOverlay(
                    enabled: showBlockingOverlay,
                    message: isGpsSearching
                        ? context.t.flight.dashboard.gpsSearching
                        : context.t.common.loading,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (currentRegions.isNotEmpty)
                          InlineLabelChip(
                            text: '${context.t.flight.route.nowLabel}:',
                          ),
                        for (final region in currentRegions)
                          RegionInlineChip(
                            region: region,
                            isLocked: premiumRegionIds.contains(region.qid),
                            onTap: () => _onRegionChipTap(
                              region,
                              isLocked: premiumRegionIds.contains(region.qid),
                            ),
                          ),
                        if (nextPrimary != null)
                          InlineLabelChip(
                            text: '${context.t.flight.route.nextRegionLabel}:',
                          ),
                        if (nextPrimary != null)
                          RegionInlineChip(
                            region: nextPrimary,
                            isNext: true,
                            nextRegionEtaMinutes: state.nextRegionEtaMinutes,
                            isLocked: premiumRegionIds.contains(
                              nextPrimary.qid,
                            ),
                            onTap: () => _onRegionChipTap(
                              nextPrimary,
                              isLocked: premiumRegionIds.contains(
                                nextPrimary.qid,
                              ),
                            ),
                          ),
                      ],
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

  Future<void> _onRegionChipTap(
    RouteRegion region, {
    required bool isLocked,
  }) async {
    if (!isLocked) {
      await _openRegionDetailsSheet(region);
      return;
    }
    await RoutePremiumGateInteractions.onGateTap(
      context: context,
      source: PaywallSource.geoAwarenessGate,
      useOfflineInfoSheet: true,
    );
  }
}
