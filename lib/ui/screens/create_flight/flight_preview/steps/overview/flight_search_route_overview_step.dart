import 'package:flutter/material.dart';
import 'package:flymap/entity/flight_route.dart';
import 'package:flymap/entity/map_detail_level.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/design_system/design_system.dart';
import 'package:flymap/ui/theme/app_colours.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/steps/overview/route_overview_page_entry.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/steps/overview/route_summary_screen.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/steps/overview/widgets/route_overview_map_widget.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/steps/overview/widgets/route_overview_pager.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/steps/overview/widgets/route_overview_progress_timeline.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/viewmodel/flight_preview_state.dart';
import 'package:flymap/ui/screens/shared/route_timeline/route_timeline_grouping.dart';

class FlightSearchRouteOverviewStep extends StatefulWidget {
  const FlightSearchRouteOverviewStep({
    required this.state,
    required this.isProUser,
    required this.onContinue,
    required this.onSelectMapDetailLevel,
    required this.onUpgradeToPro,
    super.key,
  });

  final FlightPreviewState state;
  final bool isProUser;
  final VoidCallback onContinue;
  final ValueChanged<MapDetailLevel> onSelectMapDetailLevel;
  final VoidCallback onUpgradeToPro;

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
    final maxIndex = _buildEntries(route, widget.state).length - 1;
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
    final selectedDetailLevel = widget.isProUser
        ? MapDetailLevel.pro
        : widget.state.selectedMapDetailLevel;
    if (widget.isProUser &&
        widget.state.selectedMapDetailLevel != MapDetailLevel.pro) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSelectMapDetailLevel(MapDetailLevel.pro);
      });
    }
    final isFreeUserWithProSelection =
        !widget.isProUser && selectedDetailLevel == MapDetailLevel.pro;

    final entries = _buildEntries(route, widget.state);
    final topSection = Expanded(
      child: Column(
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
                    Positioned(
                      top: widget.state.isOverviewLoading ? 52 : 12,
                      right: 12,
                      child: _MapDetailSwitcher(
                        isProUser: widget.isProUser,
                        selected: selectedDetailLevel,
                        onSelect: widget.onSelectMapDetailLevel,
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
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
              final timelineCount = (entries.length - 2).clamp(2, 9999);
              final timelineIndex = _timelineSelectedIndexForPage(
                pageIndex: safeIndex,
                timelineCount: timelineCount,
                maxPageIndex: entries.length - 1,
              );
              return RouteOverviewProgressTimeline(
                itemCount: timelineCount,
                selectedIndex: timelineIndex,
                isTitleActive: activeKind == RouteOverviewPageKind.summary,
                isSummaryActive: activeKind == RouteOverviewPageKind.summaryEnd,
              );
            },
          ),
          Expanded(
            flex: 4,
            child: RouteOverviewPager(
              key: const PageStorageKey<String>('route-overview-pager'),
              entries: entries,
              route: route,
              totalRouteMinutes:
                  entries[entries.length - 2].minuteFromDeparture,
              initialPage: 0,
              onPageChanged: (next) => _selectedIndexNotifier.value = next,
              onRouteSummaryRequested: () => _openRouteSummary(
                context,
                route: route,
                state: widget.state,
                totalRouteMinutes:
                    entries[entries.length - 2].minuteFromDeparture,
              ),
            ),
          ),
        ],
      ),
    );

    return Column(
      children: [
        topSection,
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: isFreeUserWithProSelection
              ? PremiumButton(
                  onPressed: widget.onUpgradeToPro,
                  label: context.t.createFlight.mapPreview.upgradeToPro,
                  icon: Icons.workspace_premium_rounded,
                )
              : PrimaryButton(
                  onPressed: widget.onContinue,
                  label: context.t.common.kContinue,
                ),
        ),
      ],
    );
  }

  List<RouteOverviewPageEntry> _buildEntries(
    FlightRoute route,
    FlightPreviewState state,
  ) {
    final regionGroups = RouteTimelineGrouping.groupByTimeline(
      state.routeRegions,
      cruiseSpeedKmh: state.routeCruiseSpeedKmh,
    );
    final lastRegionMinute = regionGroups.isEmpty
        ? 0
        : regionGroups.last.minuteFromDeparture;
    final arrivalMinutes = [
      state.routeTotalMinutes,
      _kmToMinutes(
        route.distanceInKm,
        cruiseSpeedKmh: state.routeCruiseSpeedKmh,
      ),
      lastRegionMinute,
    ].reduce((a, b) => a > b ? a : b);

    final regionEntries = regionGroups
        .map(
          (group) => RouteOverviewPageEntry.region(
            group.topRegion!,
            minuteFromDeparture: group.minuteFromDeparture,
          ),
        )
        .toList(growable: false);

    return [
      RouteOverviewPageEntry.summary(),
      RouteOverviewPageEntry.departure(route.departure),
      ...regionEntries,
      RouteOverviewPageEntry.arrival(
        route.arrival,
        minuteFromDeparture: arrivalMinutes,
      ),
      RouteOverviewPageEntry.summaryEnd(minuteFromDeparture: arrivalMinutes),
    ];
  }

  int _kmToMinutes(double distanceKm, {required int cruiseSpeedKmh}) {
    if (!distanceKm.isFinite || distanceKm <= 0 || cruiseSpeedKmh <= 0) {
      return 0;
    }
    return (((distanceKm * 60) / cruiseSpeedKmh) / 5).round() * 5;
  }

  int _timelineSelectedIndexForPage({
    required int pageIndex,
    required int timelineCount,
    required int maxPageIndex,
  }) {
    if (pageIndex <= 0) {
      return 0;
    }
    if (pageIndex >= maxPageIndex) {
      return timelineCount - 1;
    }
    return (pageIndex - 1).clamp(0, timelineCount - 1);
  }

  void _openRouteSummary(
    BuildContext context, {
    required FlightRoute route,
    required FlightPreviewState state,
    required int totalRouteMinutes,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RouteSummaryScreen(
          route: route,
          regions: RouteTimelineGrouping.rankAndLimit(state.routeRegions),
          totalRouteMinutes: totalRouteMinutes,
          pois: state.flightInfo.poi,
          cruiseSpeedKmh: state.routeCruiseSpeedKmh,
        ),
      ),
    );
  }
}

class _MapDetailSwitcher extends StatelessWidget {
  const _MapDetailSwitcher({
    required this.isProUser,
    required this.selected,
    required this.onSelect,
  });

  final bool isProUser;
  final MapDetailLevel selected;
  final ValueChanged<MapDetailLevel> onSelect;

  @override
  Widget build(BuildContext context) {
    final isProSelected = selected == MapDetailLevel.pro;
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.t.createFlight.mapPreview.pro,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColoursCommon.brandWhite,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Transform.scale(
              scale: 0.72,
              child: Switch(
                value: isProSelected,
                onChanged: isProUser
                    ? null
                    : (value) => onSelect(
                        value ? MapDetailLevel.pro : MapDetailLevel.basic,
                      ),
                activeTrackColor: AppColoursCommon.brandBlue,
                activeThumbColor: Colors.white,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
