import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/domain/entity/flight_route_metrics.dart';

void main() {
  group('FlightRouteMetrics display rounding', () {
    test('rounds actual metrics for display', () {
      const metrics = FlightRouteMetrics(
        greatCircleDistanceKm: 10980,
        approxDurationMinutes: 810,
        actualDistanceKm: 11121,
        actualDurationMinutes: 823,
      );

      expect(metrics.displayDistanceKm, 11120);
      expect(metrics.displayDurationMinutes, 825);
    });

    test(
      'keeps approximate metrics unrounded beyond normal integer minutes',
      () {
        const metrics = FlightRouteMetrics(
          greatCircleDistanceKm: 347.4,
          approxDurationMinutes: 54,
        );

        expect(metrics.displayDistanceKm, 347);
        expect(metrics.displayDurationMinutes, 54);
      },
    );
  });
}
