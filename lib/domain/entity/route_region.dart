import 'package:equatable/equatable.dart';
import 'package:flymap/domain/entity/route_region_type.dart';

class RouteRegion extends Equatable {
  const RouteRegion({
    required this.qid,
    required this.name,
    required this.regionType,
    required this.pathFirstEncounterKm,
    required this.pathLengthInsideKm,
    required this.geometry,
    this.pathFirstEncounterMinutes,
    this.wikidataQid,
    this.description,
    this.wikipediaUrl,
  });

  final String qid;
  final String name;
  final RouteRegionType regionType;
  final double pathFirstEncounterKm;
  final double pathLengthInsideKm;
  final RouteRegionGeometry geometry;
  final int? pathFirstEncounterMinutes;
  final String? wikidataQid;
  final String? description;
  final String? wikipediaUrl;

  RouteRegion copyWith({
    String? qid,
    String? name,
    RouteRegionType? regionType,
    double? pathFirstEncounterKm,
    double? pathLengthInsideKm,
    RouteRegionGeometry? geometry,
    int? pathFirstEncounterMinutes,
    bool clearPathFirstEncounterMinutes = false,
    String? wikidataQid,
    bool clearWikidataQid = false,
    String? fromAboveDescription,
    bool clearFromAboveDescription = false,
    String? wikipediaUrl,
    bool clearWikipediaUrl = false,
  }) {
    return RouteRegion(
      qid: qid ?? this.qid,
      name: name ?? this.name,
      regionType: regionType ?? this.regionType,
      pathFirstEncounterKm: pathFirstEncounterKm ?? this.pathFirstEncounterKm,
      pathLengthInsideKm: pathLengthInsideKm ?? this.pathLengthInsideKm,
      geometry: geometry ?? this.geometry,
      pathFirstEncounterMinutes: clearPathFirstEncounterMinutes
          ? null
          : pathFirstEncounterMinutes ?? this.pathFirstEncounterMinutes,
      wikidataQid: clearWikidataQid ? null : wikidataQid ?? this.wikidataQid,
      description: clearFromAboveDescription
          ? null
          : fromAboveDescription ?? description,
      wikipediaUrl: clearWikipediaUrl
          ? null
          : wikipediaUrl ?? this.wikipediaUrl,
    );
  }

  @override
  List<Object?> get props => [
    qid,
    name,
    regionType,
    pathFirstEncounterKm,
    pathLengthInsideKm,
    geometry,
    pathFirstEncounterMinutes,
    wikidataQid,
    description,
    wikipediaUrl,
  ];
}
