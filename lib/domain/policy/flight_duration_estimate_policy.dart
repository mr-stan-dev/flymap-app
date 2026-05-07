import 'dart:math' as math;

class FlightDurationEstimatePolicy {
  const FlightDurationEstimatePolicy._();

  static const int _baseGroundAndPhaseMinutes = 25;
  static const int _minOverheadMinutes = 35;
  static const int _maxOverheadMinutes = 90;
  static const double _distanceOverheadMinutesPerKm = 0.02;

  static int estimateTotalMinutes({
    required double distanceKm,
    required int cruiseSpeedKmh,
    int roundToMinutes = 1,
  }) {
    if (!distanceKm.isFinite || distanceKm <= 0 || cruiseSpeedKmh <= 0) {
      return 0;
    }

    final cruiseMinutes = estimateCruiseMinutes(
      distanceKm: distanceKm,
      cruiseSpeedKmh: cruiseSpeedKmh,
      roundToMinutes: 1,
    );
    final overheadMinutesRaw =
        _baseGroundAndPhaseMinutes +
        (distanceKm * _distanceOverheadMinutesPerKm);
    final overheadMinutes = overheadMinutesRaw.round().clamp(
      _minOverheadMinutes,
      _maxOverheadMinutes,
    );
    final totalRaw = cruiseMinutes + overheadMinutes;

    if (roundToMinutes <= 1) {
      return totalRaw.round();
    }
    return ((totalRaw / roundToMinutes).round()) * roundToMinutes;
  }

  static int estimateCruiseMinutes({
    required double distanceKm,
    required int cruiseSpeedKmh,
    int roundToMinutes = 1,
  }) {
    if (!distanceKm.isFinite || distanceKm <= 0 || cruiseSpeedKmh <= 0) {
      return 0;
    }

    final raw = (distanceKm * 60) / cruiseSpeedKmh;
    if (roundToMinutes <= 1) {
      return raw.round();
    }
    return ((raw / roundToMinutes).round()) * roundToMinutes;
  }

  static int normalizeTotalMinutes({
    required int? apiTotalMinutes,
    required double distanceKm,
    required int cruiseSpeedKmh,
    int roundToMinutes = 1,
  }) {
    final estimated = estimateTotalMinutes(
      distanceKm: distanceKm,
      cruiseSpeedKmh: cruiseSpeedKmh,
      roundToMinutes: roundToMinutes,
    );
    final fromApi = (apiTotalMinutes ?? 0).clamp(0, 99999);
    return math.max(fromApi, estimated);
  }
}
