import 'package:flymap/domain/entity/flight_route.dart';
import 'package:flymap/domain/entity/gps_data.dart';
import 'package:flymap/utils/route_progress_utils.dart';

class RouteProgressEstimator {
  RouteProgressEstimator._();

  static double estimateProgress({
    required FlightRoute route,
    required GpsData? gpsData,
  }) {
    return RouteProgressUtils.estimateProgress(route: route, gpsData: gpsData);
  }
}
