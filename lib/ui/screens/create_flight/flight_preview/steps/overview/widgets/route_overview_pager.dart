import 'package:flutter/material.dart';
import 'package:flymap/entity/flight_route.dart';
import 'package:flymap/entity/route_region.dart';
import 'package:flymap/entity/route_region_type.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/steps/overview/route_overview_page_entry.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/steps/overview/region_info_screen.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/steps/overview/widgets/overview_airport_card.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/steps/overview/widgets/overview_region_card.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/steps/overview/widgets/overview_summary_card.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/steps/overview/widgets/overview_title_card.dart';
import 'package:flymap/ui/screens/shared/route_timeline/route_timeline_region_type_mapper.dart';
import 'package:flymap/ui/map/map_utils.dart';
import 'package:flymap/utils/route_utils.dart';

class RouteOverviewPager extends StatefulWidget {
  const RouteOverviewPager({
    required this.entries,
    required this.route,
    required this.totalRouteMinutes,
    required this.onRouteSummaryRequested,
    this.initialPage = 0,
    required this.onPageChanged,
    super.key,
  });

  final List<RouteOverviewPageEntry> entries;
  final FlightRoute route;
  final int totalRouteMinutes;
  final VoidCallback onRouteSummaryRequested;
  final int initialPage;
  final ValueChanged<int> onPageChanged;

  @override
  State<RouteOverviewPager> createState() => _RouteOverviewPagerState();
}

class _RouteOverviewPagerState extends State<RouteOverviewPager> {
  late final PageController _controller;
  static const _typeMapper = RouteTimelineRegionTypeMapper();

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      viewportFraction: 0.88,
      initialPage: widget.initialPage,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      padEnds: false,
      itemCount: widget.entries.length,
      onPageChanged: widget.onPageChanged,
      itemBuilder: (context, index) {
        final entry = widget.entries[index];
        return Padding(
          padding: EdgeInsets.only(
            left: index == 0 ? 16 : 6,
            right: index == widget.entries.length - 1 ? 16 : 6,
            top: 4,
            bottom: 8,
          ),
          child: _buildCard(context, entry),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, RouteOverviewPageEntry entry) {
    final t = context.t;
    switch (entry.kind) {
      case RouteOverviewPageKind.summary:
        final route = widget.route;
        return OverviewTitleCard(
          routeTitleLabel: t.createFlight.overview.routeTitleLabel,
          routeCodeLine:
              '${route.departure.displayCode} → ${route.arrival.displayCode}',
          routeCitiesLine:
              '${RouteUtils.cityLabel(route.departure.city)} → ${RouteUtils.cityLabel(route.arrival.city)}',
          routeMetaLine:
              '${MapUtils.distanceFormatted(departure: route.departure, arrival: route.arrival)} • ${_formatMinutesCompact(context, widget.totalRouteMinutes)}',
          startLabel: t.createFlight.overview.start,
          onStart: _animateToNextCard,
        );
      case RouteOverviewPageKind.departure:
        final airport = entry.airport!;
        return OverviewAirportCard(
          icon: Icons.flight_takeoff_rounded,
          title: airport.name,
          subtitle:
              '${t.flight.info.departure} • ${airport.displayCode} • ${RouteUtils.cityLabel(airport.city)}',
          description: t.createFlight.overview.airportCard.departureDescription(
            airport: airport.name,
          ),
        );
      case RouteOverviewPageKind.arrival:
        final airport = entry.airport!;
        return OverviewAirportCard(
          icon: Icons.flight_land_rounded,
          title: airport.name,
          subtitle:
              '${t.flight.info.arrival} • ${airport.displayCode} • ${RouteUtils.cityLabel(airport.city)}',
          description: t.createFlight.overview.airportCard.arrivalDescription(
            airport: airport.name,
          ),
        );
      case RouteOverviewPageKind.region:
        final region = entry.region!;
        final typeLabel = _typeMapper.mapLabel(context, region.regionType);
        return OverviewRegionCard(
          title: region.name,
          subtitle: typeLabel,
          description: region.fromAboveDescription?.trim().isNotEmpty == true
              ? region.fromAboveDescription!.trim()
              : t.createFlight.overview.regionInfo.descriptionUnavailable,
          readMoreLabel: t.common.readMore,
          onReadMore: () =>
              _openRegionInfo(context, region: region, typeLabel: typeLabel),
        );
      case RouteOverviewPageKind.summaryEnd:
        final typeCounts = _collectRegionTypeCounts();
        return OverviewSummaryCard(
          title: t.createFlight.overview.allRegionsYouFlyOver,
          chipLabels: typeCounts.map((item) {
            final label = _typeMapper.mapLabel(context, item.type);
            return _formatTypeCount(item.count, label);
          }).toList(),
          fullSummaryLabel: t.createFlight.overview.fullSummary,
          onFullSummary: widget.onRouteSummaryRequested,
        );
    }
  }

  String _formatMinutesCompact(BuildContext context, int minutes) {
    final timelineT = context.t.createFlight.overview.timeline;
    if (minutes <= 0) {
      return '0 ${timelineT.minuteUnit}';
    }
    if (minutes < 60) {
      return '$minutes ${timelineT.minuteUnit}';
    }
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (m == 0) {
      return '$h${timelineT.hourCompactUnit}';
    }
    return '$h${timelineT.hourCompactUnit} $m${timelineT.minuteCompactUnit}';
  }

  void _animateToNextCard() {
    final nextIndex = (_controller.page?.round() ?? widget.initialPage) + 1;
    if (nextIndex >= widget.entries.length) return;
    _controller.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  List<_RegionTypeCount> _collectRegionTypeCounts() {
    final counts = <RouteRegionType, int>{};
    final seenRegionIds = <String>{};
    for (final entry in widget.entries) {
      if (entry.kind != RouteOverviewPageKind.region || entry.region == null) {
        continue;
      }
      final region = entry.region!;
      if (!seenRegionIds.add(region.qid)) continue;
      counts.update(
        region.regionType,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    final out = counts.entries
        .map((entry) => _RegionTypeCount(type: entry.key, count: entry.value))
        .toList();
    out.sort((a, b) {
      if (a.count != b.count) {
        return b.count.compareTo(a.count);
      }
      return a.type.apiValue.compareTo(b.type.apiValue);
    });
    return out;
  }

  String _formatTypeCount(int count, String typeLabel) {
    final base = typeLabel.toLowerCase();
    if (count == 1) {
      return '$count $base';
    }
    if (base == 'country') {
      return '$count countries';
    }
    if (base.endsWith('y')) {
      return '$count ${base.substring(0, base.length - 1)}ies';
    }
    if (base.endsWith('s')) {
      return '$count ${base}es';
    }
    return '$count ${base}s';
  }

  Future<void> _openRegionInfo(
    BuildContext context, {
    required RouteRegion region,
    required String typeLabel,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RegionInfoScreen(region: region, typeLabel: typeLabel),
      ),
    );
  }
}

class _RegionTypeCount {
  const _RegionTypeCount({required this.type, required this.count});

  final RouteRegionType type;
  final int count;
}
