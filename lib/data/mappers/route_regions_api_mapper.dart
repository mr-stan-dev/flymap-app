import 'dart:math' as math;

import 'package:flymap/domain/entity/route_region.dart';
import 'package:flymap/domain/entity/flight_route_source.dart';
import 'package:flymap/domain/entity/route_timeline.dart';
import 'package:flymap/domain/entity/route_region_type.dart';
import 'package:flymap/domain/policy/flight_duration_estimate_policy.dart';
import 'package:flymap/domain/entity/flight_route_metrics.dart';

class RouteRegionsApiMapper {
  RouteTimeline toRouteTimeline(Map<String, dynamic> payload) {
    final metaRaw = payload['meta'];
    final regionsRaw = payload['regions'];
    final routeRaw = payload['route'];
    final routeMap = routeRaw is Map
        ? routeRaw.cast<String, dynamic>()
        : const <String, dynamic>{};
    final routeSource = FlightRouteSource.fromRaw(routeMap['source']);
    final metrics = _parseRouteMetrics(payload);

    final cruiseSpeedKmh =
        metrics.effectiveAverageSpeedKmh?.round() ??
        _toInt(metaRaw is Map ? metaRaw['cruiseSpeedKmh'] : null) ??
        FlightRouteMetrics.defaultCruiseSpeedKmh;

    final regions = <RouteRegion>[];
    if (regionsRaw is List) {
      for (final rRaw in regionsRaw) {
        final parsed = _parseRegion(rRaw);
        if (parsed != null) regions.add(parsed);
      }
    }

    final estimatedRouteDistanceKm = _estimateRouteDistanceKm(regions);
    final totalRouteMinutes =
        _primaryDurationMinutes(metrics, routeSource: routeSource) > 0
        ? _primaryDurationMinutes(metrics, routeSource: routeSource)
        : FlightDurationEstimatePolicy.normalizeTotalMinutes(
            apiTotalMinutes: _toInt(
              metaRaw is Map ? metaRaw['totalRouteMinutes'] : null,
            ),
            distanceKm: estimatedRouteDistanceKm,
            cruiseSpeedKmh: cruiseSpeedKmh,
            roundToMinutes: 5,
          );

    return RouteTimeline(
      regions: regions,
      totalRouteMinutes: totalRouteMinutes,
      cruiseSpeedKmh: cruiseSpeedKmh,
    );
  }

  int _primaryDurationMinutes(
    FlightRouteMetrics metrics, {
    required FlightRouteSource routeSource,
  }) {
    if (routeSource == FlightRouteSource.fr24Historical) {
      final rawMinutes =
          metrics.actualDurationMinutes ?? metrics.approxDurationMinutes;
      if (rawMinutes <= 0) return 0;
      return FlightRouteMetrics.roundDurationMinutesForDisplay(
        rawMinutes,
        isActual: metrics.actualDurationMinutes != null,
      );
    }
    final cruiseSpeedKmh =
        metrics.effectiveAverageSpeedKmh?.round() ??
        FlightRouteMetrics.defaultCruiseSpeedKmh;
    return FlightDurationEstimatePolicy.estimateTotalMinutes(
      distanceKm: metrics.greatCircleDistanceKm,
      cruiseSpeedKmh: cruiseSpeedKmh,
      roundToMinutes: 5,
    );
  }

  FlightRouteMetrics _parseRouteMetrics(Map<String, dynamic> payload) {
    final routeRaw = payload['route'];
    if (routeRaw is! Map) {
      return const FlightRouteMetrics(
        greatCircleDistanceKm: 0,
        approxDurationMinutes: 0,
      );
    }
    final route = routeRaw.cast<String, dynamic>();
    final metricsRaw = route['metrics'];
    final metrics = metricsRaw is Map
        ? metricsRaw.cast<String, dynamic>()
        : const <String, dynamic>{};
    final flightInfoRaw = payload['flightInfo'];
    final flightInfo = flightInfoRaw is Map
        ? flightInfoRaw.cast<String, dynamic>()
        : const <String, dynamic>{};
    final greatCircleDistanceKm =
        _toFiniteDouble(metrics['greatCircleDistanceKm']) ?? 0;
    return FlightRouteMetrics(
      greatCircleDistanceKm: greatCircleDistanceKm,
      approxDurationMinutes:
          _toInt(metrics['approxDurationMinutes']) ??
          FlightRouteMetrics.estimateApproxDurationMinutes(
            greatCircleDistanceKm,
          ),
      actualDistanceKm:
          _toFiniteDouble(metrics['actualDistanceKm']) ??
          _toFiniteDouble(flightInfo['actualDistanceKm']),
      actualDurationMinutes:
          _toInt(metrics['actualDurationMinutes']) ??
          _toInt(flightInfo['actualDurationMinutes']),
    );
  }

