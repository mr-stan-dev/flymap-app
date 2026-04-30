import 'package:flymap/entity/airport.dart';
import 'package:flymap/entity/route_preview.dart';
import 'package:flymap/repository/route_preview_repository.dart';

class GetRoutePreviewUseCase {
  GetRoutePreviewUseCase({required RoutePreviewRepository repository})
    : _repository = repository;

  static const int topPlacesLimit = 200;

  final RoutePreviewRepository _repository;

  Future<RoutePreview> call({
    required Airport departure,
    required Airport arrival,
  }) async {
    return await _repository.getRoutePreview(
      departure: departure,
      arrival: arrival,
      topPlacesLimit: topPlacesLimit,
    );
  }
}
