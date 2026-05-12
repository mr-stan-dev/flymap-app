import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/domain/usecase/lookup_flight_by_number_use_case.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/repository/flight_search_repository.dart';

import 'flight_number_search_state.dart';

class FlightNumberSearchCubit extends Cubit<FlightNumberSearchState> {
  FlightNumberSearchCubit({
    required LookupFlightByNumberUseCase lookupFlightByNumberUseCase,
    required FlightSearchRepository flightSearchRepository,
  }) : _lookupFlightByNumberUseCase = lookupFlightByNumberUseCase,
       _flightSearchRepository = flightSearchRepository,
       super(const FlightNumberSearchInitial());

  final LookupFlightByNumberUseCase _lookupFlightByNumberUseCase;
  final FlightSearchRepository _flightSearchRepository;

  Future<void> loadFlightSummary(String flightNumber) async {
    final normalized = _normalize(flightNumber);
    if (normalized == null) return;

    emit(const FlightNumberSearchLoading());

    try {
      final summary = await _lookupFlightByNumberUseCase(normalized);
      final departure = await _flightSearchRepository.resolveAirport(
        code: summary.origIcao,
        fallbackName: 'Departure',
      );
      final arrival = await _flightSearchRepository.resolveAirport(
        code: summary.destIcao,
        fallbackName: 'Arrival',
      );

      final airlineName = await _flightSearchRepository
          .resolveAirlineNameByCode(summary.airlineCode);

      emit(
        FlightNumberSearchSummaryLoaded(
          summary: summary.copyWith(
            departure: departure,
            arrival: arrival,
            airlineName: airlineName ?? '',
          ),
        ),
      );
    } catch (_) {
      emit(
        FlightNumberSearchError(
          message: t.createFlight.flightNumberSearch.error,
        ),
      );
    }
  }

  Future<void> confirmSummaryAndLoadRoute({
    required String flightNumber,
  }) async {
    final normalized = _normalize(flightNumber);
    final currentState = state;
    if (normalized == null ||
        currentState is! FlightNumberSearchSummaryLoaded) {
      return;
    }

    emit(const FlightNumberSearchLoading());

    try {
      final departure = await _flightSearchRepository.resolveAirport(
        code: currentState.summary.origIcao,
        fallbackName: 'Departure',
      );
      final arrival = await _flightSearchRepository.resolveAirport(
        code: currentState.summary.destIcao,
        fallbackName: 'Arrival',
      );

      emit(
        FlightNumberSearchSuccess(
          departure: departure,
          arrival: arrival,
          flightNumber: normalized,
        ),
      );
    } catch (_) {
      emit(
        FlightNumberSearchError(
          message: t.createFlight.flightNumberSearch.error,
          summary: currentState.summary,
        ),
      );
    }
  }

  void clearSummary() {
    emit(const FlightNumberSearchInitial());
  }

  String? _normalize(String raw) {
    final normalized = raw.replaceAll(RegExp(r'\s+'), '').trim().toUpperCase();
    return normalized.isEmpty ? null : normalized;
  }
}
