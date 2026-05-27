import 'dart:math';

import 'package:flymap/domain/entity/flight_route.dart';
import 'package:flymap/domain/entity/gps_data.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/day_night/route_sun_event_forecast.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/day_night/solar_position_calculator.dart';
import 'package:latlong2/latlong.dart' as ll;

class RouteSunEventForecastService {
  RouteSunEventForecastService({
    SolarPositionCalculator? solarPositionCalculator,
  }) : _solarPositionCalculator =
           solarPositionCalculator ?? SolarPositionCalculator();

  static const int _sampleStepMinutes = 5;
  static const int _maxDisplayEtaMinutes = 60;

  final SolarPositionCalculator _solarPositionCalculator;

  RouteSunEventForecast? compute({
    required FlightRoute route,
    required GpsData? gpsData,
    double? speedKmhOverride,
    DateTime? nowUtc,
  }) {
    final latitude = gpsData?.latitude;
    final longitude = gpsData?.longitude;
    final courseDegrees = gpsData?.course;
    if (latitude == null ||
        longitude == null ||
        courseDegrees == null ||
        !courseDegrees.isFinite) {
      return null;
    }

    final speedKmh = speedKmhOverride;
    if (speedKmh == null || !speedKmh.isFinite || speedKmh <= 0) {
      return null;
    }

    final now = (nowUtc ?? DateTime.now()).toUtc();
    final origin = ll.LatLng(latitude, longitude);
    final normalizedCourseDegrees = _normalizeBearing(courseDegrees);
    final currentElevation = _solarElevationAtPoint(
      point: origin,
      nowUtc: now,
      minutesAhead: 0,
    );
    if (currentElevation == null) {
      return null;
    }

    var previousMinutes = 0;
    var previousElevation = currentElevation;

    for (
      var nextMinutes = _sampleStepMinutes;
      nextMinutes <= _maxDisplayEtaMinutes;
      nextMinutes += _sampleStepMinutes
    ) {
      final nextElevation = _solarElevationAtMinutesAhead(
        origin: origin,
        courseDegrees: normalizedCourseDegrees,
        nowUtc: now,
        minutesAhead: nextMinutes,
        speedKmh: speedKmh,
      );
      if (nextElevation == null) {
        continue;
      }

      final eventType = _crossingType(previousElevation, nextElevation);
      if (eventType != null) {
        final refinedMinutes = _refineCrossingMinute(
          origin: origin,
          courseDegrees: normalizedCourseDegrees,
          nowUtc: now,
          speedKmh: speedKmh,
          lowerMinutes: previousMinutes,
          upperMinutes: nextMinutes,
          previousElevation: previousElevation,
        );
        final etaMinutes = max(1, refinedMinutes);
        return RouteSunEventForecast(
          type: eventType,
          eta: Duration(minutes: etaMinutes),
          eventTimeUtc: now.add(Duration(minutes: etaMinutes)),
        );
      }

      previousMinutes = nextMinutes;
      previousElevation = nextElevation;
    }

    return null;
  }

  RouteSunEventType? _crossingType(
    double previousElevation,
    double nextElevation,
  ) {
    final threshold = SolarPositionCalculator.sunriseSunsetThresholdDegrees;
    final wasNight = previousElevation <= threshold;
    final isNight = nextElevation <= threshold;
    if (wasNight == isNight) {
      return null;
    }
    return wasNight ? RouteSunEventType.sunrise : RouteSunEventType.sunset;
  }

  int _refineCrossingMinute({
    required ll.LatLng origin,
    required double courseDegrees,
    required DateTime nowUtc,
    required double speedKmh,
    required int lowerMinutes,
    required int upperMinutes,
    required double previousElevation,
  }) {
    var previous = previousElevation;
    for (var minute = lowerMinutes + 1; minute <= upperMinutes; minute++) {
      final elevation = _solarElevationAtMinutesAhead(
        origin: origin,
        courseDegrees: courseDegrees,
        nowUtc: nowUtc,
        minutesAhead: minute,
        speedKmh: speedKmh,
      );
      if (elevation == null) {
        continue;
      }
      if (_crossingType(previous, elevation) != null) {
        return minute;
      }
      previous = elevation;
    }
    return upperMinutes;
  }

  double? _solarElevationAtMinutesAhead({
    required ll.LatLng origin,
    required double courseDegrees,
    required DateTime nowUtc,
    required int minutesAhead,
    required double speedKmh,
  }) {
    final distanceKm = speedKmh * minutesAhead / 60;
    final point = _pointAhead(
      origin: origin,
      bearingDegrees: courseDegrees,
      distanceKm: distanceKm,
    );
    return _solarElevationAtPoint(
      point: point,
      nowUtc: nowUtc,
      minutesAhead: minutesAhead,
    );
  }

  double? _solarElevationAtPoint({
    required ll.LatLng point,
    required DateTime nowUtc,
    required int minutesAhead,
  }) {
    return _solarPositionCalculator.solarElevationDegrees(
      dateTimeUtc: nowUtc.add(Duration(minutes: minutesAhead)),
      latitude: point.latitude,
      longitude: point.longitude,
    );
  }

  ll.LatLng _pointAhead({
    required ll.LatLng origin,
    required double bearingDegrees,
    required double distanceKm,
  }) {
    if (!distanceKm.isFinite || distanceKm <= 0) {
      return origin;
    }

    const earthRadiusKm = 6371.0;
    final angularDistance = distanceKm / earthRadiusKm;
    final bearingRad = _degToRad(bearingDegrees);
    final lat1 = _degToRad(origin.latitude);
    final lon1 = _degToRad(origin.longitude);

    final lat2 = asin(
      (sin(lat1) * cos(angularDistance)) +
          (cos(lat1) * sin(angularDistance) * cos(bearingRad)),
    );
    final lon2 =
        lon1 +
        atan2(
          sin(bearingRad) * sin(angularDistance) * cos(lat1),
          cos(angularDistance) - (sin(lat1) * sin(lat2)),
        );

    return ll.LatLng(_radToDeg(lat2), _normalizeLongitude(_radToDeg(lon2)));
  }

  double _normalizeBearing(double bearing) {
    var normalized = bearing % 360;
    if (normalized < 0) {
      normalized += 360;
    }
    return normalized;
  }

  double _normalizeLongitude(double longitude) {
    var normalized = longitude;
    while (normalized > 180) {
      normalized -= 360;
    }
    while (normalized < -180) {
      normalized += 360;
    }
    return normalized;
  }

  double _degToRad(double value) => value * (pi / 180);
  double _radToDeg(double value) => value * (180 / pi);
}
