import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/domain/policy/flight_duration_estimate_policy.dart';

void main() {
  group('FlightDurationEstimatePolicy', () {
    test('estimateCruiseMinutes returns cruise-only duration', () {
      final minutes = FlightDurationEstimatePolicy.estimateCruiseMinutes(
        distanceKm: 920,
        cruiseSpeedKmh: 850,
        roundToMinutes: 5,
      );

      expect(minutes, 65);
    });

    test('estimateTotalMinutes includes non-cruise overhead', () {
      final minutes = FlightDurationEstimatePolicy.estimateTotalMinutes(
        distanceKm: 920,
        cruiseSpeedKmh: 850,
        roundToMinutes: 5,
      );

      expect(minutes, 110);
    });

    test('normalizeTotalMinutes floors low API values by estimate', () {
      final minutes = FlightDurationEstimatePolicy.normalizeTotalMinutes(
        apiTotalMinutes: 65,
        distanceKm: 920,
        cruiseSpeedKmh: 850,
        roundToMinutes: 5,
      );

      expect(minutes, 110);
    });

    test('normalizeTotalMinutes keeps higher API values', () {
      final minutes = FlightDurationEstimatePolicy.normalizeTotalMinutes(
        apiTotalMinutes: 140,
        distanceKm: 920,
        cruiseSpeedKmh: 850,
        roundToMinutes: 5,
      );

      expect(minutes, 140);
    });

    test('estimateTotalMinutes for long-haul reaches around 8h', () {
      final minutes = FlightDurationEstimatePolicy.estimateTotalMinutes(
        distanceKm: 5540,
        cruiseSpeedKmh: 850,
        roundToMinutes: 5,
      );

      expect(minutes, 480);
    });
  });
}
