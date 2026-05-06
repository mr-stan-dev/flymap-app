import 'package:flymap/data/api/route_places_api.dart';
import 'package:flymap/data/mappers/route_places_api_mapper.dart';
import 'package:flymap/domain/entity/airport.dart';
import 'package:flymap/domain/entity/route_preview.dart';
import 'package:flymap/logger.dart';

abstract interface class RoutePreviewRepository {
  Future<RoutePreview> getRoutePreview({
    required Airport departure,
    required Airport arrival,
    required int topPlacesLimit,
  });
}

class HybridRoutePreviewRepository implements RoutePreviewRepository {
  HybridRoutePreviewRepository({
    required RoutePlacesApi api,
    required RoutePlacesApiMapper mapper,
  }) : _api = api,
       _mapper = mapper;

  final RoutePlacesApi _api;
  final RoutePlacesApiMapper _mapper;
  final _logger = Logger('HybridRoutePreviewRepository');

  @override
  Future<RoutePreview> getRoutePreview({
    required Airport departure,
    required Airport arrival,
    required int topPlacesLimit,
  }) async {
    try {
      final response = await _api.getRoutePlaces(
        departure: departure,
        arrival: arrival,
        limit: topPlacesLimit,
      );
      final preview = _mapper.toRoutePreview(
        response,
        departure: departure,
        arrival: arrival,
      );
      _logger.log(
        'Route preview from backend waypoints=${preview.route.waypoints.length} corridor=${preview.route.corridor.length} pois=${preview.topPois.length}',
      );
      return preview;
    } catch (e) {
      _logger.error(
        'Route preview backend failed dep=${departure.primaryCode} arr=${arrival.primaryCode} error=$e',
      );
      rethrow;
    }
  }
}
