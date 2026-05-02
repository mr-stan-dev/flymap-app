import 'package:flymap/data/mappers/route_places_api_mapper.dart';
import 'package:flymap/data/mappers/route_regions_api_mapper.dart';
import 'package:flymap/entity/airport.dart';
import 'package:flymap/entity/route_overview.dart';

class RouteOverviewApiMapper {
  RouteOverviewApiMapper({
    RoutePlacesApiMapper? placesMapper,
    RouteRegionsApiMapper? regionsMapper,
  }) : _placesMapper = placesMapper ?? RoutePlacesApiMapper(),
       _regionsMapper = regionsMapper ?? RouteRegionsApiMapper();

  final RoutePlacesApiMapper _placesMapper;
  final RouteRegionsApiMapper _regionsMapper;

  RouteOverview toRouteOverview(
    Map<String, dynamic> payload, {
    required Airport departure,
    required Airport arrival,
  }) {
    final preview = _placesMapper.toRoutePreview(
      payload,
      departure: departure,
      arrival: arrival,
    );
    final timeline = _regionsMapper.toRouteTimeline(payload);
    return RouteOverview(
      route: preview.route,
      topPois: preview.topPois,
      timeline: timeline,
    );
  }
}
