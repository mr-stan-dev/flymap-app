import 'package:equatable/equatable.dart';
import 'package:flymap/domain/entity/flight_route.dart';
import 'package:flymap/domain/entity/route_poi_summary.dart';

class RoutePreview extends Equatable {
  const RoutePreview({required this.route, required this.topPois});

  final FlightRoute route;
  final List<RoutePoiSummary> topPois;

  @override
  List<Object?> get props => [route, topPois];
}
