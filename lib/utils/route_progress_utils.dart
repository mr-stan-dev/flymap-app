import 'package:flymap/entity/flight_route.dart';
import 'package:flymap/entity/gps_data.dart';
import 'package:flymap/ui/map/map_utils.dart';
import 'package:latlong2/latlong.dart';

class RouteProgressUtils {
  RouteProgressUtils._();

  static const betweenAirportsToleranceMultiplier = 1.3;

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
    final progress = estimateProgress(route: route, gpsData: gpsData);
    return (progress * route.distanceInKm).clamp(0.0, route.distanceInKm);
  }
}
