import 'package:flymap/domain/entity/airport.dart';

class FlightPreviewArgs {
  const FlightPreviewArgs({
    required this.departure,
    required this.arrival,
    this.flightNumber,
    this.hasPendingFlightUnlock = false,
  });

  final Airport departure;
  final Airport arrival;
  final String? flightNumber;
  final bool hasPendingFlightUnlock;
}
