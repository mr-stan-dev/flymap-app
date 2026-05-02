import 'package:flutter/material.dart';
import 'package:flymap/entity/airport.dart';
import 'package:flymap/entity/flight_route.dart';
import 'package:flymap/entity/route_region.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/screens/shared/route_timeline/route_timeline_grouping.dart';
import 'package:flymap/ui/screens/shared/route_timeline/widgets/airport_timeline_card.dart';
import 'package:flymap/ui/screens/shared/route_timeline/widgets/region_group_timeline_card.dart';

class RouteTimelineWidget extends StatelessWidget {
  const RouteTimelineWidget({
    required this.route,
    required this.regions,
    required this.cruiseSpeedKmh,
    required this.totalRouteMinutes,
    this.currentRegionQid,
    this.lastVisitedRegionQid,
    this.onOpenRegion,
    super.key,
  });

  final FlightRoute route;
  final List<RouteRegion> regions;
  final int cruiseSpeedKmh;
  final int totalRouteMinutes;
  final String? currentRegionQid;
  final String? lastVisitedRegionQid;
  final ValueChanged<RouteRegion>? onOpenRegion;

  @override
  Widget build(BuildContext context) {
    final groups = RouteTimelineGrouping.groupByTimeline(
      regions,
      cruiseSpeedKmh: cruiseSpeedKmh,
    );
    final entries = _buildEntries(groups);
    final currentEntryIndex = _findEntryIndexByRegionQid(
      entries,
      regionQid: currentRegionQid,
    );
    final visitedEntryIndex =
        currentEntryIndex ??
        _findEntryIndexByRegionQid(entries, regionQid: lastVisitedRegionQid);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < entries.length; index++)
          _RouteTimelineRow(
            timingLabel: _buildMinuteLabel(context, entries[index]),
            isFirst: index == 0,
            isLast: index == entries.length - 1,
            pointState: _pointState(
              index: index,
              currentEntryIndex: currentEntryIndex,
              visitedEntryIndex: visitedEntryIndex,
            ),
            lineAboveState: _lineAboveState(
              index: index,
              currentEntryIndex: currentEntryIndex,
              visitedEntryIndex: visitedEntryIndex,
            ),
            lineBelowState: _lineBelowState(
              index: index,
              currentEntryIndex: currentEntryIndex,
              visitedEntryIndex: visitedEntryIndex,
            ),
            card: _buildCard(entries[index]),
          ),
      ],
    );
  }

  List<_RouteTimelineEntry> _buildEntries(
    List<RouteTimelineRegionGroup> groups,
  ) {
    final arrivalMinutes = RouteTimelineGrouping.arrivalMinutes(
      routeDistanceKm: route.distanceInKm,
      totalRouteMinutes: totalRouteMinutes,
      cruiseSpeedKmh: cruiseSpeedKmh,
      groups: groups,
    );

    return [
      _RouteTimelineEntry.departure(route.departure),
      ...groups.map(_RouteTimelineEntry.group),
      _RouteTimelineEntry.arrival(
        route.arrival,
        minuteFromDeparture: arrivalMinutes,
      ),
    ];
  }

  int? _findEntryIndexByRegionQid(
    List<_RouteTimelineEntry> entries, {
    required String? regionQid,
  }) {
    if (regionQid == null || regionQid.isEmpty) return null;
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      if (entry.kind != _RouteTimelineEntryKind.group) continue;
      final group = entry.regionGroup;
      if (group == null) continue;
      final found = group.regions.any((region) => region.qid == regionQid);
      if (found) return i;
    }
    return null;
  }

  _RouteTimelinePointState _pointState({
    required int index,
    required int? currentEntryIndex,
    required int? visitedEntryIndex,
  }) {
    if (currentEntryIndex != null) {
      if (index < currentEntryIndex) return _RouteTimelinePointState.past;
      if (index == currentEntryIndex) return _RouteTimelinePointState.current;
      return _RouteTimelinePointState.future;
    }
    if (visitedEntryIndex != null) {
      return index <= visitedEntryIndex
          ? _RouteTimelinePointState.past
          : _RouteTimelinePointState.future;
    }
    return _RouteTimelinePointState.future;
  }

  _RouteTimelinePointState _lineAboveState({
    required int index,
    required int? currentEntryIndex,
    required int? visitedEntryIndex,
  }) {
    if (currentEntryIndex != null) {
      return index <= currentEntryIndex
          ? _RouteTimelinePointState.past
          : _RouteTimelinePointState.future;
    }
    if (visitedEntryIndex != null) {
      return index <= visitedEntryIndex
          ? _RouteTimelinePointState.past
          : _RouteTimelinePointState.future;
    }
    return _RouteTimelinePointState.future;
  }

  _RouteTimelinePointState _lineBelowState({
    required int index,
    required int? currentEntryIndex,
    required int? visitedEntryIndex,
  }) {
    if (currentEntryIndex != null) {
      return index < currentEntryIndex
          ? _RouteTimelinePointState.past
          : _RouteTimelinePointState.future;
    }
    if (visitedEntryIndex != null) {
      return index < visitedEntryIndex
          ? _RouteTimelinePointState.past
          : _RouteTimelinePointState.future;
    }
    return _RouteTimelinePointState.future;
  }

  Widget _buildCard(_RouteTimelineEntry entry) {
    switch (entry.kind) {
      case _RouteTimelineEntryKind.departure:
        return AirportTimelineCard(
          airport: entry.airport!,
          icon: Icons.flight_takeoff_rounded,
        );
      case _RouteTimelineEntryKind.arrival:
        return AirportTimelineCard(
          airport: entry.airport!,
          icon: Icons.flight_land_rounded,
        );
      case _RouteTimelineEntryKind.group:
        final onOpenRegion = this.onOpenRegion;
        return RegionGroupTimelineCard(
          group: entry.regionGroup!,
          onOpenRegion: onOpenRegion,
        );
    }
  }

  _TimingLabel _buildMinuteLabel(
    BuildContext context,
    _RouteTimelineEntry entry,
  ) {
    return _formatTimingLabel(context, entry.minuteFromDeparture);
  }

  _TimingLabel _formatTimingLabel(BuildContext context, int? minutesRaw) {
    final minutes = minutesRaw ?? 0;
    final timelineT = context.t.createFlight.overview.timeline;
    final minuteUnit = timelineT.minuteCompactUnit;
    final hourUnit = timelineT.hourCompactUnit;
    if (minutes <= 0) {
      return _TimingLabel.single(_TimingLine(value: '0', unit: minuteUnit));
    }
    if (minutes < 60) {
      return _TimingLabel.single(
        _TimingLine(value: '$minutes', unit: minuteUnit),
      );
    }
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return _TimingLabel.twoLines(
      firstLine: _TimingLine(value: '$h', unit: hourUnit),
      secondLine: _TimingLine(value: '$m', unit: minuteUnit),
    );
  }
}

