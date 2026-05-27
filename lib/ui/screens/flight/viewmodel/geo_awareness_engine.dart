import 'package:equatable/equatable.dart';
import 'package:flymap/domain/entity/flight_route.dart';
import 'package:flymap/domain/entity/gps_data.dart';
import 'package:flymap/domain/entity/route_region.dart';
import 'package:flymap/domain/entity/route_region_geo_contains.dart';
import 'package:flymap/utils/route_progress_utils.dart';

class GeoAwarenessSnapshot extends Equatable {
  const GeoAwarenessSnapshot({
    this.currentRegionIds = const [],
    this.nextRegionId,
    this.nextRegionEtaMinutes,
    this.coveredDistanceKm = 0,
  });

  final List<String> currentRegionIds;
  final String? nextRegionId;
  final int? nextRegionEtaMinutes;
  final double coveredDistanceKm;

  @override
  List<Object?> get props => [
    currentRegionIds,
    nextRegionId,
    nextRegionEtaMinutes,
    coveredDistanceKm,
  ];
}

class GeoAwarenessEngine {
  const GeoAwarenessEngine();

  static const _maxNextRegionEtaMinutes = 180;
  static const _minNextRegionEtaSpeedKmh = 200.0;

  GeoAwarenessSnapshot compute({
    required FlightRoute route,
    required List<RouteRegion> routeRegions,
    required GpsData? gpsData,
    GeoAwarenessSnapshot? previous,
  }) {
    final lat = gpsData?.latitude;
    final lon = gpsData?.longitude;
    final hasLocation = lat != null && lon != null;
    final progress = RouteProgressUtils.sample(route: route, gpsData: gpsData);
    final coveredDistanceKm = hasLocation
        ? _resolvedCoveredDistanceKm(progress, previous)
        : (previous?.coveredDistanceKm ?? 0);

    final currentRegionIds = hasLocation
        ? _currentRegionIds(
            routeRegions: routeRegions,
            latitude: lat,
            longitude: lon,
          )
        : (previous?.currentRegionIds ?? const <String>[]);

    final nextRegionId = hasLocation
        ? _nextRegionId(
            routeRegions: routeRegions,
            currentRegionIds: currentRegionIds,
            coveredDistanceKm: coveredDistanceKm,
          )
        : (previous?.nextRegionId ??
              _nextRegionId(
                routeRegions: routeRegions,
                currentRegionIds: const [],
                coveredDistanceKm: coveredDistanceKm,
              ));

    final nextRegionEtaMinutes = _estimateNextRegionEtaMinutes(
      nextRegionId: nextRegionId,
      routeRegions: routeRegions,
      gpsData: gpsData,
      coveredDistanceKm: coveredDistanceKm,
      offRouteKm: progress.offRouteKm,
      hasProjectedProgress: progress.isProjected,
    );

    return GeoAwarenessSnapshot(
      currentRegionIds: currentRegionIds,
      nextRegionId: nextRegionId,
      nextRegionEtaMinutes: nextRegionEtaMinutes,
      coveredDistanceKm: coveredDistanceKm,
    );
  }

  double _resolvedCoveredDistanceKm(
    RouteProgressSample progress,
    GeoAwarenessSnapshot? previous,
  ) {
    final previousCoveredDistanceKm = previous?.coveredDistanceKm ?? 0;
    final currentCoveredDistanceKm = progress.coveredDistanceKm;
    if (!currentCoveredDistanceKm.isFinite) {
      return previousCoveredDistanceKm;
    }
    return currentCoveredDistanceKm > previousCoveredDistanceKm
        ? currentCoveredDistanceKm
        : previousCoveredDistanceKm;
  }

  List<String> _currentRegionIds({
    required List<RouteRegion> routeRegions,
    required double latitude,
    required double longitude,
  }) {
    final out = <RouteRegion>[];
    for (final region in routeRegions) {
      if (RouteRegionGeoContains.contains(
        region,
        latitude: latitude,
        longitude: longitude,
      )) {
        out.add(region);
      }
    }

    out.sort((a, b) => a.pathLengthInsideKm.compareTo(b.pathLengthInsideKm));
    return out.map((region) => region.qid).toList(growable: false);
  }

  String? _nextRegionId({
    required List<RouteRegion> routeRegions,
    required List<String> currentRegionIds,
    required double coveredDistanceKm,
  }) {
    if (routeRegions.isEmpty) return null;
    final sorted = List<RouteRegion>.from(
      routeRegions,
    )..sort((a, b) => a.pathFirstEncounterKm.compareTo(b.pathFirstEncounterKm));

    if (currentRegionIds.isEmpty) {
      return _firstRegionAfterDistance(
        sorted,
        coveredDistanceKm: coveredDistanceKm,
      );
    }

    final currentSet = currentRegionIds.toSet();
    return _firstRegionAfterDistance(
      sorted,
      coveredDistanceKm: coveredDistanceKm,
      excludeIds: currentSet,
    );
  }

  String? _firstRegionAfterDistance(
    List<RouteRegion> sortedRegions, {
    required double coveredDistanceKm,
    Set<String> excludeIds = const {},
  }) {
    for (final region in sortedRegions) {
      if (excludeIds.contains(region.qid)) continue;
      if (region.pathFirstEncounterKm > coveredDistanceKm) {
        return region.qid;
      }
    }
    return null;
  }

  int? _estimateNextRegionEtaMinutes({
    required String? nextRegionId,
    required List<RouteRegion> routeRegions,
    required GpsData? gpsData,
    required double coveredDistanceKm,
    required double offRouteKm,
    required bool hasProjectedProgress,
  }) {
    if (nextRegionId == null || nextRegionId.isEmpty) return null;
    RouteRegion? nextRegion;
    for (final region in routeRegions) {
      if (region.qid == nextRegionId) {
        nextRegion = region;
        break;
      }
    }
    if (nextRegion == null) return null;

    final speedKmh = _speedKmhFromGps(gpsData);
    if (speedKmh == null ||
        !speedKmh.isFinite ||
        speedKmh < _minNextRegionEtaSpeedKmh ||
        !hasProjectedProgress) {
      return null;
    }

    final remainingDistanceKm =
        nextRegion.pathFirstEncounterKm - coveredDistanceKm;
    if (!remainingDistanceKm.isFinite || remainingDistanceKm <= 0) {
      return null;
    }

    final adjustedDistanceKm = remainingDistanceKm + offRouteKm;
    final rawMinutes = (adjustedDistanceKm / speedKmh) * 60.0;
    if (!rawMinutes.isFinite || rawMinutes > _maxNextRegionEtaMinutes) {
      return null;
    }
    return rawMinutes.round().clamp(0, _maxNextRegionEtaMinutes);
  }

  double? _speedKmhFromGps(GpsData? gpsData) {
    final speed = gpsData?.speed;
    final value = speed?.value;
    if (value == null || !value.isFinite || value <= 0) {
      return null;
    }
    final unit = (speed?.unit ?? '').toLowerCase().trim();
    if (unit == 'km/h' || unit == 'kmh' || unit == 'kph') {
      return value;
    }
    if (unit == 'mph') {
      return value * 1.609344;
    }
    return null;
  }
}
