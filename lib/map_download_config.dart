import 'dart:math' as math;

import 'package:flymap/domain/entity/map_detail_level.dart';

/// Route length buckets used by map download zoom and sizing logic.
///
/// Ranges:
/// - [RouteLength.short]: `<= 2500 km`
/// - [RouteLength.mid]: `> 2500 km` and `<= 5000 km`
/// - [RouteLength.long]: `> 5000 km` and `<= 10000 km`
/// - [RouteLength.superLong]: `> 10000 km`
enum RouteLength {
  short(0),
  mid(2501),
  long(5001),
  superLong(10001);

  const RouteLength(this.minDistanceKm);

  final int minDistanceKm;
}

class MapDownloadConfig {
  MapDownloadConfig._();

  static const int wayPointDensityKm = 100;
  static const double shortCorridorWidthKm = 160.0;
  static const double midCorridorWidthKm = 240.0;
  static const double longCorridorWidthKm = 320.0;

  static const int minDownloadZoom = 0;
  static const int defaultWorkerCount = 6;
  static const int seaFilterMinZoom = 8;

  static const String mapLayerId = 'ofm_vector';
  static const String mbtilesDirectoryName = 'mbtiles';
  static const String planetPath = 'planet/20260304_001001_pt';
  static const String tilesPattern = '{z}/{x}/{y}.pbf';
  static const String flymapTiles =
      'https://tiles.flymap.app/$planetPath/$tilesPattern';
  static const String ofmTiles =
      'https://tiles.openfreemap.org/$planetPath/$tilesPattern';

  static const double fallbackDistanceKm = 1000.0;
  static const double estimatedMinMbPer1000Km = 30.0;
  static const double estimatedMaxMbPer1000Km = 50.0;
  static const double estimatedArticleMb = 0.5;

  static RouteLength resolveRouteLength(double distanceKm) {
    final bucketDistanceKm = distanceKm.isFinite ? distanceKm.ceil() : 0;
    return RouteLength.values.lastWhere(
      (routeLength) => bucketDistanceKm >= routeLength.minDistanceKm,
      orElse: () => RouteLength.short,
    );
  }

  static double resolveCorridorWidthKm(double distanceKm) {
    final midBoundaryKm = RouteLength.mid.minDistanceKm - 1;
    final longBoundaryKm = RouteLength.long.minDistanceKm - 1;
    if (distanceKm < midBoundaryKm) {
      return shortCorridorWidthKm;
    }
    if (distanceKm < longBoundaryKm) {
      return midCorridorWidthKm;
    }
    return longCorridorWidthKm;
  }

  static int resolveMaxZoom({
    required double distanceKm,
    required MapDetailLevel detailLevel,
  }) {
    final routeLength = resolveRouteLength(distanceKm);
    return switch (detailLevel) {
      MapDetailLevel.basic => switch (routeLength) {
        RouteLength.short => 10,
        RouteLength.mid => 9,
        RouteLength.long => 8,
        RouteLength.superLong => 7,
      },
      MapDetailLevel.pro => switch (routeLength) {
        RouteLength.short => 11,
        RouteLength.mid => 10,
        RouteLength.long => 9,
        RouteLength.superLong => 8,
      },
    };
  }

  static double zoomScaleForEstimate(int maxZoom) {
    return math.pow(2, maxZoom - 10).toDouble();
  }
}