enum _RouteTimelineEntryKind { departure, group, arrival }

class _RouteTimelineEntry {
  const _RouteTimelineEntry._({
    required this.kind,
    required this.minuteFromDeparture,
    this.airport,
    this.regionGroup,
  });

  final _RouteTimelineEntryKind kind;
  final int minuteFromDeparture;
  final Airport? airport;
  final RouteTimelineRegionGroup? regionGroup;

  factory _RouteTimelineEntry.departure(Airport airport) {
    return _RouteTimelineEntry._(
      kind: _RouteTimelineEntryKind.departure,
      minuteFromDeparture: 0,
      airport: airport,
    );
  }

  factory _RouteTimelineEntry.group(RouteTimelineRegionGroup group) {
    return _RouteTimelineEntry._(
      kind: _RouteTimelineEntryKind.group,
      minuteFromDeparture: group.minuteFromDeparture,
      regionGroup: group,
    );
  }

  factory _RouteTimelineEntry.arrival(
    Airport airport, {
    required int minuteFromDeparture,
  }) {
    return _RouteTimelineEntry._(
      kind: _RouteTimelineEntryKind.arrival,
      minuteFromDeparture: minuteFromDeparture,
      airport: airport,
    );
  }
}

enum _RouteTimelinePointState { past, current, future }

class _RouteTimelineRow extends StatelessWidget {
  const _RouteTimelineRow({
    required this.timingLabel,
    required this.isFirst,
    required this.isLast,
    required this.pointState,
    required this.lineAboveState,
    required this.lineBelowState,
    required this.card,
  });

