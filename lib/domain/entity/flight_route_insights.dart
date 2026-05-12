import 'package:equatable/equatable.dart';
import 'package:flymap/domain/entity/route_poi_summary.dart';
import 'package:flymap/domain/entity/route_region.dart';

class FlightRouteInsights extends Equatable {
  const FlightRouteInsights({
    this.overview,
    this.poiHighlights = const [],
    this.regions = const [],
  });

  static const FlightRouteInsights empty = FlightRouteInsights();

  final String? overview;
  final List<RoutePoiSummary> poiHighlights;
  final List<RouteRegion> regions;

  bool get isEmpty =>
      (overview == null || overview!.trim().isEmpty) &&
      poiHighlights.isEmpty &&
      regions.isEmpty;

  FlightRouteInsights copyWith({
    String? overview,
    bool clearOverview = false,
    List<RoutePoiSummary>? poiHighlights,
    List<RouteRegion>? regions,
  }) {
    return FlightRouteInsights(
      overview: clearOverview ? null : overview ?? this.overview,
      poiHighlights: poiHighlights ?? this.poiHighlights,
      regions: regions ?? this.regions,
    );
  }

  @override
  List<Object?> get props => [overview, poiHighlights, regions];
}
