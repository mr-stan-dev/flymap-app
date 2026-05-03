import 'package:flymap/entity/airport.dart';
import 'package:flymap/entity/route_region.dart';

enum RouteOverviewPageKind {
  summary,
  departure,
  region,
  arrival,
  summaryEnd,
}

class RouteOverviewPageEntry {
  const RouteOverviewPageEntry._({
    required this.kind,
    required this.minuteFromDeparture,
    this.airport,
    this.region,
  });

  final RouteOverviewPageKind kind;
  final int minuteFromDeparture;
  final Airport? airport;
  final RouteRegion? region;

  factory RouteOverviewPageEntry.summary() {
    return const RouteOverviewPageEntry._(
      kind: RouteOverviewPageKind.summary,
      minuteFromDeparture: 0,
    );
  }

  factory RouteOverviewPageEntry.departure(Airport airport) {
    return RouteOverviewPageEntry._(
      kind: RouteOverviewPageKind.departure,
      minuteFromDeparture: 0,
      airport: airport,
    );
  }

  factory RouteOverviewPageEntry.region(
    RouteRegion region, {
    required int minuteFromDeparture,
  }) {
    return RouteOverviewPageEntry._(
      kind: RouteOverviewPageKind.region,
      minuteFromDeparture: minuteFromDeparture,
      region: region,
    );
  }

  factory RouteOverviewPageEntry.arrival(
    Airport airport, {
    required int minuteFromDeparture,
  }) {
    return RouteOverviewPageEntry._(
      kind: RouteOverviewPageKind.arrival,
      minuteFromDeparture: minuteFromDeparture,
      airport: airport,
    );
  }

  factory RouteOverviewPageEntry.summaryEnd({
    required int minuteFromDeparture,
  }) {
    return RouteOverviewPageEntry._(
      kind: RouteOverviewPageKind.summaryEnd,
      minuteFromDeparture: minuteFromDeparture,
    );
  }
}
