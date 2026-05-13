import 'dart:math' as math;

class OutsideTemperatureEstimate {
  const OutsideTemperatureEstimate({
    required this.celsius,
    required this.baseCelsius,
    required this.latitudeAdjustmentCelsius,
    required this.timeOfDayAdjustmentCelsius,
  });

  final double celsius;
  final double baseCelsius;
  final double latitudeAdjustmentCelsius;
  final double timeOfDayAdjustmentCelsius;
}

class OutsideTemperaturePolicy {
  const OutsideTemperaturePolicy._();
  static const double minReliableAltitudeMeters = 2000;

  static bool isAvailable({required double altitudeMeters}) =>
      altitudeMeters >= minReliableAltitudeMeters;

  static OutsideTemperatureEstimate estimate({
    required double altitudeMeters,
    double? latitude,
    double? longitude,
    DateTime? timestampUtc,
  }) {
    final normalizedAltitude = math.max(0.0, altitudeMeters);
    final base = _standardAtmosphereCelsius(normalizedAltitude);
    final lowAltitudeWeight = _lowAltitudeWeight(normalizedAltitude);
    final latitudeAdjustment =
        _latitudeAdjustmentCelsius(latitude) * lowAltitudeWeight;
    final timeAdjustment =
        _timeOfDayAdjustmentCelsius(
          longitude: longitude,
          timestampUtc: timestampUtc,
        ) *
        lowAltitudeWeight;
    final value = (base + latitudeAdjustment + timeAdjustment).clamp(
      -65.0,
      55.0,
    );

    return OutsideTemperatureEstimate(
      celsius: value,
      baseCelsius: base,
      latitudeAdjustmentCelsius: latitudeAdjustment,
      timeOfDayAdjustmentCelsius: timeAdjustment,
    );
  }

  static double _standardAtmosphereCelsius(double altitudeMeters) {
    final altitudeKm = altitudeMeters / 1000;
    if (altitudeMeters <= 11000) {
      return 15 - (6.5 * altitudeKm);
    }
    return -56.5;
  }

  static double _lowAltitudeWeight(double altitudeMeters) {
    if (altitudeMeters <= 2000) return 1;
    if (altitudeMeters >= 11000) return 0.12;
    final progress = (altitudeMeters - 2000) / 9000;
    return 1 - (progress * 0.88);
  }

  static double _latitudeAdjustmentCelsius(double? latitude) {
    if (latitude == null) return 0;
    final absoluteLatitude = latitude.abs().clamp(0.0, 90.0);
    return 6 - (absoluteLatitude / 90 * 20);
  }

  static double _timeOfDayAdjustmentCelsius({
    required double? longitude,
    required DateTime? timestampUtc,
  }) {
    if (longitude == null || timestampUtc == null) return 0;
    final utc = timestampUtc.toUtc();
    final utcHour =
        utc.hour +
        utc.minute / 60 +
        utc.second / 3600 +
        utc.millisecond / 3600000;
    final localSolarHour = (utcHour + longitude / 15) % 24;
    final normalizedHour = localSolarHour < 0
        ? localSolarHour + 24
        : localSolarHour;
    return math.cos((normalizedHour - 15) / 24 * 2 * math.pi) * 5;
  }
}
