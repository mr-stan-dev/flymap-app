import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/domain/entity/flight_route.dart';
import 'package:flymap/domain/entity/route_region.dart';
import 'package:flymap/domain/policy/route_region_premium_gate_policy.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/steps/overview/route_overview_page_entry.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/steps/overview/route_summary_screen.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/steps/overview/widgets/route_overview_map_widget.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/steps/overview/widgets/route_overview_pager.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/steps/overview/widgets/route_overview_progress_timeline.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/viewmodel/flight_preview_cubit.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/viewmodel/flight_preview_state.dart';
import 'package:flymap/ui/screens/subscription/viewmodel/subscription_cubit.dart';
import 'package:flymap/ui/screens/shared/route_timeline/route_timeline_grouping.dart';

class FlightSearchRouteOverviewStep extends StatefulWidget {
  const FlightSearchRouteOverviewStep({
    required this.state,
    required this.isProUser,
    required this.onContinue,
    required this.onPremiumGateTap,
    super.key,
  });

  final FlightPreviewState state;
  final bool isProUser;
  final VoidCallback onContinue;
  final VoidCallback onPremiumGateTap;

  @override
  State<FlightSearchRouteOverviewStep> createState() =>
      _FlightSearchRouteOverviewStepState();
}

class _FlightSearchRouteOverviewStepState
    extends State<FlightSearchRouteOverviewStep> {
  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(0);

  @override
  void didUpdateWidget(covariant FlightSearchRouteOverviewStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    final route = widget.state.flightRoute;
    if (route == null) {
      return;
    }
    final orderedRegions = RouteRegionPremiumGatePolicy.orderByDistance(
      widget.state.routeRegions,
    );
    final gateDecision = RouteRegionPremiumGatePolicy.evaluate(
      orderedRegions: orderedRegions,
      isProUser: widget.isProUser,
    );
    final maxIndex =
        _buildEntries(
          route,
          widget.state,
          orderedRegions: orderedRegions,
          gateDecision: gateDecision,
        ).length -
        1;
    if (_selectedIndexNotifier.value > maxIndex) {
      _selectedIndexNotifier.value = maxIndex;
    }
  }

  @override
  void dispose() {
    _selectedIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final route = widget.state.flightRoute;
    if (route == null) {
      return Center(child: Text(context.t.createFlight.overview.routeNotReady));
    }

    final orderedRegions = RouteRegionPremiumGatePolicy.orderByDistance(
      widget.state.routeRegions,
    );
    final gateDecision = RouteRegionPremiumGatePolicy.evaluate(
      orderedRegions: orderedRegions,
      isProUser: widget.isProUser,
    );
    final entries = _buildEntries(
      route,
      widget.state,
      orderedRegions: orderedRegions,
      gateDecision: gateDecision,
    );
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: ValueListenableBuilder<int>(
            valueListenable: _selectedIndexNotifier,
            builder: (context, selectedIndex, _) {
              final selectedEntry =
                  entries[selectedIndex.clamp(0, entries.length - 1)];
              final selectedRegion = selectedEntry.region;
              final selectedAirport =
                  selectedEntry.kind == RouteOverviewPageKind.departure ||
                      selectedEntry.kind == RouteOverviewPageKind.arrival
                  ? selectedEntry.airport
                  : null;
              final showWholeRoute =
                  selectedEntry.kind == RouteOverviewPageKind.summary ||
                  selectedEntry.kind == RouteOverviewPageKind.premiumGate ||
                  selectedEntry.kind == RouteOverviewPageKind.summaryEnd;
              return Stack(
                children: [
                  Positioned.fill(
                    child: RouteOverviewMapWidget(
                      route: route,
                      flightInfo: widget.state.flightInfo,
                      selectedRegion: selectedRegion,
                      selectedAirport: selectedAirport,
                      showWholeRoute: showWholeRoute,
                    ),
                  ),
                  if (widget.state.isOverviewLoading)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.t.flight.info.overviewLoading,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        ValueListenableBuilder<int>(
          valueListenable: _selectedIndexNotifier,
          builder: (context, selectedIndex, _) {
            final safeIndex = selectedIndex.clamp(0, entries.length - 1);
            final activeKind = entries[safeIndex].kind;
            final visibleRegionCardCount = entries
                .where(
                  (entry) => entry.kind == RouteOverviewPageKind.regionGroup,
                )
                .length;
            final progress = _buildProgressState(
              entries: entries,
              selectedPageEntry: entries[safeIndex],
              gateDecision: gateDecision,
              visibleRegionCardCount: visibleRegionCardCount,
            );
            final timelineCount = progress.itemCount;
            return RouteOverviewProgressTimeline(
              itemCount: timelineCount,
              selectedIndex: progress.selectedIndex,
              isTitleActive: activeKind == RouteOverviewPageKind.summary,
              isSummaryActive: activeKind == RouteOverviewPageKind.summaryEnd,
              isPremiumRangeActive: progress.isPremiumRangeActive,
              premiumRangeStartIndex: progress.premiumRangeStartIndex,
              premiumRangeEndIndex: progress.premiumRangeEndIndex,
              enlargePremiumRange:
                  activeKind == RouteOverviewPageKind.premiumGate,
              enlargeSelectedDot:
                  activeKind != RouteOverviewPageKind.premiumGate &&
                  activeKind != RouteOverviewPageKind.summary &&
                  activeKind != RouteOverviewPageKind.summaryEnd,
            );
          },
        ),
        Expanded(
          flex: 4,
          child: RouteOverviewPager(
            key: const PageStorageKey<String>('route-overview-pager'),
            entries: entries,
            route: route,
            totalRouteMinutes: entries[entries.length - 2].minuteFromDeparture,
            totalRegionCount: orderedRegions.length,
            initialPage: 0,
            onPageChanged: (next) => _selectedIndexNotifier.value = next,
            onRouteSummaryRequested: () => _openRouteSummary(
              context,
              route: route,
              state: widget.state,
              totalRouteMinutes:
                  entries[entries.length - 2].minuteFromDeparture,
            ),
            onPremiumGateTap: widget.onPremiumGateTap,
            onSkipReview: widget.onContinue,
          ),
        ),
      ],
    );
  }

  List<RouteOverviewPageEntry> _buildEntries(
    FlightRoute route,
    FlightPreviewState state, {
    required List<RouteRegion> orderedRegions,
    required RouteRegionPremiumGateDecision gateDecision,
  }) {
    final visibleRegions = gateDecision.freeRegions;
    final hiddenRegions = gateDecision.premiumRegions;
    final groupedVisibleRegions = RouteTimelineGrouping.groupByTimeline(
      visibleRegions,
      cruiseSpeedKmh: state.routeCruiseSpeedKmh,
    );
    final regionEntries = groupedVisibleRegions
        .map(RouteOverviewPageEntry.regionGroup)
        .toList(growable: false);
    final lastRegionMinute = groupedVisibleRegions.isEmpty
        ? 0
        : groupedVisibleRegions.last.minuteFromDeparture;
    final arrivalMinutes = [
      state.routeTotalMinutes,
      _kmToMinutes(
        route.distanceInKm,
        cruiseSpeedKmh: state.routeCruiseSpeedKmh,
      ),
      lastRegionMinute,
    ].reduce((a, b) => a > b ? a : b);

    final entries = <RouteOverviewPageEntry>[
      RouteOverviewPageEntry.summary(),
      RouteOverviewPageEntry.departure(route.departure),
      ...regionEntries,
      if (gateDecision.isGated && hiddenRegions.isNotEmpty)
        RouteOverviewPageEntry.premiumGate(
          minuteFromDeparture: _regionMinute(
            hiddenRegions.first,
            cruiseSpeedKmh: state.routeCruiseSpeedKmh,
          ),
        ),
      RouteOverviewPageEntry.arrival(
        route.arrival,
        minuteFromDeparture: arrivalMinutes,
      ),
      RouteOverviewPageEntry.summaryEnd(minuteFromDeparture: arrivalMinutes),
    ];
    return entries;
  }

  _RouteOverviewProgressState _buildProgressState({
    required List<RouteOverviewPageEntry> entries,
    required RouteOverviewPageEntry selectedPageEntry,
    required RouteRegionPremiumGateDecision gateDecision,
    required int visibleRegionCardCount,
  }) {
    final hiddenPremiumRegionCount = gateDecision.premiumRegions.length;
    final hasPremiumRange =
        gateDecision.isGated && hiddenPremiumRegionCount > 0;
    final premiumRangeStartIndex = hasPremiumRange
        ? (visibleRegionCardCount + 1)
        : null;
    final premiumRangeEndIndex = hasPremiumRange
        ? (premiumRangeStartIndex! + hiddenPremiumRegionCount - 1)
        : null;
    final stopCount = (visibleRegionCardCount + hiddenPremiumRegionCount + 2)
        .clamp(2, 9999);
    final entryKind = selectedPageEntry.kind;
    final visibleEntries = entries
        .where((entry) => entry.kind == RouteOverviewPageKind.regionGroup)
        .toList(growable: false);
    int clampedSelectedStopIndex;
    if (entryKind == RouteOverviewPageKind.summary ||
        entryKind == RouteOverviewPageKind.departure) {
      clampedSelectedStopIndex = 0;
    } else if (entryKind == RouteOverviewPageKind.arrival ||
        entryKind == RouteOverviewPageKind.summaryEnd) {
      clampedSelectedStopIndex = stopCount - 1;
    } else if (entryKind == RouteOverviewPageKind.premiumGate) {
      clampedSelectedStopIndex = premiumRangeStartIndex ?? (stopCount - 1);
    } else {
      final visibleIndex = visibleEntries.indexOf(selectedPageEntry);
      clampedSelectedStopIndex = (visibleIndex < 0 ? 0 : visibleIndex + 1)
          .clamp(0, stopCount - 1);
    }

    final keepPremiumRangeActive =
        hasPremiumRange && entryKind == RouteOverviewPageKind.premiumGate;
    final premiumStartForState = keepPremiumRangeActive
        ? premiumRangeStartIndex
        : null;
    final premiumEndForState = keepPremiumRangeActive
        ? premiumRangeEndIndex
        : null;

    if (entryKind == RouteOverviewPageKind.summary) {
      return _RouteOverviewProgressState(
        itemCount: stopCount,
        selectedIndex: 0,
        isPremiumRangeActive: keepPremiumRangeActive,
        premiumRangeStartIndex: premiumStartForState,
        premiumRangeEndIndex: premiumEndForState,
      );
    }
    if (entryKind == RouteOverviewPageKind.summaryEnd) {
      return _RouteOverviewProgressState(
        itemCount: stopCount,
        selectedIndex: stopCount - 1,
        isPremiumRangeActive: keepPremiumRangeActive,
        premiumRangeStartIndex: premiumStartForState,
        premiumRangeEndIndex: premiumEndForState,
      );
    }
    return _RouteOverviewProgressState(
      itemCount: stopCount,
      selectedIndex: clampedSelectedStopIndex,
      isPremiumRangeActive: keepPremiumRangeActive,
      premiumRangeStartIndex: premiumStartForState,
      premiumRangeEndIndex: premiumEndForState,
    );
  }

  int _kmToMinutes(double distanceKm, {required int cruiseSpeedKmh}) {
    if (!distanceKm.isFinite || distanceKm <= 0 || cruiseSpeedKmh <= 0) {
      return 0;
    }
    return (((distanceKm * 60) / cruiseSpeedKmh) / 5).round() * 5;
  }

  int _regionMinute(RouteRegion region, {required int cruiseSpeedKmh}) {
    return RouteTimelineGrouping.toTimelineMinute(
      region.pathFirstEncounterKm,
      cruiseSpeedKmh: cruiseSpeedKmh,
    );
  }

  void _openRouteSummary(
    BuildContext context, {
    required FlightRoute route,
    required FlightPreviewState state,
    required int totalRouteMinutes,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<FlightPreviewCubit>()),
            BlocProvider.value(value: context.read<SubscriptionCubit>()),
          ],
          child: RouteSummaryScreen(
            route: route,
            totalRouteMinutes: totalRouteMinutes,
            cruiseSpeedKmh: state.routeCruiseSpeedKmh,
            onContinue: widget.onContinue,
          ),
        ),
      ),
    );
  }
}

class _RouteOverviewProgressState {
  const _RouteOverviewProgressState({
    required this.itemCount,
    required this.selectedIndex,
    this.isPremiumRangeActive = false,
    this.premiumRangeStartIndex,
    this.premiumRangeEndIndex,
  });

  final int itemCount;
  final int selectedIndex;
  final bool isPremiumRangeActive;
  final int? premiumRangeStartIndex;
  final int? premiumRangeEndIndex;
}
