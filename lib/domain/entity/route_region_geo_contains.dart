import 'package:flymap/domain/entity/route_region.dart';

class RouteRegionGeoContains {
  const RouteRegionGeoContains._();

  static bool contains(
    RouteRegion region, {
    required double latitude,
    required double longitude,
  }) {
    return _geoJsonContainsPoint(
      region.geometry.geoJson,
      latitude: latitude,
      longitude: longitude,
    );
  }

  static bool _geoJsonContainsPoint(
    dynamic geoJson, {
    required double latitude,
    required double longitude,
  }) {
    if (geoJson is! Map) return false;
    final type = (geoJson['type'] ?? '').toString().toLowerCase();
    switch (type) {
      case 'feature':
        return _geoJsonContainsPoint(
          geoJson['geometry'],
          latitude: latitude,
          longitude: longitude,
        );
      case 'featurecollection':
        final features = geoJson['features'];
        if (features is! List) return false;
        for (final feature in features) {
          if (_geoJsonContainsPoint(
            feature,
            latitude: latitude,
            longitude: longitude,
          )) {
            return true;
          }
        }
        return false;
      case 'geometrycollection':
        final geometries = geoJson['geometries'];
        if (geometries is! List) return false;
        for (final geometry in geometries) {
          if (_geoJsonContainsPoint(
            geometry,
            latitude: latitude,
            longitude: longitude,
          )) {
            return true;
          }
        }
        return false;
      case 'polygon':
        return _polygonContainsPoint(
          geoJson['coordinates'],
          latitude: latitude,
          longitude: longitude,
        );
      case 'multipolygon':
        final polygons = geoJson['coordinates'];
        if (polygons is! List) return false;
        for (final polygon in polygons) {
          if (_polygonContainsPoint(
            polygon,
            latitude: latitude,
            longitude: longitude,
          )) {
            return true;
          }
        }
        return false;
      default:
        return false;
    }
  }

  static bool _polygonContainsPoint(
    dynamic polygonCoords, {
    required double latitude,
    required double longitude,
  }) {
    if (polygonCoords is! List || polygonCoords.isEmpty) {
      return false;
    }
    final outerRing = polygonCoords.first;
    if (!_ringContainsPoint(
      outerRing,
      latitude: latitude,
      longitude: longitude,
    )) {
      return false;
    }
    for (var i = 1; i < polygonCoords.length; i++) {
      if (_ringContainsPoint(
        polygonCoords[i],
        latitude: latitude,
        longitude: longitude,
      )) {
        return false;
      }
    }
    return true;
  }

  static bool _ringContainsPoint(
    dynamic ringCoords, {
    required double latitude,
    required double longitude,
  }) {
    if (ringCoords is! List || ringCoords.length < 3) {
      return false;
    }
    final points = <List<double>>[];
    for (final coord in ringCoords) {
      final parsed = _parseLonLat(coord);
      if (parsed == null) continue;
      points.add(parsed);
    }
    if (points.length < 3) return false;

    const epsilon = 1e-9;
    for (var i = 0, j = points.length - 1; i < points.length; j = i++) {
      final x1 = points[j][0];
      final y1 = points[j][1];
      final x2 = points[i][0];
      final y2 = points[i][1];
      if (_pointOnSegment(
        longitude: longitude,
        latitude: latitude,
        x1: x1,
        y1: y1,
        x2: x2,
        y2: y2,
        epsilon: epsilon,
      )) {
        return true;
      }
    }

    var inside = false;
    for (var i = 0, j = points.length - 1; i < points.length; j = i++) {
      final xi = points[i][0];
      final yi = points[i][1];
      final xj = points[j][0];
      final yj = points[j][1];
      final intersects =
          ((yi > latitude) != (yj > latitude)) &&
          (longitude <
              ((xj - xi) * (latitude - yi)) / ((yj - yi) + epsilon) + xi);
      if (intersects) inside = !inside;
    }
    return inside;
  }

  static List<double>? _parseLonLat(dynamic rawCoord) {
    if (rawCoord is! List || rawCoord.length < 2) return null;
    final lon = rawCoord[0];
    final lat = rawCoord[1];
    if (lon is! num || lat is! num) return null;
    return [lon.toDouble(), lat.toDouble()];
  }

  static bool _pointOnSegment({
    required double longitude,
    required double latitude,
    required double x1,
    required double y1,
    required double x2,
    required double y2,
    required double epsilon,
  }) {
    final cross = (latitude - y1) * (x2 - x1) - (longitude - x1) * (y2 - y1);
    if (cross.abs() > epsilon) return false;
    final minX = x1 < x2 ? x1 : x2;
    final maxX = x1 > x2 ? x1 : x2;
    final minY = y1 < y2 ? y1 : y2;
    final maxY = y1 > y2 ? y1 : y2;
    return longitude >= minX - epsilon &&
        longitude <= maxX + epsilon &&
        latitude >= minY - epsilon &&
        latitude <= maxY + epsilon;
  }
}
