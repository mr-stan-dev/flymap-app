import 'package:flymap/domain/entity/flight.dart';
import 'package:flymap/repository/flight_repository.dart';

class AutoCompleteStaleInProgressFlightsUseCase {
  AutoCompleteStaleInProgressFlightsUseCase({
    required FlightRepository repository,
  }) : _repository = repository;

  final FlightRepository _repository;

  Future<int> call({
    Duration maxInProgressAge = const Duration(hours: 24),
    DateTime? now,
  }) async {
    final flights = await _repository.getAllFlights();
    final timestamp = now ?? DateTime.now();
    var updatedCount = 0;

    for (final flight in flights) {
      if (flight.status != FlightStatus.inProgress) continue;
      final startedAt = flight.inProgressAt ?? flight.createdAt;
      if (timestamp.difference(startedAt) <= maxInProgressAge) continue;

      final updated = await _repository.updateFlightStatus(
        flightId: flight.id,
        status: FlightStatus.completed,
        completedAt: timestamp,
      );
      if (updated) {
        updatedCount++;
      }
    }
    return updatedCount;
  }
}
