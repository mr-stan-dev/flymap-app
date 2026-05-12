import 'package:flymap/domain/entity/flight_summary.dart';
import 'package:flymap/repository/flight_search_repository.dart';

class LookupFlightByNumberUseCase {
  LookupFlightByNumberUseCase({required FlightSearchRepository repository})
    : _repository = repository;

  final FlightSearchRepository _repository;

  Future<FlightSummary> call(String flightNumber) {
    return _repository.lookupFlightByNumber(flightNumber);
  }
}
