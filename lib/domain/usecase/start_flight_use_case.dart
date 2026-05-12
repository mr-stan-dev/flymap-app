import 'package:flymap/domain/entity/flight_status.dart';
import 'package:flymap/repository/flight_repository.dart';

class StartFlightUseCase {
  StartFlightUseCase({required FlightRepository repository})
    : _repository = repository;

  final FlightRepository _repository;

  Future<bool> call({required String flightId}) {
    return _repository.updateFlightStatus(
      flightId: flightId,
      status: FlightStatus.inProgress,
    );
  }
}
