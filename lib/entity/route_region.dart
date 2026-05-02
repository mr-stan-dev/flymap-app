import 'package:equatable/equatable.dart';
import 'package:flymap/entity/route_region_type.dart';

class RouteRegion extends Equatable {
  const RouteRegion({
    required this.qid,
    required this.name,
    required this.regionType,
    required this.pathFirstEncounterKm,
    required this.pathLengthInsideKm,
    required this.geometry,
    this.wikidataQid,
    this.fromAboveDescription,
    this.wikipediaUrl,
  });

  final String qid;
  final String name;
  final RouteRegionType regionType;
  final double pathFirstEncounterKm;
  final double pathLengthInsideKm;
  final RouteRegionGeometry geometry;
  final String? wikidataQid;
  final String? fromAboveDescription;
  final String? wikipediaUrl;

  RouteRegion copyWith({
    String? qid,
    String? name,
    RouteRegionType? regionType,
    double? pathFirstEncounterKm,
    double? pathLengthInsideKm,
    RouteRegionGeometry? geometry,
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
      wikidataQid: clearWikidataQid ? null : wikidataQid ?? this.wikidataQid,
      fromAboveDescription: clearFromAboveDescription
          ? null
          : fromAboveDescription ?? this.fromAboveDescription,
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
    wikidataQid,
    fromAboveDescription,
    wikipediaUrl,
  ];
}
