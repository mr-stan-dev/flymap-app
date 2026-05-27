import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/domain/entity/airport.dart';
import 'package:flymap/domain/entity/flight_route.dart';
import 'package:flymap/domain/entity/flight_route_metrics.dart';
import 'package:flymap/domain/entity/flight_waypoint.dart';
import 'package:flymap/domain/entity/gps_data.dart';
import 'package:flymap/domain/entity/route_region.dart';
import 'package:flymap/domain/entity/route_region_type.dart';
import 'package:flymap/ui/screens/flight/viewmodel/geo_awareness_engine.dart';
import 'package:flymap/utils/route_progress_utils.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('GeoAwarenessEngine next-region ETA', () {
    const engine = GeoAwarenessEngine();
    final route = _buildRoute();
    final gpsWithSpeed = const GpsData(
      latitude: 0,
      longitude: 3,
      speed: SpeedValue(600, 'km/h'),
    );
    final gpsWithoutSpeed = const GpsData(latitude: 0, longitude: 3);
    final currentDistanceKm = RouteProgressUtils.coveredDistanceKm(
      route: route,
      gpsData: gpsWithSpeed,
    );
    final regions = [
      _buildRegion(pathFirstEncounterKm: currentDistanceKm + 200),
    ];

    test('uses live GPS speed to estimate next-region ETA', () {
      final snapshot = engine.compute(
        route: route,
        routeRegions: regions,
        gpsData: gpsWithSpeed,
      );

      expect(snapshot.nextRegionId, 'region-1');
      expect(snapshot.nextRegionEtaMinutes, 20);
    });

    test('hides next-region ETA when GPS speed is unavailable', () {
      final snapshot = engine.compute(
        route: route,
        routeRegions: regions,
        gpsData: gpsWithoutSpeed,
      );

      expect(snapshot.nextRegionId, 'region-1');
      expect(snapshot.nextRegionEtaMinutes, isNull);
    });

    test('hides next-region ETA when speed is below 200 km/h', () {
      final snapshot = engine.compute(
        route: route,
        routeRegions: regions,
        gpsData: const GpsData(
          latitude: 0,
          longitude: 3,
          speed: SpeedValue(199, 'km/h'),
        ),
      );

      expect(snapshot.nextRegionId, 'region-1');
      expect(snapshot.nextRegionEtaMinutes, isNull);
    });

    test('hides next-region ETA when computed time exceeds 3 hours', () {
      final snapshot = engine.compute(
        route: route,
        routeRegions: [
          _buildRegion(pathFirstEncounterKm: currentDistanceKm + 2000),
        ],
        gpsData: gpsWithSpeed,
      );

      expect(snapshot.nextRegionId, 'region-1');
      expect(snapshot.nextRegionEtaMinutes, isNull);
    });
  });
}

FlightRoute _buildRoute() {
  const departure = Airport(
    name: 'Origin Airport',
    city: 'Origin',
    countryCode: 'GB',
    latLon: LatLng(0, 0),
    iataCode: 'ORG',
    icaoCode: 'ORIG',
    wikipediaUrl: '',
  );
  const arrival = Airport(
    name: 'Arrival Airport',
    city: 'Arrival',
    countryCode: 'FR',
    latLon: LatLng(0, 10),
    iataCode: 'ARR',
    icaoCode: 'ARRI',
    wikipediaUrl: '',
  );

  return const FlightRoute(
    departure: departure,
    arrival: arrival,
    waypoints: [
      FlightWaypoint(latLon: LatLng(0, 0)),
      FlightWaypoint(latLon: LatLng(0, 10)),
    ],
    corridor: [LatLng(0, 0), LatLng(0, 10)],
    metrics: FlightRouteMetrics(
      greatCircleDistanceKm: 1111.95,
      approxDurationMinutes: 111,
    ),
  );
}

RouteRegion _buildRegion({required double pathFirstEncounterKm}) {
  return RouteRegion(
    qid: 'region-1',
    name: 'English Channel',
    regionType: RouteRegionType.channel,
    pathFirstEncounterKm: pathFirstEncounterKm,
    pathLengthInsideKm: 120,
    geometry: const RouteRegionGeometry(
      type: 'Polygon',
      geoJson: {
        'type': 'Polygon',
        'coordinates': [
          [
            [7.0, -1.0],
            [8.0, -1.0],
            [8.0, 1.0],
            [7.0, 1.0],
            [7.0, -1.0],
          ],
        ],
      },
    ),
  );
}
