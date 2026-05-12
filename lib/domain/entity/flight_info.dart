import 'package:flymap/domain/entity/flight_article.dart';
import 'package:equatable/equatable.dart';
import 'package:flymap/domain/entity/flight_offline_content.dart';
import 'package:flymap/domain/entity/flight_route_metrics.dart';
import 'package:flymap/domain/entity/flight_route_insights.dart';
import 'package:flymap/domain/entity/route_poi_summary.dart';
import 'package:flymap/domain/entity/route_region.dart';

class FlightInfo extends Equatable {
  final FlightRouteInsights routeInsights;
  final FlightOfflineContent offlineContent;
  final FlightRouteMetrics routeMetrics;

  const FlightInfo(
    this.routeInsights,
    this.offlineContent, [
    this.routeMetrics = const FlightRouteMetrics(
      greatCircleDistanceKm: 0,
      approxDurationMinutes: 0,
    ),
  ]);

  static const FlightInfo empty = FlightInfo(
    FlightRouteInsights.empty,
    FlightOfflineContent.empty,
    FlightRouteMetrics(greatCircleDistanceKm: 0, approxDurationMinutes: 0),
  );

  String get overview => routeInsights.overview ?? '';
  List<RoutePoiSummary> get poi => routeInsights.poiHighlights;
  List<FlightArticle> get articles => offlineContent.articles;
  List<RouteRegion> get routeRegions => routeInsights.regions;
  int get routeTotalMinutes => routeMetrics.effectiveDurationMinutes;
  int get routeCruiseSpeedKmh =>
      routeMetrics.effectiveAverageSpeedKmh?.round() ??
      FlightRouteMetrics.defaultCruiseSpeedKmh;

  bool get isEmpty =>
      routeInsights.isEmpty && offlineContent.isEmpty && routeMetrics.isEmpty;

  FlightInfo copyWith({
    FlightRouteInsights? routeInsights,
    FlightOfflineContent? offlineContent,
    FlightRouteMetrics? routeMetrics,
    String? overview,
    List<RoutePoiSummary>? poi,
    List<FlightArticle>? articles,
    List<RouteRegion>? routeRegions,
    int? routeTotalMinutes,
    int? routeCruiseSpeedKmh,
  }) {
    final nextRouteInsights =
        routeInsights ??
        this.routeInsights.copyWith(
          overview: overview,
          poiHighlights: poi,
          regions: routeRegions,
        );
    final nextOfflineContent =
        offlineContent ?? this.offlineContent.copyWith(articles: articles);
    final nextRouteMetrics =
        routeMetrics ??
        _copyRouteMetrics(
          routeTotalMinutes: routeTotalMinutes,
          routeCruiseSpeedKmh: routeCruiseSpeedKmh,
        );
    return FlightInfo(nextRouteInsights, nextOfflineContent, nextRouteMetrics);
  }

  FlightRouteMetrics _copyRouteMetrics({
    int? routeTotalMinutes,
    int? routeCruiseSpeedKmh,
  }) {
    final nextDuration =
        routeTotalMinutes ?? routeMetrics.approxDurationMinutes;
    var nextDistance = routeMetrics.greatCircleDistanceKm;
    final speed = routeCruiseSpeedKmh;
    if (speed != null &&
        speed > 0 &&
        nextDuration > 0 &&
        (!nextDistance.isFinite || nextDistance <= 0)) {
      nextDistance = speed * (nextDuration / 60.0);
    }
    return routeMetrics.copyWith(
      greatCircleDistanceKm: nextDistance,
      approxDurationMinutes: routeTotalMinutes,
    );
  }

  @override
  List<Object?> get props => [routeInsights, offlineContent, routeMetrics];
}
