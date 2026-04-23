import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/data/route/great_circle_route_provider.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('GreatCircleRouteProvider.calculateRoute', () {
    late GreatCircleRouteProvider provider;

    setUp(() {
      provider = GreatCircleRouteProvider();
    });

    test('returns only finite coordinates for very short routes', () {
      // Distance between these points is ~10 km which previously caused
      // segments to round to 0 and produced LatLng(NaN, NaN) points.
      const start = LatLng(52.2296, 21.0122);
      const end = LatLng(52.3000, 21.0200);

      final route = provider.calculateRoute(start, end);

      expect(route.length, greaterThanOrEqualTo(2));
      for (final point in route) {
        expect(point.latitude.isFinite, isTrue);
        expect(point.longitude.isFinite, isTrue);
      }
    });

    test('returns only finite coordinates when start equals end', () {
      const point = LatLng(40.0, -73.0);

      final route = provider.calculateRoute(point, point);

      for (final p in route) {
        expect(p.latitude.isFinite, isTrue);
        expect(p.longitude.isFinite, isTrue);
      }
    });

    test('still produces multiple waypoints for long routes', () {
      const start = LatLng(52.2296, 21.0122);
      const end = LatLng(40.7128, -74.0060);

      final route = provider.calculateRoute(start, end);

      expect(route.length, greaterThan(10));
      for (final point in route) {
        expect(point.latitude.isFinite, isTrue);
        expect(point.longitude.isFinite, isTrue);
      }
    });
  });
}
