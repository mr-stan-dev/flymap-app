import 'package:equatable/equatable.dart';

class FlightRouteMetrics extends Equatable {
  static const int defaultCruiseSpeedKmh = 850;

  const FlightRouteMetrics({
    required this.greatCircleDistanceKm,
    required this.approxDurationMinutes,
    this.actualDistanceKm,
    this.actualDurationMinutes,
  });

  factory FlightRouteMetrics.fromLegacyDistance(double distanceKm) {
    return FlightRouteMetrics(
      greatCircleDistanceKm: distanceKm,
      approxDurationMinutes: estimateApproxDurationMinutes(distanceKm),
    );
  }

  final double greatCircleDistanceKm;
  final int approxDurationMinutes;
  final double? actualDistanceKm;
  final int? actualDurationMinutes;

  bool get isEmpty =>
      (!greatCircleDistanceKm.isFinite || greatCircleDistanceKm <= 0) &&
      approxDurationMinutes <= 0 &&
      actualDistanceKm == null &&
      actualDurationMinutes == null;

  bool get hasActualTrack =>
      actualDistanceKm != null && actualDurationMinutes != null;

  double get effectiveDistanceKm =>
      _positiveFinite(actualDistanceKm) ?? greatCircleDistanceKm;

  int get effectiveDurationMinutes =>
      _positiveInt(actualDurationMinutes) ?? approxDurationMinutes;

  int get displayDistanceKm => roundDistanceKmForDisplay(
    effectiveDistanceKm,
    isActual: _positiveFinite(actualDistanceKm) != null,
  );

  int get displayDurationMinutes => roundDurationMinutesForDisplay(
    effectiveDurationMinutes,
    isActual: _positiveInt(actualDurationMinutes) != null,
  );

  double? get effectiveAverageSpeedKmh {
    final duration = effectiveDurationMinutes;
    final distance = effectiveDistanceKm;
    if (!distance.isFinite || distance <= 0 || duration <= 0) return null;
    return distance / (duration / 60.0);
  }

  FlightRouteMetrics copyWith({
    double? greatCircleDistanceKm,
    int? approxDurationMinutes,
    double? actualDistanceKm,
    bool clearActualDistanceKm = false,
    int? actualDurationMinutes,
    bool clearActualDurationMinutes = false,
  }) {
    return FlightRouteMetrics(
      greatCircleDistanceKm:
          greatCircleDistanceKm ?? this.greatCircleDistanceKm,
      approxDurationMinutes:
          approxDurationMinutes ?? this.approxDurationMinutes,
      actualDistanceKm: clearActualDistanceKm
          ? null
          : actualDistanceKm ?? this.actualDistanceKm,
      actualDurationMinutes: clearActualDurationMinutes
          ? null
          : actualDurationMinutes ?? this.actualDurationMinutes,
    );
  }

  static int estimateApproxDurationMinutes(double distanceKm) {
    if (!distanceKm.isFinite || distanceKm <= 0) return 0;
    final cruiseMinutes = (distanceKm * 60) / defaultCruiseSpeedKmh;
    return (cruiseMinutes / 5).round() * 5;
  }

  static int roundDistanceKmForDisplay(
    double distanceKm, {
    required bool isActual,
  }) {
    if (!distanceKm.isFinite || distanceKm <= 0) return 0;
    if (!isActual) return distanceKm.round();
    return ((distanceKm / 10).round() * 10).toInt();
  }

  static int roundDurationMinutesForDisplay(
    int minutes, {
    required bool isActual,
  }) {
    if (minutes <= 0) return 0;
    if (!isActual) return minutes;
    return (minutes / 5).round() * 5;
  }

  static double? _positiveFinite(double? value) {
    if (value == null || !value.isFinite || value <= 0) return null;
    return value;
  }

  static int? _positiveInt(int? value) {
    if (value == null || value <= 0) return null;
    return value;
  }

  @override
  List<Object?> get props => [
    greatCircleDistanceKm,
    approxDurationMinutes,
    actualDistanceKm,
    actualDurationMinutes,
  ];
}
