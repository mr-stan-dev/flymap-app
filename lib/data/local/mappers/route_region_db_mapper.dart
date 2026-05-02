import 'package:flymap/entity/route_region.dart';
import 'package:flymap/entity/route_region_type.dart';

import 'mapper_utils.dart';

class RouteRegionDbKeys {
  static const qid = 'qid';
  static const name = 'name';
  static const regionType = 'regionType';
  static const pathFirstEncounterKm = 'pathFirstEncounterKm';
  static const pathLengthInsideKm = 'pathLengthInsideKm';
  static const geometry = 'geometry';
  static const geometryType = 'type';
  static const geometryGeoJson = 'geoJson';
  static const wikidataQid = 'wikidataQid';
  static const fromAboveDescription = 'fromAboveDescription';
  static const wikipediaUrl = 'wikipediaUrl';
}

class RouteRegionDbMapper {
  RouteRegion? fromDb(Map<String, dynamic> map) {
    final qid = map.getString(RouteRegionDbKeys.qid);
    final name = map.getString(RouteRegionDbKeys.name);
    if (qid.isEmpty || name.isEmpty) return null;

    final geometryRaw = map.getMap(RouteRegionDbKeys.geometry);
    if (geometryRaw == null) return null;
    final geometryType = (geometryRaw[RouteRegionDbKeys.geometryType] ?? '')
        .toString()
        .trim();
    final geometryGeoJsonRaw = geometryRaw[RouteRegionDbKeys.geometryGeoJson];
    if (geometryType.isEmpty || geometryGeoJsonRaw is! Map) {
      return null;
    }
    final geometryGeoJson = geometryGeoJsonRaw.cast<String, dynamic>();

    return RouteRegion(
      qid: qid,
      name: name,
      regionType: RouteRegionType.fromApiValue(
        map.getString(RouteRegionDbKeys.regionType),
      ),
      pathFirstEncounterKm: map.getDouble(
        RouteRegionDbKeys.pathFirstEncounterKm,
      ),
      pathLengthInsideKm: map.getDouble(RouteRegionDbKeys.pathLengthInsideKm),
      geometry: RouteRegionGeometry(
        type: geometryType,
        geoJson: geometryGeoJson,
      ),
      wikidataQid: map.getString(RouteRegionDbKeys.wikidataQid).trim().isEmpty
          ? null
          : map.getString(RouteRegionDbKeys.wikidataQid),
      fromAboveDescription:
          map.getString(RouteRegionDbKeys.fromAboveDescription).trim().isEmpty
          ? null
          : map.getString(RouteRegionDbKeys.fromAboveDescription),
      wikipediaUrl: map.getString(RouteRegionDbKeys.wikipediaUrl).trim().isEmpty
          ? null
          : map.getString(RouteRegionDbKeys.wikipediaUrl),
    );
  }

  Map<String, dynamic> toDb(RouteRegion region) => <String, dynamic>{
    RouteRegionDbKeys.qid: region.qid,
    RouteRegionDbKeys.name: region.name,
    RouteRegionDbKeys.regionType: region.regionType.apiValue,
    RouteRegionDbKeys.pathFirstEncounterKm: region.pathFirstEncounterKm,
    RouteRegionDbKeys.pathLengthInsideKm: region.pathLengthInsideKm,
    RouteRegionDbKeys.geometry: {
      RouteRegionDbKeys.geometryType: region.geometry.type,
      RouteRegionDbKeys.geometryGeoJson: region.geometry.geoJson,
    },
    RouteRegionDbKeys.wikidataQid: region.wikidataQid ?? '',
    RouteRegionDbKeys.fromAboveDescription: region.fromAboveDescription ?? '',
    RouteRegionDbKeys.wikipediaUrl: region.wikipediaUrl ?? '',
  };
}
