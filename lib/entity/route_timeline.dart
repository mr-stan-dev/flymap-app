import 'package:equatable/equatable.dart';
import 'package:flymap/entity/route_region.dart';

class RouteTimeline extends Equatable {
  const RouteTimeline({
    required this.regions,
    required this.totalRouteMinutes,
    required this.cruiseSpeedKmh,
  });

  final List<RouteRegion> regions;
  final int totalRouteMinutes;
  final int cruiseSpeedKmh;

  const RouteTimeline.empty()
    : regions = const [],
      totalRouteMinutes = 0,
      cruiseSpeedKmh = 850;

  @override
  List<Object?> get props => [regions, totalRouteMinutes, cruiseSpeedKmh];
}
