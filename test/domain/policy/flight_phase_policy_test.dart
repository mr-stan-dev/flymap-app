import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/domain/policy/flight_phase_policy.dart';

void main() {
  group('FlightPhasePolicy', () {
    test('returns null while stationary even when altitude is stable', () {
      final phase = FlightPhasePolicy.classify(
        speedKmh: 0,
        altitudeMeters: 10000,
        speedDeltaKmh: 0,
        altitudeDeltaMeters: 0,
      );

      expect(phase, isNull);
    });

    test('returns null without a previous altitude sample', () {
      final phase = FlightPhasePolicy.classify(
        speedKmh: 850,
        altitudeMeters: 10000,
        speedDeltaKmh: 0,
        altitudeDeltaMeters: null,
      );

      expect(phase, isNull);
    });

    test('classifies ascending only with enough speed and climb delta', () {
      final phase = FlightPhasePolicy.classify(
        speedKmh: 320,
        altitudeMeters: 1800,
        speedDeltaKmh: 2,
        altitudeDeltaMeters: 12,
      );

      expect(phase, FlightPhase.ascending);
    });

    test('classifies descending only with enough speed and descent delta', () {
      final phase = FlightPhasePolicy.classify(
        speedKmh: 360,
        altitudeMeters: 2500,
        speedDeltaKmh: -2,
        altitudeDeltaMeters: -12,
      );

      expect(phase, FlightPhase.descending);
    });

    test('classifies cruising only when fast high and level', () {
      final phase = FlightPhasePolicy.classify(
        speedKmh: 840,
        altitudeMeters: 9750,
        speedDeltaKmh: 0,
        altitudeDeltaMeters: 2,
      );

      expect(phase, FlightPhase.cruising);
    });

    test('does not classify low-altitude level movement as cruising', () {
      final phase = FlightPhasePolicy.classify(
        speedKmh: 300,
        altitudeMeters: 600,
        speedDeltaKmh: 0,
        altitudeDeltaMeters: 1,
      );

      expect(phase, isNull);
    });

    test('classifies taxi at low altitude and low speed', () {
      final phase = FlightPhasePolicy.classify(
        speedKmh: 18,
        altitudeMeters: 15,
        speedDeltaKmh: 1.2,
        altitudeDeltaMeters: 0,
      );

      expect(phase, FlightPhase.taxi);
    });

    test('classifies takeoff roll on runway when accelerating', () {
      final phase = FlightPhasePolicy.classify(
        speedKmh: 140,
        altitudeMeters: 10,
        speedDeltaKmh: 6,
        altitudeDeltaMeters: 0,
      );

      expect(phase, FlightPhase.takeoffRoll);
    });

    test('classifies landing roll on runway when decelerating', () {
      final phase = FlightPhasePolicy.classify(
        speedKmh: 135,
        altitudeMeters: 12,
        speedDeltaKmh: -6,
        altitudeDeltaMeters: 0,
      );

      expect(phase, FlightPhase.landingRoll);
    });

    test('classifies ground roll on runway when speed delta is small', () {
      final phase = FlightPhasePolicy.classify(
        speedKmh: 120,
        altitudeMeters: 8,
        speedDeltaKmh: 1,
        altitudeDeltaMeters: 0,
      );

      expect(phase, FlightPhase.groundRoll);
    });

    test('does not classify runway phases when altitude is too high', () {
      final phase = FlightPhasePolicy.classify(
        speedKmh: 120,
        altitudeMeters: 400,
        speedDeltaKmh: 6,
        altitudeDeltaMeters: 0,
      );

      expect(phase, isNull);
    });
  });
}
