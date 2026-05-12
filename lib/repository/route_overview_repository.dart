import 'package:flymap/data/api/route_overview_api.dart';
import 'package:flymap/data/mappers/route_overview_api_mapper.dart';
import 'package:flymap/domain/entity/airport.dart';
import 'package:flymap/domain/entity/route_overview.dart';

abstract interface class RouteOverviewRepository {
  Future<RouteOverview> getRouteOverview({
    required Airport departure,
    required Airport arrival,
    required int placesLimit,
    required int regionsLimit,
  });

  RouteOverview mapRouteOverviewPayload(
    Map<String, dynamic> payload, {
    required Airport departure,
    required Airport arrival,
  });
}

class ApiRouteOverviewRepository implements RouteOverviewRepository {
  ApiRouteOverviewRepository({
    required RouteOverviewApi api,
    required RouteOverviewApiMapper mapper,
  }) : _api = api,
       _mapper = mapper;

  final RouteOverviewApi _api;
  final RouteOverviewApiMapper _mapper;

  @override
  Future<RouteOverview> getRouteOverview({
    required Airport departure,
    required Airport arrival,
    required int placesLimit,
    required int regionsLimit,
  }) async {
    final payload = await _api.getRouteOverview(
      departure: departure,
      arrival: arrival,
      placesLimit: placesLimit,
      regionsLimit: regionsLimit,
    );
    return _mapper.toRouteOverview(
      payload,
      departure: departure,
      arrival: arrival,
    );
  }

  @override
  RouteOverview mapRouteOverviewPayload(
    Map<String, dynamic> payload, {
    required Airport departure,
    required Airport arrival,
  }) {
    return _mapper.toRouteOverview(
      payload,
      departure: departure,
      arrival: arrival,
    );
  }
}
