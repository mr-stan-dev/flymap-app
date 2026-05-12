import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart' show LatLng;

class MapTile {
  final int z;
  final int x;
  final int y;
  MapTile(this.z, this.x, this.y);
}

/// Helpers for mapping between geographic coordinates and XYZ vector tiles.
///
/// All public entry points sanitize input into Web Mercator bounds first.
/// That keeps near-polar and edge-longitude inputs from producing invalid
/// tile rows/columns during route map downloads.
class TileUtils {
  static const double _webMercatorMaxLatitude = 85.05112878;
  static const double _maxLongitudeInclusive = 180.0;
  static const double _minLongitudeInclusive = -180.0;
  static const double _longitudeEpsilon = 1e-9;

  /// Converts a lat/lon point to an XYZ tile at [zoom].
  ///
  /// The input is clamped to valid Web Mercator bounds before projection, so
  /// callers can safely pass route geometry that reaches the poles or exactly
  /// `180` longitude.
  static MapTile xyzFromLatLon(LatLng latLon, int zoom) {
    final tileCount = 1 << zoom;
    final n = tileCount.toDouble();
    final sanitized = sanitizeLatLng(latLon);
    final xTile = (((sanitized.longitude + 180.0) / 360.0) * n).floor().clamp(
      0,
      tileCount - 1,
    );
    final mercatorY =
        (1 -
            math.log(
                  math.tan(sanitized.latitude * math.pi / 180.0) +
                      1 / math.cos(sanitized.latitude * math.pi / 180.0),
                ) /
                math.pi) /
        2;
    final yTile = (mercatorY * n).floor().clamp(0, tileCount - 1);
    return MapTile(zoom, xTile, yTile);
  }

  /// Yields tiles whose area intersects the given polygon at [zoom].
  ///
  /// The polygon is sanitized first; non-finite points are dropped and the
  /// remaining coordinates are clamped into Web Mercator bounds. If fewer than
  /// three valid points remain, there is no drawable polygon and the result is
  /// empty.
  static Iterable<MapTile> tilesForPolygon(
    List<LatLng> polygon,
    int zoom,
  ) sync* {
    final sanitizedPolygon = polygon
        .where((point) => point.latitude.isFinite && point.longitude.isFinite)
        .map(sanitizeLatLng)
        .toList(growable: false);
    if (sanitizedPolygon.length < 3) return;

    // Iterate over the polygon's tile bounding box, then keep only tiles whose
    // rectangle intersects the polygon. This is deliberately conservative: an
    // empty result near the poles is acceptable, but invalid tile coordinates
    // are not.
    double minLat = sanitizedPolygon.first.latitude;
    double maxLat = sanitizedPolygon.first.latitude;
    double minLon = sanitizedPolygon.first.longitude;
    double maxLon = sanitizedPolygon.first.longitude;
    for (final pnt in sanitizedPolygon) {
      if (pnt.latitude < minLat) minLat = pnt.latitude;
      if (pnt.latitude > maxLat) maxLat = pnt.latitude;
      if (pnt.longitude < minLon) minLon = pnt.longitude;
      if (pnt.longitude > maxLon) maxLon = pnt.longitude;
    }
    final topLeft = xyzFromLatLon(LatLng(maxLat, minLon), zoom);
    final bottomRight = xyzFromLatLon(LatLng(minLat, maxLon), zoom);
    int tileCount = 0;
    for (int x = topLeft.x; x <= bottomRight.x; x++) {
      final minY = math.min(topLeft.y, bottomRight.y);
      final maxY = math.max(topLeft.y, bottomRight.y);
      for (int y = minY; y <= maxY; y++) {
        final intersects = _tileIntersectsPolygon(x, y, zoom, sanitizedPolygon);
        if (intersects) {
          yield MapTile(zoom, x, y);
          tileCount++;
        }
      }
    }
    if (kDebugMode) {
      print('[VectorTilesDownloader] Zoom $zoom: $tileCount tiles selected');
    }
  }

  /// Clamps coordinates into the valid Web Mercator input range.
  ///
  /// Longitude is nudged slightly away from the inclusive `180` edge so tile
  /// projection still lands inside the last valid column.
  static LatLng sanitizeLatLng(LatLng point) {
    final lat = point.latitude.isFinite ? point.latitude : 0.0;
    final lon = point.longitude.isFinite ? point.longitude : 0.0;
    final clampedLat = lat.clamp(
      -_webMercatorMaxLatitude,
      _webMercatorMaxLatitude,
    );
    final clampedLon = lon.clamp(
      _minLongitudeInclusive,
      _maxLongitudeInclusive,
    );
    final adjustedLon = clampedLon >= _maxLongitudeInclusive
        ? _maxLongitudeInclusive - _longitudeEpsilon
        : clampedLon;
    return LatLng(clampedLat, adjustedLon);
  }

