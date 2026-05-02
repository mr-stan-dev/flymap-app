import 'package:flymap/entity/flight_article.dart';
import 'package:equatable/equatable.dart';
import 'package:flymap/entity/route_poi_summary.dart';
import 'package:flymap/entity/route_region.dart';

class FlightInfo extends Equatable {
  final String overview;
  final List<RoutePoiSummary> poi;
  final List<FlightArticle> articles;
  final List<RouteRegion> routeRegions;
  final int routeTotalMinutes;
  final int routeCruiseSpeedKmh;

  const FlightInfo(
    this.overview,
    this.poi, [
    this.articles = const [],
    this.routeRegions = const [],
    this.routeTotalMinutes = 0,
    this.routeCruiseSpeedKmh = 850,
  ]);

  static const FlightInfo empty = FlightInfo(
    '',
    <RoutePoiSummary>[],
    <FlightArticle>[],
    <RouteRegion>[],
    0,
    850,
  );
  bool get isEmpty =>
      overview.isEmpty &&
      poi.isEmpty &&
      articles.isEmpty &&
      routeRegions.isEmpty;

  FlightInfo copyWith({
    String? overview,
    List<RoutePoiSummary>? poi,
    List<FlightArticle>? articles,
    List<RouteRegion>? routeRegions,
    int? routeTotalMinutes,
    int? routeCruiseSpeedKmh,
  }) {
    return FlightInfo(
      overview ?? this.overview,
      poi ?? this.poi,
      articles ?? this.articles,
      routeRegions ?? this.routeRegions,
      routeTotalMinutes ?? this.routeTotalMinutes,
      routeCruiseSpeedKmh ?? this.routeCruiseSpeedKmh,
    );
  }

  @override
  List<Object?> get props => [
    overview,
    poi,
    articles,
    routeRegions,
    routeTotalMinutes,
    routeCruiseSpeedKmh,
  ];
}
