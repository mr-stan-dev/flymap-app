import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/domain/entity/flight.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/logger.dart';
import 'package:flymap/repository/flight_repository.dart';
import 'package:flymap/domain/usecase/delete_flight_use_case.dart';

import 'storage_state.dart';

class StorageCubit extends Cubit<StorageState> {
  StorageCubit({
    required FlightRepository repository,
    required DeleteFlightUseCase deleteFlightUseCase,
  }) : _repository = repository,
       _deleteFlightUseCase = deleteFlightUseCase,
       super(const StorageLoading()) {
    load();
  }

  final FlightRepository _repository;
  final DeleteFlightUseCase _deleteFlightUseCase;
  final Logger _logger = const Logger('StorageCubit');

  StorageSort _sort = StorageSort.size;
  List<StorageItem> _allItems = const [];

  Future<void> load() async {
    emit(const StorageLoading());
    try {
      final flights = await _repository.getAllFlights();
      _allItems = _buildStorageItems(flights);
      emit(
        StorageSuccess(
          items: _sortedItems(),
          sort: _sort,
          totalMapsCount: _totalMapsCount(_allItems),
          totalSizeBytes: _totalSizeBytes(_allItems),
        ),
      );
    } catch (e) {
      _logger.error('Failed to load storage data: $e');
      emit(StorageError(t.settings.storageLoadError));
    }
  }

  Future<void> setSort(StorageSort sort) async {
    if (_sort == sort) return;
    _sort = sort;
    final current = state;
    if (current is! StorageSuccess) return;
    emit(current.copyWith(items: _sortedItems(), sort: _sort));
  }

  Future<bool> deleteFlight(String flightId) async {
    try {
      final ok = await _deleteFlightUseCase(flightId);
      if (!ok) return false;
      await load();
      return true;
    } catch (e) {
      _logger.error('Failed to delete flight $flightId: $e');
      return false;
    }
  }

  List<StorageItem> _buildStorageItems(List<Flight> flights) {
    final items = <StorageItem>[];
    for (final flight in flights) {
      if (flight.maps.isEmpty) continue;
      final totalSize = flight.maps.fold<int>(
        0,
        (sum, map) => sum + map.sizeBytes,
      );
      if (totalSize <= 0) continue;
      items.add(StorageItem(flight: flight, totalSizeBytes: totalSize));
    }
    return items;
  }

  int _totalMapsCount(List<StorageItem> items) {
    return items.fold<int>(0, (sum, item) => sum + item.flight.maps.length);
  }

  int _totalSizeBytes(List<StorageItem> items) {
    return items.fold<int>(0, (sum, item) => sum + item.totalSizeBytes);
  }

  List<StorageItem> _sortedItems() {
    final sorted = [..._allItems];
    switch (_sort) {
      case StorageSort.name:
        sorted.sort((a, b) => a.flight.routeName.compareTo(b.flight.routeName));
        break;
      case StorageSort.size:
        sorted.sort((a, b) => b.totalSizeBytes.compareTo(a.totalSizeBytes));
        break;
    }
    return sorted;
  }
}