  /// Returns whether [tile] falls inside the valid XYZ range for its zoom.
  static bool isValidTile(MapTile tile) {
    if (tile.z < 0) return false;
    final tileCount = 1 << tile.z;
    return tile.x >= 0 &&
        tile.x < tileCount &&
        tile.y >= 0 &&
        tile.y < tileCount;
  }

  static LatLng latLonFromTileCenter(int x, int y, int z) {
    final n = math.pow(2, z).toDouble();
    final lonDeg = x / n * 360.0 - 180.0;
    final latRad = math.atan(_sinh(math.pi * (1 - 2 * y / n)));
    final latDeg = latRad * 180.0 / math.pi;
    return LatLng(latDeg, lonDeg);
  }

  static bool _pointInPolygon(LatLng point, List<LatLng> polygon) {
    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final xi = polygon[i].longitude;
      final yi = polygon[i].latitude;
      final xj = polygon[j].longitude;
      final yj = polygon[j].latitude;
      final intersect =
          ((yi > point.latitude) != (yj > point.latitude)) &&
          (point.longitude <
              (xj - xi) * (point.latitude - yi) / ((yj - yi) + 1e-12) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  static bool _tileIntersectsPolygon(int x, int y, int z, List<LatLng> poly) {
    // Tile rectangle in lat/lon.
    final n = math.pow(2, z).toDouble();
    final west = x / n * 360.0 - 180.0;
    final east = (x + 1) / n * 360.0 - 180.0;
    // Use adjacent tile centers to approximate the tile's north/south bounds.
    final northLat = latLonFromTileCenter(x, y, z).latitude;
    final southLat = latLonFromTileCenter(x, y + 1, z).latitude;

    // 1. Any polygon vertex inside rect?
    for (final p in poly) {
      if (p.longitude >= west &&
          p.longitude <= east &&
          p.latitude <= northLat &&
          p.latitude >= southLat) {
        return true;
      }
    }

    // 2. Any rect corner inside polygon?
    final corners = [
      LatLng(northLat, west),
      LatLng(northLat, east),
      LatLng(southLat, east),
      LatLng(southLat, west),
    ];
    for (final c in corners) {
      if (_pointInPolygon(c, poly)) return true;
    }

    // 3. Edge intersection
    for (int i = 0, j = poly.length - 1; i < poly.length; j = i++) {
      final p1 = poly[j];
      final p2 = poly[i];
      if (_lineIntersectsRect(p1, p2, west, east, southLat, northLat)) {
        return true;
      }
    }
    return false;
  }

  static bool _lineIntersectsRect(
    LatLng p1,
    LatLng p2,
    double west,
    double east,
    double south,
    double north,
  ) {
    // Liang–Barsky clipping like approach: check if segment intersects any of 4 edges.
    return _segmentsIntersect(
          p1,
          p2,
          LatLng(south, west),
          LatLng(south, east),
        ) || // south edge
        _segmentsIntersect(
          p1,
          p2,
          LatLng(north, west),
          LatLng(north, east),
        ) || // north
        _segmentsIntersect(
          p1,
          p2,
          LatLng(south, west),
          LatLng(north, west),
        ) || // west
        _segmentsIntersect(
          p1,
          p2,
          LatLng(south, east),
          LatLng(north, east),
        ); // east
  }

  static bool _segmentsIntersect(LatLng a1, LatLng a2, LatLng b1, LatLng b2) {
    double cross(double x1, double y1, double x2, double y2) =>
        x1 * y2 - y1 * x2;
    final d1x = a2.longitude - a1.longitude;
    final d1y = a2.latitude - a1.latitude;
    final d2x = b2.longitude - b1.longitude;
    final d2y = b2.latitude - b1.latitude;

    final delta = cross(d1x, d1y, d2x, d2y);
    if (delta.abs() < 1e-12) return false; // Parallel

    final s =
        cross(
          b1.longitude - a1.longitude,
          b1.latitude - a1.latitude,
          d2x,
          d2y,
        ) /
        delta;
    final t =
        cross(
          b1.longitude - a1.longitude,
          b1.latitude - a1.latitude,
          d1x,
          d1y,
        ) /
        delta;
    return s >= 0 && s <= 1 && t >= 0 && t <= 1;
  }
}

double _sinh(double x) => (math.exp(x) - math.exp(-x)) / 2;
