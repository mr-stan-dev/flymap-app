import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/data/api/flight_info_api.dart';
import 'package:flymap/domain/entity/user_profile.dart';
import 'package:latlong2/latlong.dart';

void main() {
  test(
    'buildFlightInfoFunctionRequest includes user_preferences.interests',
    () {
      final request = buildFlightInfoFunctionRequest(
        airportDeparture: 'LHR',
        airportArrival: 'SFO',
        waypoints: const [LatLng(0, 0), LatLng(1, 1)],
        promptVersion: 2,
        interests: const [UsersInterests.regions, UsersInterests.volcanoes],
      );

      expect(request['user_preferences'], isA<Map<String, dynamic>>());
      expect(request['lang'], 'en');
      final prefs = request['user_preferences']! as Map<String, dynamic>;
      expect(prefs['interests'], ['Cities & regions', 'Volcanoes & geology']);
    },
  );

  test('buildFlightInfoFunctionRequest omits user_preferences when empty', () {
    final request = buildFlightInfoFunctionRequest(
      airportDeparture: 'LHR',
      airportArrival: 'SFO',
      waypoints: const [LatLng(0, 0), LatLng(1, 1)],
      promptVersion: 2,
      interests: const [],
    );

    expect(request.containsKey('user_preferences'), isFalse);
  });

  test(
    'buildFlightInfoFunctionRequest rounds waypoint coordinates to 2 decimals',
    () {
      final request = buildFlightInfoFunctionRequest(
        airportDeparture: 'LHR',
        airportArrival: 'SFO',
        waypoints: const [
          LatLng(51.470022, -0.454295),
          LatLng(37.621313, -122.378955),
        ],
        promptVersion: 3,
      );

      expect(request['waypoints'], [
        [51.47, -0.45],
        [37.62, -122.38],
      ]);
    },
  );

  test(
    'buildFlightInfoFunctionRequest samples dense routes to backend limit',
    () {
      final waypoints = List.generate(
        360,
        (index) => LatLng(index / 10, -index / 10),
      );

      final request = buildFlightInfoFunctionRequest(
        airportDeparture: 'SFO',
        airportArrival: 'PEK',
        waypoints: waypoints,
        promptVersion: 4,
      );

      final sampled = request['waypoints'] as List<dynamic>;
      expect(sampled, hasLength(flightInfoRequestMaxWaypoints));
      expect(sampled.first, [0.0, 0.0]);
      expect(sampled.last, [35.9, -35.9]);
    },
  );

  test(
    'buildFlightInfoFunctionRequest can clamp dense routes to 20 waypoints for wiki',
    () {
      final waypoints = List.generate(
        500,
        (index) => LatLng(index / 10, -index / 10),
      );

      final request = buildFlightInfoFunctionRequest(
        airportDeparture: 'SFO',
        airportArrival: 'PEK',
        waypoints: waypoints,
        promptVersion: 4,
        maxWaypoints: wikiArticlesRequestMaxWaypoints,
      );

      final sampled = request['waypoints'] as List<dynamic>;
      expect(sampled, hasLength(wikiArticlesRequestMaxWaypoints));
      expect(sampled.first, [0.0, 0.0]);
      expect(sampled.last, [49.9, -49.9]);
    },
  );
}
