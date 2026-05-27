import 'dart:math';

import 'package:flymap/domain/entity/flight_route.dart';
import 'package:flymap/ui/map/map_utils.dart';
import 'package:latlong2/latlong.dart' as ll;

/// Samples and projects positions against the planned route polyline.
class RoutePathSampler {
  RoutePathSampler._(this.points, this._cumulativeDistancesKm);

  factory RoutePathSampler.fromFlightRoute(FlightRoute route) {
    final points = route.waypoints.length >= 2
        ? route.waypointLatLngs
        : <ll.LatLng>[route.departure.latLon, route.arrival.latLon];
    final cumulative = <double>[0];
    var total = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      total += MapUtils.distanceKm(
        departure: points[i],
        arrival: points[i + 1],
      );
      cumulative.add(total);
    }
    return RoutePathSampler._(points, cumulative);
  }

  final List<ll.LatLng> points;
  final List<double> _cumulativeDistancesKm;

  bool get isValid => points.length >= 2;

  double get totalDistanceKm =>
      _cumulativeDistancesKm.isEmpty ? 0 : _cumulativeDistancesKm.last;

  /// Returns the interpolated route point at a given distance from departure.
  ll.LatLng? pointAtDistanceKm(double targetKm) {
    if (!isValid) return null;
    if (targetKm <= 0) return points.first;
    if (targetKm >= totalDistanceKm) return points.last;

    for (var i = 0; i < points.length - 1; i++) {
      final startKm = _cumulativeDistancesKm[i];
      final endKm = _cumulativeDistancesKm[i + 1];
      final segmentKm = endKm - startKm;
      if (segmentKm <= 0) {
        continue;
      }
      if (targetKm > endKm) {
        continue;
      }

      final localT = ((targetKm - startKm) / segmentKm)
          .clamp(0.0, 1.0)
          .toDouble();
      final start = points[i];
      final end = points[i + 1];
      return ll.LatLng(
        start.latitude + (end.latitude - start.latitude) * localT,
        _interpolateLongitudeShortestPath(
          start.longitude,
          end.longitude,
          localT,
        ),
      );
    }
    return points.last;
  }

  RoutePathProjection? projectPoint(
    ll.LatLng point, {
    double maxOffRouteKm = 350,
  }) {
    if (!isValid) return null;

    // Snap to the closest route segment and report both along-route progress
    // and lateral deviation from the planned path.
    RoutePathProjection? bestProjection;
    for (var i = 0; i < points.length - 1; i++) {
      final start = points[i];
      final end = points[i + 1];
      final projected = _projectOntoSegment(
        point: point,
        start: start,
        end: end,
      );
      final segmentKm =
          _cumulativeDistancesKm[i + 1] - _cumulativeDistancesKm[i];
      final distanceAlongRouteKm =
          _cumulativeDistancesKm[i] + segmentKm * projected.fractionAlong;

      final candidate = RoutePathProjection(
        distanceAlongRouteKm: distanceAlongRouteKm,
        offRouteKm: projected.offRouteKm,
        closestPoint: projected.closestPoint,
      );

      if (bestProjection == null ||
          candidate.offRouteKm < bestProjection.offRouteKm) {
        bestProjection = candidate;
      }
    }

    if (bestProjection == null || bestProjection.offRouteKm > maxOffRouteKm) {
      return null;
    }
    return bestProjection;
  }

  _SegmentProjection _projectOntoSegment({
    required ll.LatLng point,
    required ll.LatLng start,
    required ll.LatLng end,
  }) {
    // Use a local planar approximation per segment; this keeps projection
    // math simple while remaining accurate enough for route-progress UI.
    final avgLatRadians =
        ((start.latitude + end.latitude) / 2) * 3.141592653589793 / 180;
    final xScale = cos(avgLatRadians);

    final startLon = _normalizeLongitude(start.longitude);
    final endLon = _unwrapLongitudeRelative(
      startLon,
      _normalizeLongitude(end.longitude),
    );
    final pointLon = _unwrapLongitudeRelative(
      startLon,
      _normalizeLongitude(point.longitude),
    );

    final ax = startLon * xScale;
    final ay = start.latitude;
    final bx = endLon * xScale;
    final by = end.latitude;
    final px = pointLon * xScale;
    final py = point.latitude;

    final abx = bx - ax;
    final aby = by - ay;
    final apx = px - ax;
    final apy = py - ay;
    final abSquared = abx * abx + aby * aby;
    final rawT = abSquared <= 1e-9 ? 0.0 : (apx * abx + apy * aby) / abSquared;
    final t = rawT.clamp(0.0, 1.0).toDouble();

    final closestX = ax + abx * t;
    final closestY = ay + aby * t;
    final closestPoint = ll.LatLng(
      closestY,
      _normalizeLongitude(closestX / xScale),
    );
    final offRouteKm = MapUtils.distanceKm(
      departure: point,
      arrival: closestPoint,
    );

    return _SegmentProjection(
      fractionAlong: t,
      offRouteKm: offRouteKm,
      closestPoint: closestPoint,
    );
  }

  double _interpolateLongitudeShortestPath(
    double fromLon,
    double toLon,
    double t,
  ) {
    var delta = _normalizeLongitude(toLon) - _normalizeLongitude(fromLon);
    if (delta > 180) {
      delta -= 360;
    } else if (delta < -180) {
      delta += 360;
    }
    return _normalizeLongitude(_normalizeLongitude(fromLon) + delta * t);
  }

  double _unwrapLongitudeRelative(double referenceLon, double targetLon) {
    var adjusted = targetLon;
    var delta = adjusted - referenceLon;
    if (delta > 180) {
      adjusted -= 360;
    } else if (delta < -180) {
      adjusted += 360;
    }
    return adjusted;
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

class RoutePathProjection {
  const RoutePathProjection({
    required this.distanceAlongRouteKm,
    required this.offRouteKm,
    required this.closestPoint,
  });

  final double distanceAlongRouteKm;
  final double offRouteKm;
  final ll.LatLng closestPoint;
}

class _SegmentProjection {
  const _SegmentProjection({
    required this.fractionAlong,
    required this.offRouteKm,
    required this.closestPoint,
  });

  final double fractionAlong;
  final double offRouteKm;
  final ll.LatLng closestPoint;
}
