import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/domain/policy/outside_temperature_policy.dart';

void main() {
  group('OutsideTemperaturePolicy', () {
    test('isAvailable gates estimates below 2000m', () {
      expect(
        OutsideTemperaturePolicy.isAvailable(altitudeMeters: 1999),
        isFalse,
      );
      expect(
        OutsideTemperaturePolicy.isAvailable(altitudeMeters: 2000),
        isTrue,
      );
    });

    test('keeps altitude as dominant factor at cruise altitude', () {
      final dayEquator = OutsideTemperaturePolicy.estimate(
        altitudeMeters: 11000,
        latitude: 0,
        longitude: 0,
        timestampUtc: DateTime.utc(2026, 5, 13, 15),
      );
      final nightPole = OutsideTemperaturePolicy.estimate(
        altitudeMeters: 11000,
        latitude: 80,
        longitude: 0,
        timestampUtc: DateTime.utc(2026, 5, 13, 3),
      );

      expect(dayEquator.celsius, closeTo(-55.2, 1.0));
      expect(nightPole.celsius, closeTo(-58.1, 1.0));
      expect((dayEquator.celsius - nightPole.celsius).abs(), lessThan(4));
    });

    test('applies stronger latitude and time adjustment at low altitude', () {
      final warmAfternoonEquator = OutsideTemperaturePolicy.estimate(
        altitudeMeters: 500,
        latitude: 0,
        longitude: 0,
        timestampUtc: DateTime.utc(2026, 5, 13, 15),
      );
      final coldNightHighLatitude = OutsideTemperaturePolicy.estimate(
        altitudeMeters: 500,
        latitude: 70,
        longitude: 0,
        timestampUtc: DateTime.utc(2026, 5, 13, 3),
      );

      expect(
        warmAfternoonEquator.celsius - coldNightHighLatitude.celsius,
        greaterThan(20),
      );
    });

    test('uses longitude to approximate local solar time', () {
      final localAfternoon = OutsideTemperaturePolicy.estimate(
        altitudeMeters: 0,
        latitude: 35,
        longitude: 45,
        timestampUtc: DateTime.utc(2026, 5, 13, 12),
      );
      final localNight = OutsideTemperaturePolicy.estimate(
        altitudeMeters: 0,
        latitude: 35,
        longitude: 45,
        timestampUtc: DateTime.utc(2026, 5, 13, 0),
      );

      expect(localAfternoon.celsius, greaterThan(localNight.celsius));
    });
  });
}