  final _TimingLabel timingLabel;
  final bool isFirst;
  final bool isLast;
  final _RouteTimelinePointState pointState;
  final _RouteTimelinePointState lineAboveState;
  final _RouteTimelinePointState lineBelowState;
  final Widget card;

  @override
  Widget build(BuildContext context) {
    final futureColor = Theme.of(
      context,
    ).colorScheme.outline.withValues(alpha: 0.35);
    final passedColor = Theme.of(context).colorScheme.primary;
    const currentColor = Color(0xFF22C55E);

    Color colorFor(_RouteTimelinePointState state) {
      switch (state) {
        case _RouteTimelinePointState.past:
          return passedColor;
        case _RouteTimelinePointState.current:
          return currentColor;
        case _RouteTimelinePointState.future:
          return futureColor;
      }
    }

    final pointColor = colorFor(pointState);
    final colorScheme = Theme.of(context).colorScheme;
    final digitStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w800,
      height: 1.0,
      color: colorScheme.onSurfaceVariant,
    );
    final unitStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      height: 1.0,
      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
    );
    final timingMaxWidth = _maxTimingRailWidth(
      context,
      digitStyle: digitStyle,
      unitStyle: unitStyle,
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: timingMaxWidth,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Align(
                alignment: Alignment.topRight,
                child: _TimingLabelText(
                  label: timingLabel,
                  digitStyle: digitStyle,
                  unitStyle: unitStyle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                  child: Container(
                    width: 2,
                    color: isFirst
                        ? Colors.transparent
                        : colorFor(lineAboveState),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: pointState == _RouteTimelinePointState.current
                      ? _PulsingTimelineDot(color: pointColor)
                      : Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: pointColor, width: 2),
                          ),
                        ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast
                        ? Colors.transparent
                        : colorFor(lineBelowState),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 2, 0, 6),
              child: card,
            ),
          ),
        ],
      ),
    );
  }

  double _maxTimingRailWidth(
    BuildContext context, {
    TextStyle? digitStyle,
    TextStyle? unitStyle,
  }) {
    final textDirection = Directionality.of(context);
    final painter = TextPainter(
      textDirection: textDirection,
      text: TextSpan(
        children: [
          TextSpan(text: '88', style: digitStyle),
          TextSpan(text: 'h', style: unitStyle),
        ],
      ),
    )..layout();
    return painter.width.ceilToDouble() + 2;
  }
}

class _TimingLabelText extends StatelessWidget {
  const _TimingLabelText({
    required this.label,
    required this.digitStyle,
    required this.unitStyle,
  });

  final _TimingLabel label;
  final TextStyle? digitStyle;
  final TextStyle? unitStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _line(label.firstLine),
        if (label.secondLine != null) ...[
          const SizedBox(height: 1),
          _line(label.secondLine!),
        ],
      ],
    );
  }

  Widget _line(_TimingLine line) {
    return Text.rich(
      TextSpan(
        children: [
          if (line.value.isNotEmpty)
            TextSpan(text: line.value, style: digitStyle),
          if (line.unit.isNotEmpty) TextSpan(text: line.unit, style: unitStyle),
        ],
      ),
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.visible,
      textAlign: TextAlign.right,
    );
  }
}

class _TimingLabel {
  const _TimingLabel.single(_TimingLine line)
    : firstLine = line,
      secondLine = null;

  const _TimingLabel.twoLines({
    required this.firstLine,
    required this.secondLine,
  });

  final _TimingLine firstLine;
  final _TimingLine? secondLine;
}

class _TimingLine {
  const _TimingLine({this.value = '', this.unit = ''});

  final String value;
  final String unit;
}

class _PulsingTimelineDot extends StatefulWidget {
  const _PulsingTimelineDot({required this.color});

  final Color color;

  @override
  State<_PulsingTimelineDot> createState() => _PulsingTimelineDotState();
}

class _PulsingTimelineDotState extends State<_PulsingTimelineDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = 0.15 + (_controller.value * 0.55);
        final scale = 1 + (_controller.value * 0.12);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: widget.color, width: 2.2),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: pulse),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