  RouteRegion? _parseRegion(dynamic regionRaw) {
    if (regionRaw is! Map) return null;
    final region = regionRaw.cast<String, dynamic>();
    final propsRaw = region['properties'];
    final geometryRaw = region['geometry'];
    if (propsRaw is! Map) return null;
    final props = propsRaw.cast<String, dynamic>();
    final geometry = _parseGeometry(geometryRaw);
    if (geometry == null) return null;
    final qid = (props['qid'] ?? props['regionId'] ?? '').toString().trim();
    final name = (props['name'] ?? '').toString().trim();
    final regionTypeRaw = (props['regionType'] ?? '').toString().trim();
    final wikidataQid = _normalizeWikidataQid(props['wikidataQid']);
    final fromAboveDescription = _toNonEmptyString(
      props['fromAboveDescription'],
    );
    final pathFirstEncounterKm = _toFiniteDouble(props['pathFirstEncounterKm']);
    final pathLengthInsideKm = _toFiniteDouble(props['pathLengthInsideKm']);
    final pathFirstEncounterMinutes = _toNonNegativeInt(
      props['pathFirstEncounterMinutes'],
    );
    if (qid.isEmpty ||
        name.isEmpty ||
        regionTypeRaw.isEmpty ||
        pathFirstEncounterKm == null ||
        pathLengthInsideKm == null) {
      return null;
    }

    return RouteRegion(
      qid: qid,
      name: name,
      regionType: RouteRegionType.fromApiValue(regionTypeRaw),
      pathFirstEncounterKm: pathFirstEncounterKm,
      pathLengthInsideKm: pathLengthInsideKm,
      geometry: geometry,
      pathFirstEncounterMinutes: pathFirstEncounterMinutes,
      wikidataQid: wikidataQid ?? _normalizeWikidataQid(qid),
      description: fromAboveDescription,
    );
  }

  RouteRegionGeometry? _parseGeometry(dynamic geometryRaw) {
    if (geometryRaw is! Map) return null;
    final geo = geometryRaw.cast<String, dynamic>();
    final type = (geo['type'] ?? '').toString().trim();
    if (type.isEmpty) return null;
    if (!geo.containsKey('coordinates') && !geo.containsKey('geometries')) {
      return null;
    }
    return RouteRegionGeometry(type: type, geoJson: geo);
  }

  double _estimateRouteDistanceKm(List<RouteRegion> regions) {
    if (regions.isEmpty) return 0;
    var maxEncounter = 0.0;
    for (final region in regions) {
      final regionEnd = region.pathFirstEncounterKm + region.pathLengthInsideKm;
      maxEncounter = math.max(maxEncounter, regionEnd);
    }
    return maxEncounter;
  }

  double? _toFiniteDouble(dynamic raw) {
    if (raw is num) {
      final value = raw.toDouble();
      return value.isFinite ? value : null;
    }
    if (raw is String) {
      final parsed = double.tryParse(raw);
      if (parsed == null || !parsed.isFinite) return null;
      return parsed;
    }
    return null;
  }

  int? _toInt(dynamic raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  int? _toNonNegativeInt(dynamic raw) {
    final value = _toInt(raw);
    if (value == null || value < 0) return null;
    return value;
  }

  String? _toNonEmptyString(dynamic raw) {
    if (raw == null) return null;
    final value = raw.toString().trim();
    return value.isEmpty ? null : value;
  }

  String? _normalizeWikidataQid(dynamic raw) {
    final value = _toNonEmptyString(raw)?.toUpperCase();
    if (value == null) return null;
    final direct = RegExp(r'^Q\d+$').firstMatch(value);
    if (direct != null) return direct.group(0);
    final embedded = RegExp(r'Q\d+').firstMatch(value);
    return embedded?.group(0);
  }
}
