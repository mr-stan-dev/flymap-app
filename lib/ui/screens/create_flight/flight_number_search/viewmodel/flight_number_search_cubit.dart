import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/analytics/app_analytics.dart';
import 'package:flymap/crashlytics/app_crashlytics.dart';
import 'package:flymap/domain/usecase/lookup_flight_by_number_use_case.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/repository/flight_search_repository.dart';

import 'flight_number_search_state.dart';

class FlightNumberSearchCubit extends Cubit<FlightNumberSearchState> {
  FlightNumberSearchCubit({
    required LookupFlightByNumberUseCase lookupFlightByNumberUseCase,
    required FlightSearchRepository flightSearchRepository,
    required AppAnalytics analytics,
    required AppCrashlytics crashlytics,
  }) : _lookupFlightByNumberUseCase = lookupFlightByNumberUseCase,
       _flightSearchRepository = flightSearchRepository,
       _analytics = analytics,
       _crashlytics = crashlytics,
       super(const FlightNumberSearchInitial());

  final LookupFlightByNumberUseCase _lookupFlightByNumberUseCase;
  final FlightSearchRepository _flightSearchRepository;
  final AppAnalytics _analytics;
  final AppCrashlytics _crashlytics;

  Future<void> loadFlightSummary(String flightNumber) async {
    final normalized = _normalize(flightNumber);
    if (normalized == null) return;

    emit(const FlightNumberSearchLoading());

    try {
      final summary = await _lookupFlightByNumberUseCase(normalized);
      _logLookupResult(result: FlightNumberLookupResult.success);
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
    } catch (error) {
      final failureResult = _lookupFailureResult(error);
      _logLookupResult(result: failureResult);
      unawaited(
        _crashlytics.setContext(
          screen: 'flight_number_lookup_failed',
          flightNumber: normalized,
        ),
      );
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

  void _logLookupResult({required FlightNumberLookupResult result}) {
    _analytics.log(FlightNumberLookupResultEvent(result: result));
  }

  FlightNumberLookupResult _lookupFailureResult(Object error) {
    if (error is FirebaseFunctionsException) {
      return switch (error.code) {
        'not-found' => FlightNumberLookupResult.notFound,
        'unavailable' => FlightNumberLookupResult.providerUnavailable,
        _ => FlightNumberLookupResult.failed,
      };
    }
    return FlightNumberLookupResult.failed;
  }
}
