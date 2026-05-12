import 'package:flymap/domain/entity/airport.dart';

class FlightPreviewArgs {
  const FlightPreviewArgs({
    required this.departure,
    required this.arrival,
    this.flightNumber,
  });

  final Airport departure;
  final Airport arrival;
  final String? flightNumber;
}
