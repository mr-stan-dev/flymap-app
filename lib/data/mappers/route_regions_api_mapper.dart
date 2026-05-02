import 'package:flymap/entity/route_region.dart';
import 'package:flymap/entity/route_timeline.dart';
import 'package:flymap/entity/route_region_type.dart';

class RouteRegionsApiMapper {
  RouteTimeline toRouteTimeline(Map<String, dynamic> payload) {
    final metaRaw = payload['meta'];
    final regionsRaw = payload['regions'];

    final cruiseSpeedKmh =
        _toInt(metaRaw is Map ? metaRaw['cruiseSpeedKmh'] : null) ?? 850;

    final regions = <RouteRegion>[];
    if (regionsRaw is List) {
      for (final rRaw in regionsRaw) {
        final parsed = _parseRegion(rRaw);
        if (parsed != null) regions.add(parsed);
      }
    }

    final totalRouteMinutes =
        _toInt(metaRaw is Map ? metaRaw['totalRouteMinutes'] : null) ??
        _kmToMinutesFromRegionPath(
          regions.isEmpty ? 0 : regions.last.pathFirstEncounterKm,
          cruiseSpeedKmh: cruiseSpeedKmh,
        );

    return RouteTimeline(
      regions: regions,
      totalRouteMinutes: totalRouteMinutes,
      cruiseSpeedKmh: cruiseSpeedKmh,
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
    final qid = (props['regionId'] ?? props['qid'] ?? '').toString().trim();
    final name = (props['name'] ?? '').toString().trim();
    final regionTypeRaw = (props['regionType'] ?? '').toString().trim();
    final wikidataQid = _normalizeWikidataQid(
      props['wikidataQid'] ??
          props['wikidata_qid'] ??
          props['wikidata_id'] ??
          props['wikidataId'],
    );
    final fromAboveDescription = _toNonEmptyString(
      props['fromAboveDescription'] ?? props['from_above'],
    );
    final pathFirstEncounterKm = _toFiniteDouble(props['pathFirstEncounterKm']);
    final pathLengthInsideKm = _toFiniteDouble(props['pathLengthInsideKm']);
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
      wikidataQid: wikidataQid ?? _normalizeWikidataQid(qid),
      fromAboveDescription: fromAboveDescription,
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

  int _kmToMinutesFromRegionPath(
    double distanceKm, {
    required int cruiseSpeedKmh,
  }) {
    if (!distanceKm.isFinite || distanceKm <= 0 || cruiseSpeedKmh <= 0) {
      return 0;
    }
    return ((distanceKm * 60) / cruiseSpeedKmh).round();
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
