import 'package:flymap/domain/entity/airport.dart';
import 'package:flymap/domain/entity/flight_summary.dart';

sealed class FlightNumberSearchState {
  const FlightNumberSearchState();
}

class FlightNumberSearchInitial extends FlightNumberSearchState {
  const FlightNumberSearchInitial();
}

class FlightNumberSearchLoading extends FlightNumberSearchState {
  const FlightNumberSearchLoading();
}

class FlightNumberSearchSummaryLoaded extends FlightNumberSearchState {
  final FlightSummary summary;

  const FlightNumberSearchSummaryLoaded({required this.summary});
}

class FlightNumberSearchError extends FlightNumberSearchState {
  final String message;
  final FlightSummary? summary;

  const FlightNumberSearchError({required this.message, this.summary});
}

class FlightNumberSearchSuccess extends FlightNumberSearchState {
  final Airport departure;
  final Airport arrival;
  final String flightNumber;

  const FlightNumberSearchSuccess({
    required this.departure,
    required this.arrival,
    required this.flightNumber,
  });
}
