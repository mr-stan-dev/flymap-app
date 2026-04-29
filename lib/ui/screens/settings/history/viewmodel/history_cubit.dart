import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/entity/flight.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/logger.dart';
import 'package:flymap/repository/flight_repository.dart';

import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit({required FlightRepository repository})
    : _repository = repository,
      super(const HistoryLoading()) {
    load();
  }

  final FlightRepository _repository;
  final Logger _logger = const Logger('HistoryCubit');

  HistorySort _sort = HistorySort.date;
  List<HistoryItem> _allItems = const [];

  Future<void> load() async {
    emit(const HistoryLoading());
    try {
      final flights = await _repository.getAllFlights();
      _allItems = flights.map((f) => HistoryItem(flight: f)).toList();
      emit(
        HistorySuccess(
          items: _sortedItems(),
          sort: _sort,
          totalFlights: flights.length,
          totalDistanceKm: _totalDistanceKm(flights),
        ),
      );
    } catch (e) {
      _logger.error('Failed to load history: $e');
      emit(HistoryError(t.settings.historyLoadError));
    }
  }

  Future<void> setSort(HistorySort sort) async {
    if (_sort == sort) return;
    _sort = sort;
    final current = state;
    if (current is! HistorySuccess) return;
    emit(current.copyWith(items: _sortedItems(), sort: _sort));
  }

  double _totalDistanceKm(List<Flight> flights) {
    return flights.fold<double>(0, (sum, f) => sum + f.route.distanceInKm);
  }

  List<HistoryItem> _sortedItems() {
    final sorted = [..._allItems];
    switch (_sort) {
      case HistorySort.name:
        sorted.sort(
          (a, b) => a.flight.routeName.toLowerCase().compareTo(
            b.flight.routeName.toLowerCase(),
          ),
        );
        break;
      case HistorySort.distance:
        sorted.sort(
          (a, b) => b.flight.route.distanceInKm.compareTo(a.flight.route.distanceInKm),
        );
        break;
      case HistorySort.date:
        sorted.sort((a, b) => b.flight.createdAt.compareTo(a.flight.createdAt));
        break;
    }
    return sorted;
  }
}

