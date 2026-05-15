enum FlightPhase {
  taxi,
  groundRoll,
  takeoffRoll,
  landingRoll,
  ascending,
  cruising,
  descending,
}

class FlightPhasePolicy {
  const FlightPhasePolicy._();

  static const double minAirborneSpeedKmh = 160;
  // GPS altitude is MSL; keep runway detection available at high-elevation
  // airports (e.g. Denver, Mexico City, Lhasa) by using a permissive ceiling.
  static const double maxRunwayAltitudeMeters = 4500;
  static const double taxiMaxSpeedKmh = 40;
  static const double minRunwayRollSpeedKmh = 30;
  static const double maxRunwayRollSpeedKmh = 200;
  static const double minRunwaySpeedDeltaKmh = 3;
  static const double minCruiseSpeedKmh = 450;
  static const double minCruiseAltitudeMeters = 3000;
  static const double minClimbDeltaMeters = 8;
  static const double minDescentDeltaMeters = 8;
  static const double maxLevelDeltaMeters = 4;

  static FlightPhase? classify({
    required double speedKmh,
    required double altitudeMeters,
    required double? speedDeltaKmh,
    required double? altitudeDeltaMeters,
  }) {
    final runwayPhase = _classifyRunwayPhase(
      speedKmh: speedKmh,
      altitudeMeters: altitudeMeters,
      speedDeltaKmh: speedDeltaKmh,
    );
    if (runwayPhase != null) {
      return runwayPhase;
    }

    if (speedKmh < minAirborneSpeedKmh || altitudeDeltaMeters == null) {
      return null;
    }

    if (altitudeDeltaMeters >= minClimbDeltaMeters) {
      return FlightPhase.ascending;
    }

    if (altitudeDeltaMeters <= -minDescentDeltaMeters) {
      return FlightPhase.descending;
    }

    final isLevel = altitudeDeltaMeters.abs() <= maxLevelDeltaMeters;
    final isCruiseLikely =
        speedKmh >= minCruiseSpeedKmh &&
        altitudeMeters >= minCruiseAltitudeMeters;
    if (isLevel && isCruiseLikely) {
      return FlightPhase.cruising;
    }

    return null;
  }

  static FlightPhase? _classifyRunwayPhase({
    required double speedKmh,
    required double altitudeMeters,
    required double? speedDeltaKmh,
  }) {
    if (altitudeMeters > maxRunwayAltitudeMeters) return null;

    if (speedKmh <= taxiMaxSpeedKmh) {
      return FlightPhase.taxi;
    }

    if (speedKmh < minRunwayRollSpeedKmh || speedKmh > maxRunwayRollSpeedKmh) {
      return null;
    }

    if (speedDeltaKmh == null) {
      return FlightPhase.groundRoll;
    }

    if (speedDeltaKmh >= minRunwaySpeedDeltaKmh) {
      return FlightPhase.takeoffRoll;
    }

    if (speedDeltaKmh <= -minRunwaySpeedDeltaKmh) {
      return FlightPhase.landingRoll;
    }

    return FlightPhase.groundRoll;
  }
}
