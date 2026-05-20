import 'dart:math';

class SolarPositionCalculator {
  static const double sunriseSunsetThresholdDegrees = -0.833;

  SolarPositionSnapshot snapshot(DateTime dateTimeUtc) {
    final utc = dateTimeUtc.toUtc();
    final dayOfYear = _dayOfYear(utc);
    final totalMinutes =
        utc.hour * 60 + utc.minute + utc.second / 60 + utc.millisecond / 60000;
    final gamma =
        (2 * pi / 365) * (dayOfYear - 1 + ((totalMinutes / 60) - 12) / 24);

    final equationOfTimeMinutes =
        229.18 *
        (0.000075 +
            0.001868 * cos(gamma) -
            0.032077 * sin(gamma) -
            0.014615 * cos(2 * gamma) -
            0.040849 * sin(2 * gamma));

    final declinationRadians =
        0.006918 -
        0.399912 * cos(gamma) +
        0.070257 * sin(gamma) -
        0.006758 * cos(2 * gamma) +
        0.000907 * sin(2 * gamma) -
        0.002697 * cos(3 * gamma) +
        0.00148 * sin(3 * gamma);

    final subsolarLongitudeDegrees = _normalizeLongitude(
      (720 - totalMinutes - equationOfTimeMinutes) / 4,
    );

    return SolarPositionSnapshot(
      declinationRadians: declinationRadians,
      equationOfTimeMinutes: equationOfTimeMinutes,
      subsolarLongitudeDegrees: subsolarLongitudeDegrees,
      totalUtcMinutes: totalMinutes,
    );
  }

  double solarElevationDegrees({
    required DateTime dateTimeUtc,
    required double latitude,
    required double longitude,
  }) {
    final snapshot = this.snapshot(dateTimeUtc);
    return solarElevationDegreesFromSnapshot(
      snapshot: snapshot,
      latitude: latitude,
      longitude: longitude,
    );
  }

  double solarElevationDegreesFromSnapshot({
    required SolarPositionSnapshot snapshot,
    required double latitude,
    required double longitude,
  }) {
    final latitudeRadians = latitude * pi / 180;
    final trueSolarTimeMinutes =
        snapshot.totalUtcMinutes +
        snapshot.equationOfTimeMinutes +
        4 * longitude;
    var hourAngleDegrees = (trueSolarTimeMinutes / 4) - 180;
    while (hourAngleDegrees < -180) {
      hourAngleDegrees += 360;
    }
    while (hourAngleDegrees > 180) {
      hourAngleDegrees -= 360;
    }
    final hourAngleRadians = hourAngleDegrees * pi / 180;

    final cosZenith =
        sin(latitudeRadians) * sin(snapshot.declinationRadians) +
        cos(latitudeRadians) *
            cos(snapshot.declinationRadians) *
            cos(hourAngleRadians);
    final clampedCosZenith = cosZenith.clamp(-1.0, 1.0);
    final zenithRadians = acos(clampedCosZenith);
    return 90 - (zenithRadians * 180 / pi);
  }

  int _dayOfYear(DateTime utc) {
    final start = DateTime.utc(utc.year, 1, 1);
    return utc.difference(start).inDays + 1;
  }

  double _normalizeLongitude(double longitude) {
    var lon = longitude;
    while (lon > 180) {
      lon -= 360;
    }
    while (lon < -180) {
      lon += 360;
    }
    return lon;
  }
}

class SolarPositionSnapshot {
  const SolarPositionSnapshot({
    required this.declinationRadians,
    required this.equationOfTimeMinutes,
    required this.subsolarLongitudeDegrees,
    required this.totalUtcMinutes,
  });

  final double declinationRadians;
  final double equationOfTimeMinutes;
  final double subsolarLongitudeDegrees;
  final double totalUtcMinutes;
}
