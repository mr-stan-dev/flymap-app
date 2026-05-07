import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/domain/entity/gps_data.dart';
import 'package:flymap/domain/entity/route_region.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/subscription/paywall_source.dart';
import 'package:flymap/ui/screens/flight/viewmodel/flight_screen_cubit.dart';
import 'package:flymap/ui/screens/flight/viewmodel/flight_screen_state.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/telemetry_searching_overlay.dart';
import 'package:flymap/ui/screens/subscription/viewmodel/subscription_cubit.dart';
import 'package:flymap/ui/screens/shared/premium/route_premium_gate_interactions.dart';
import 'package:flymap/domain/policy/route_region_premium_gate_policy.dart';
import 'package:flymap/ui/screens/shared/region_artwork.dart';
import 'package:flymap/ui/screens/shared/route_timeline/route_timeline_region_type_mapper.dart';

class GeoAwarenessCard extends StatefulWidget {
  const GeoAwarenessCard({required this.onSelectedRegionChanged, super.key});

  final ValueChanged<RouteRegion?> onSelectedRegionChanged;

  @override
  State<GeoAwarenessCard> createState() => _GeoAwarenessCardState();
}

class _GeoAwarenessCardState extends State<GeoAwarenessCard> {
  static const _typeMapper = RouteTimelineRegionTypeMapper();

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

    final typeLabel = _typeMapper.mapLabel(context, region.regionType);
    final description = region.description?.trim().isNotEmpty == true
        ? region.description!.trim()
        : context.t.createFlight.overview.regionInfo.descriptionUnavailable;

    await showModalBottomSheet<void>(
      context: context,
      barrierColor: Colors.transparent,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final bottomInset = MediaQuery.viewPaddingOf(sheetContext).bottom;
        final colorScheme = Theme.of(sheetContext).colorScheme;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 16 + bottomInset),
          child: Material(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RegionArtwork(
                        regionName: region.name,
                        regionType: region.regionType,
                        size: 56,
                        borderRadius: 10,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              region.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(sheetContext)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              typeLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(
                                sheetContext,
                              ).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: Theme.of(
                      sheetContext,
                    ).textTheme.bodyMedium?.copyWith(height: 1.35),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
              previous.gpsStatus != current.gpsStatus ||
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
        final isGpsSearching = state.gpsStatus == GpsStatus.searching;
        final showLoadingState = !hasRegionContent;

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
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (showLoadingState)
                    const _GeoAwarenessLoadingState()
                  else
                    TelemetrySearchingOverlay(
                      enabled: isGpsSearching,
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (currentRegions.isNotEmpty)
                            _InlineLabelChip(
                              text: '${context.t.flight.route.nowLabel}:',
                            ),
                          for (final region in currentRegions)
                            _RegionInlineChip(
                              region: region,
                              isLocked: premiumRegionIds.contains(region.qid),
                              onTap: () => _onRegionChipTap(
                                region,
                                isLocked: premiumRegionIds.contains(region.qid),
                              ),
                            ),
                          if (nextPrimary != null)
                            _InlineLabelChip(
                              text:
                                  '${context.t.flight.route.nextRegionLabel}:',
                            ),
                          if (nextPrimary != null)
                            _RegionInlineChip(
                              region: nextPrimary,
                              isNext: true,
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

class _InlineLabelChip extends StatelessWidget {
  const _InlineLabelChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 4, top: 6, bottom: 6),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _RegionInlineChip extends StatelessWidget {
  const _RegionInlineChip({
    required this.region,
    required this.isLocked,
    required this.onTap,
    this.isNext = false,
  });

  final RouteRegion region;
  final bool isLocked;
  final VoidCallback onTap;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgAlpha = isNext ? 0.82 : 1.0;
    final textAlpha = isNext ? 0.9 : 1.0;

    return Material(
      color: colorScheme.surfaceContainerLow.withValues(alpha: bgAlpha),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 4, 8, 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLocked)
                Icon(
                  Icons.lock_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )
              else
                RegionArtwork(
                  regionName: region.name,
                  regionType: region.regionType,
                  size: 18,
                  borderRadius: 4,
                  isCircle: true,
                ),
              const SizedBox(width: 6),
              Text(
                isLocked
                    ? context.t.flight.route.premiumLockedChipLabel
                    : region.name,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: textAlpha),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GeoAwarenessLoadingState extends StatelessWidget {
  const _GeoAwarenessLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
          const SizedBox(width: 10),
          Text(
            context.t.flight.dashboard.gpsSearching,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
