import 'dart:math';

import 'package:flymap/domain/entity/flight_route.dart';
import 'package:latlong2/latlong.dart' as ll;

class CorridorEndpointPadding {
  const CorridorEndpointPadding._();

  static const double _kmPerDegLat = 110.574;
  static const double _kmPerDegLonEquator = 111.320;

  /// Builds optional circular endpoint caps around departure/arrival airports
  /// when they are too close to the current corridor edge.
  static List<List<ll.LatLng>> build(FlightRoute route) {
    if (route.corridor.length < 3) {
      return const [];
    }

    final targetRadiusKm = _targetRadiusKm(route.distanceInKm);
    final minAcceptableDistanceKm = targetRadiusKm * 0.72;
    final rings = <List<ll.LatLng>>[];

    final departureDistanceKm = _minDistanceToBoundaryKm(
      route.departure.latLon,
      route.corridor,
    );
    if (departureDistanceKm < minAcceptableDistanceKm) {
      rings.add(
        _buildCircleRing(
          center: route.departure.latLon,
          radiusKm: targetRadiusKm,
        ),
      );
    }

    final arrivalDistanceKm = _minDistanceToBoundaryKm(
      route.arrival.latLon,
      route.corridor,
    );
    if (arrivalDistanceKm < minAcceptableDistanceKm) {
      rings.add(
        _buildCircleRing(
          center: route.arrival.latLon,
          radiusKm: targetRadiusKm,
        ),
      );
    }

    return rings;
  }

  static double _targetRadiusKm(double routeDistanceKm) {
    if (!routeDistanceKm.isFinite || routeDistanceKm <= 0) {
      return 55.0;
    }
    return (routeDistanceKm * 0.04).clamp(35.0, 85.0);
  }

  static List<ll.LatLng> _buildCircleRing({
    required ll.LatLng center,
    required double radiusKm,
  }) {
    final points = <ll.LatLng>[];
    final latRad = center.latitude * (pi / 180.0);
    final cosLat = cos(latRad).abs().clamp(0.12, 1.0);
    final latRadiusDeg = radiusKm / _kmPerDegLat;
    final lonRadiusDeg = radiusKm / (_kmPerDegLonEquator * cosLat);

    const steps = 48;
    for (var i = 0; i <= steps; i++) {
      final angle = (2 * pi * i) / steps;
      final lat = (center.latitude + sin(angle) * latRadiusDeg).clamp(
        -89.9,
        89.9,
      );
      final lon = _normalizeLongitude(
        center.longitude + cos(angle) * lonRadiusDeg,
      );
      points.add(ll.LatLng(lat, lon));
    }
    return points;
  }

  static double _minDistanceToBoundaryKm(
    ll.LatLng point,
    List<ll.LatLng> corridor,
  ) {
    final ring = _ensureClosed(corridor);
    if (ring.length < 2) {
      return double.infinity;
    }

    var minDistanceKm = double.infinity;
    for (var i = 0; i < ring.length - 1; i++) {
      final distanceKm = _distancePointToSegmentKm(point, ring[i], ring[i + 1]);
      if (distanceKm < minDistanceKm) {
        minDistanceKm = distanceKm;
      }
    }
    return minDistanceKm;
  }

  static double _distancePointToSegmentKm(
    ll.LatLng point,
    ll.LatLng start,
    ll.LatLng end,
  ) {
    final refLatRad = point.latitude * (pi / 180.0);
    final cosRefLat = cos(refLatRad).abs().clamp(0.12, 1.0);

    final ax = 0.0;
    final ay = 0.0;
    final bx = _deltaLonKm(start.longitude, point.longitude, cosRefLat);
    final by = (start.latitude - point.latitude) * _kmPerDegLat;
    final cx = _deltaLonKm(end.longitude, point.longitude, cosRefLat);
    final cy = (end.latitude - point.latitude) * _kmPerDegLat;

    final abx = cx - bx;
    final aby = cy - by;
    final abLenSq = (abx * abx) + (aby * aby);
    if (abLenSq <= 1e-9) {
      return sqrt((bx * bx) + (by * by));
    }

    final t = ((ax - bx) * abx + (ay - by) * aby) / abLenSq;
    final clampedT = t.clamp(0.0, 1.0);
    final closestX = bx + abx * clampedT;
    final closestY = by + aby * clampedT;
    return sqrt((closestX * closestX) + (closestY * closestY));
  }

  static double _deltaLonKm(double lon, double referenceLon, double cosRefLat) {
    final deltaLonDeg = _normalizeLongitude(lon - referenceLon);
    return deltaLonDeg * _kmPerDegLonEquator * cosRefLat;
  }

  static List<ll.LatLng> _ensureClosed(List<ll.LatLng> ring) {
    if (ring.isEmpty) return const [];
    final first = ring.first;
    final last = ring.last;
    if ((first.latitude - last.latitude).abs() < 1e-9 &&
        (first.longitude - last.longitude).abs() < 1e-9) {
      return ring;
    }
    return [...ring, first];
  }

  static double _normalizeLongitude(double longitude) {
    var lon = longitude;
    while (lon > 180.0) {
      lon -= 360.0;
    }
    while (lon < -180.0) {
      lon += 360.0;
    }
    return lon;
  }
}
