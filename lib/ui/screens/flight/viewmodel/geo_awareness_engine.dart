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
  });

  final List<String> currentRegionIds;
  final String? nextRegionId;
  final int? nextRegionEtaMinutes;

  @override
  List<Object?> get props => [
    currentRegionIds,
    nextRegionId,
    nextRegionEtaMinutes,
  ];
}

class GeoAwarenessEngine {
  const GeoAwarenessEngine();

  GeoAwarenessSnapshot compute({
    required FlightRoute route,
    required List<RouteRegion> routeRegions,
    required int cruiseSpeedKmh,
    required GpsData? gpsData,
    GeoAwarenessSnapshot? previous,
  }) {
    final lat = gpsData?.latitude;
    final lon = gpsData?.longitude;
    final hasLocation = lat != null && lon != null;

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
          )
        : (previous?.nextRegionId ??
              _nextRegionId(
                routeRegions: routeRegions,
                currentRegionIds: const [],
              ));

    final nextRegionEtaMinutes = _estimateNextRegionEtaMinutes(
      nextRegionId: nextRegionId,
      route: route,
      routeRegions: routeRegions,
      cruiseSpeedKmh: cruiseSpeedKmh,
      gpsData: gpsData,
    );

    return GeoAwarenessSnapshot(
      currentRegionIds: currentRegionIds,
      nextRegionId: nextRegionId,
      nextRegionEtaMinutes: nextRegionEtaMinutes,
    );
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
  }) {
    if (routeRegions.isEmpty) return null;
    final sorted = List<RouteRegion>.from(
      routeRegions,
    )..sort((a, b) => a.pathFirstEncounterKm.compareTo(b.pathFirstEncounterKm));

    if (currentRegionIds.isEmpty) {
      return sorted.first.qid;
    }

    final currentSet = currentRegionIds.toSet();
    var maxEncounterKm = double.negativeInfinity;
    for (final region in sorted) {
      if (currentSet.contains(region.qid) &&
          region.pathFirstEncounterKm > maxEncounterKm) {
        maxEncounterKm = region.pathFirstEncounterKm;
      }
    }
    if (!maxEncounterKm.isFinite) {
      maxEncounterKm = 0;
    }

    for (final region in sorted) {
      if (!currentSet.contains(region.qid) &&
          region.pathFirstEncounterKm > maxEncounterKm) {
        return region.qid;
      }
    }
    return null;
  }

  int? _estimateNextRegionEtaMinutes({
    required String? nextRegionId,
    required FlightRoute route,
    required List<RouteRegion> routeRegions,
    required int cruiseSpeedKmh,
    required GpsData? gpsData,
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

    final currentDistanceKm = RouteProgressUtils.coveredDistanceKm(
      route: route,
      gpsData: gpsData,
    );
    final remainingDistanceKm =
        nextRegion.pathFirstEncounterKm - currentDistanceKm;
    if (!remainingDistanceKm.isFinite || remainingDistanceKm <= 0) {
      return 0;
    }

    final speedKmh = _speedKmhFromGps(gpsData) ?? cruiseSpeedKmh.toDouble();
    if (!speedKmh.isFinite || speedKmh <= 0) return null;

    final rawMinutes = (remainingDistanceKm / speedKmh) * 60.0;
    return rawMinutes.isFinite ? rawMinutes.round().clamp(0, 99999) : null;
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
