import 'package:flymap/domain/entity/airport.dart';
import 'package:flymap/domain/entity/route_timeline.dart';
import 'package:flymap/repository/route_timeline_repository.dart';

class GetRouteRegionsUseCase {
  GetRouteRegionsUseCase({required RouteTimelineRepository repository})
    : _repository = repository;

  static const int routeRegionsLimit = 50;

  final RouteTimelineRepository _repository;

  Future<RouteTimeline> call({
    required Airport departure,
    required Airport arrival,
  }) async {
    return await _repository.getRouteTimeline(
      departure: departure,
      arrival: arrival,
      limit: routeRegionsLimit,
    );
  }
}
