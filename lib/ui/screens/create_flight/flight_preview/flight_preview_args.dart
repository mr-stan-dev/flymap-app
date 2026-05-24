import 'package:flymap/domain/entity/airport.dart';

class FlightPreviewArgs {
  const FlightPreviewArgs({
    required this.departure,
    required this.arrival,
    this.flightNumber,
    this.fr24Id,
    this.hasPendingFlightUnlock = false,
  });

  final Airport departure;
  final Airport arrival;
  final String? flightNumber;
  final String? fr24Id;
  final bool hasPendingFlightUnlock;
}
