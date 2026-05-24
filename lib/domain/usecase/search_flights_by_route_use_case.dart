import 'package:flymap/domain/entity/flight_summary.dart';
import 'package:flymap/repository/flight_search_repository.dart';

class SearchFlightsByRouteUseCase {
  SearchFlightsByRouteUseCase({required FlightSearchRepository repository})
    : _repository = repository;

  final FlightSearchRepository _repository;

  Future<List<FlightSummary>> call({
    required String departureCode,
    required String arrivalCode,
  }) {
    return _repository.searchFlightsByRoute(
      departureCode: _normalizeCode(departureCode),
      arrivalCode: _normalizeCode(arrivalCode),
    );
  }

  String _normalizeCode(String raw) {
    return raw.trim().toUpperCase();
  }
}
