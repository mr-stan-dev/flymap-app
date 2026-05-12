import 'package:equatable/equatable.dart';
import 'package:flymap/domain/entity/flight_route.dart';
import 'package:flymap/domain/entity/flight_summary.dart';
import 'package:flymap/domain/entity/route_poi_summary.dart';
import 'package:flymap/domain/entity/route_timeline.dart';

class RouteOverview extends Equatable {
  const RouteOverview({
    required this.route,
    required this.topPois,
    required this.timeline,
    required this.flightInfo,
  });

  final FlightRoute route;
  final List<RoutePoiSummary> topPois;
  final RouteTimeline timeline;
  final FlightSummary? flightInfo;

  @override
  List<Object?> get props => [route, topPois, timeline, flightInfo];
}
