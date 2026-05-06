import 'package:flymap/domain/entity/airport.dart';
import 'package:flymap/domain/entity/route_overview.dart';
import 'package:flymap/repository/route_overview_repository.dart';

class GetRouteOverviewUseCase {
  GetRouteOverviewUseCase({required RouteOverviewRepository repository})
    : _repository = repository;

  static const int placesLimit = 200;
  static const int regionsLimit = 50;

  final RouteOverviewRepository _repository;

  Future<RouteOverview> call({
    required Airport departure,
    required Airport arrival,
  }) async {
    return await _repository.getRouteOverview(
      departure: departure,
      arrival: arrival,
      placesLimit: placesLimit,
      regionsLimit: regionsLimit,
    );
  }
}
