import 'package:equatable/equatable.dart';
import 'package:flymap/domain/entity/flight_route.dart';
import 'package:flymap/domain/entity/route_poi_summary.dart';
import 'package:flymap/domain/entity/route_timeline.dart';

class RouteOverview extends Equatable {
  const RouteOverview({
    required this.route,
    required this.topPois,
    required this.timeline,
  });

  final FlightRoute route;
  final List<RoutePoiSummary> topPois;
  final RouteTimeline timeline;

  @override
  List<Object?> get props => [route, topPois, timeline];
}
