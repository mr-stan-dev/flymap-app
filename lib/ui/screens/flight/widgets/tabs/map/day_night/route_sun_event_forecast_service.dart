import 'dart:math';

import 'package:flymap/domain/entity/flight_route.dart';
import 'package:flymap/domain/entity/flight_route_metrics.dart';
import 'package:flymap/domain/entity/gps_data.dart';
import 'package:flymap/utils/route_path_sampler.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/day_night/route_sun_event_forecast.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/day_night/solar_position_calculator.dart';
import 'package:latlong2/latlong.dart' as ll;

class RouteSunEventForecastService {
  RouteSunEventForecastService({
    SolarPositionCalculator? solarPositionCalculator,
  }) : _solarPositionCalculator =
           solarPositionCalculator ?? SolarPositionCalculator();

  static const int _sampleStepMinutes = 5;

  final SolarPositionCalculator _solarPositionCalculator;

  RouteSunEventForecast? compute({
    required FlightRoute route,
    required GpsData? gpsData,
    double? speedKmhOverride,
    DateTime? nowUtc,
  }) {
    final latitude = gpsData?.latitude;
    final longitude = gpsData?.longitude;
    if (latitude == null || longitude == null) {
      return null;
    }

    final speedKmh =
        speedKmhOverride ??
        route.metrics.effectiveAverageSpeedKmh ??
        FlightRouteMetrics.defaultCruiseSpeedKmh.toDouble();
    if (!speedKmh.isFinite || speedKmh <= 0) {
      return null;
    }

    final sampler = RoutePathSampler.fromFlightRoute(route);
    if (!sampler.isValid || sampler.totalDistanceKm <= 0) {
      return null;
    }

    final projection = sampler.projectPoint(ll.LatLng(latitude, longitude));
    if (projection == null) {
      return null;
    }

    final currentDistanceKm = projection.distanceAlongRouteKm
        .clamp(0.0, sampler.totalDistanceKm)
        .toDouble();
    final remainingDistanceKm = sampler.totalDistanceKm - currentDistanceKm;
    if (remainingDistanceKm <= 0) {
      return null;
    }

    final now = (nowUtc ?? DateTime.now()).toUtc();
    final currentElevation = _solarElevationAtDistance(
      sampler: sampler,
      distanceKm: currentDistanceKm,
      nowUtc: now,
      minutesAhead: 0,
      speedKmh: speedKmh,
    );
    if (currentElevation == null) {
      return null;
    }

    final maxMinutes = (remainingDistanceKm / speedKmh * 60).floor();
    if (maxMinutes < 1) {
      return null;
    }

    var previousMinutes = 0;
    var previousElevation = currentElevation;

    for (
      var nextMinutes = _sampleStepMinutes;
      nextMinutes <= max(1, maxMinutes);
      nextMinutes += _sampleStepMinutes
    ) {
      final clampedNextMinutes = min(nextMinutes, maxMinutes);
      final nextElevation = _solarElevationAtDistance(
        sampler: sampler,
        distanceKm: currentDistanceKm,
        nowUtc: now,
        minutesAhead: clampedNextMinutes,
        speedKmh: speedKmh,
      );
      if (nextElevation == null) {
        continue;
      }

      final eventType = _crossingType(previousElevation, nextElevation);
      if (eventType != null) {
        final refinedMinutes = _refineCrossingMinute(
          sampler: sampler,
          currentDistanceKm: currentDistanceKm,
          nowUtc: now,
          speedKmh: speedKmh,
          lowerMinutes: previousMinutes,
          upperMinutes: clampedNextMinutes,
          previousElevation: previousElevation,
        );
        final etaMinutes = max(1, refinedMinutes);
        return RouteSunEventForecast(
          type: eventType,
          eta: Duration(minutes: etaMinutes),
          eventTimeUtc: now.add(Duration(minutes: etaMinutes)),
        );
      }

      if (clampedNextMinutes == maxMinutes) {
        break;
      }
      previousMinutes = clampedNextMinutes;
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
    required RoutePathSampler sampler,
    required double currentDistanceKm,
    required DateTime nowUtc,
    required double speedKmh,
    required int lowerMinutes,
    required int upperMinutes,
    required double previousElevation,
  }) {
    var previous = previousElevation;
    for (var minute = lowerMinutes + 1; minute <= upperMinutes; minute++) {
      final elevation = _solarElevationAtDistance(
        sampler: sampler,
        distanceKm: currentDistanceKm,
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

  double? _solarElevationAtDistance({
    required RoutePathSampler sampler,
    required double distanceKm,
    required DateTime nowUtc,
    required int minutesAhead,
    required double speedKmh,
  }) {
    final nextDistanceKm = min(
      sampler.totalDistanceKm,
      distanceKm + (speedKmh * minutesAhead / 60),
    );
    final point = sampler.pointAtDistanceKm(nextDistanceKm);
    if (point == null) {
      return null;
    }
    return _solarPositionCalculator.solarElevationDegrees(
      dateTimeUtc: nowUtc.add(Duration(minutes: minutesAhead)),
      latitude: point.latitude,
      longitude: point.longitude,
    );
  }
}
