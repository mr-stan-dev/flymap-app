import 'package:flymap/domain/entity/flight_route.dart';
import 'package:flymap/domain/entity/gps_data.dart';
import 'package:flymap/ui/map/map_utils.dart';
import 'package:flymap/utils/route_path_sampler.dart';
import 'package:latlong2/latlong.dart';

class RouteProgressUtils {
  RouteProgressUtils._();

  static const betweenAirportsToleranceMultiplier = 1.3;

  static RouteProgressSample sample({
    required FlightRoute route,
    required GpsData? gpsData,
  }) {
    final lat = gpsData?.latitude;
    final lon = gpsData?.longitude;
    if (lat == null || lon == null) {
      return const RouteProgressSample(
        coveredDistanceKm: 0,
        offRouteKm: double.infinity,
        isProjected: false,
      );
    }

    final sampler = RoutePathSampler.fromFlightRoute(route);
    if (sampler.isValid && sampler.totalDistanceKm > 0) {
      final projection = sampler.projectPoint(LatLng(lat, lon));
      if (projection != null) {
        return RouteProgressSample(
          coveredDistanceKm: projection.distanceAlongRouteKm
              .clamp(0.0, sampler.totalDistanceKm)
              .toDouble(),
          offRouteKm: projection.offRouteKm,
          isProjected: true,
        );
      }
    }

    return RouteProgressSample(
      coveredDistanceKm:
          estimateProgress(route: route, gpsData: gpsData) * route.distanceInKm,
      offRouteKm: double.infinity,
      isProjected: false,
    );
  }

  static double estimateProgress({
    required FlightRoute route,
    required GpsData? gpsData,
  }) {
    final lat = gpsData?.latitude;
    final lon = gpsData?.longitude;
    if (lat == null || lon == null) return 0;

    final airportToAirportDistanceKm = route.distanceInKm;
    if (airportToAirportDistanceKm <= 0) return 0;

    final current = LatLng(lat, lon);
    final distanceToDepartureKm = MapUtils.distanceKm(
      departure: route.departure.latLon,
      arrival: current,
    );
    final distanceToArrivalKm = MapUtils.distanceKm(
      departure: current,
      arrival: route.arrival.latLon,
    );

    if (distanceToArrivalKm > airportToAirportDistanceKm) return 0;

    final span = distanceToDepartureKm + distanceToArrivalKm;
    if (span <= 0) return 0;
    final maxAllowedSpanKm =
        airportToAirportDistanceKm * betweenAirportsToleranceMultiplier;
    if (span > maxAllowedSpanKm) return 0;

    return (distanceToDepartureKm / span).clamp(0.0, 1.0);
  }

  static double coveredDistanceKm({
    required FlightRoute route,
    required GpsData? gpsData,
  }) {
    return sample(route: route, gpsData: gpsData).coveredDistanceKm;
  }
}

class RouteProgressSample {
  const RouteProgressSample({
    required this.coveredDistanceKm,
    required this.offRouteKm,
    required this.isProjected,
  });

  final double coveredDistanceKm;
  final double offRouteKm;
  final bool isProjected;
}
