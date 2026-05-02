import 'package:flymap/data/api/route_regions_api.dart';
import 'package:flymap/data/mappers/route_regions_api_mapper.dart';
import 'package:flymap/entity/airport.dart';
import 'package:flymap/entity/route_timeline.dart';

abstract interface class RouteTimelineRepository {
  Future<RouteTimeline> getRouteTimeline({
    required Airport departure,
    required Airport arrival,
    required int limit,
  });
}

class ApiRouteTimelineRepository implements RouteTimelineRepository {
  ApiRouteTimelineRepository({
    required RouteRegionsApi api,
    required RouteRegionsApiMapper mapper,
  }) : _api = api,
       _mapper = mapper;

  final RouteRegionsApi _api;
  final RouteRegionsApiMapper _mapper;

  @override
  Future<RouteTimeline> getRouteTimeline({
    required Airport departure,
    required Airport arrival,
    required int limit,
  }) async {
    final payload = await _api.getRouteRegions(
      departure: departure,
      arrival: arrival,
      limit: limit,
    );
    return _mapper.toRouteTimeline(payload);
  }
}
