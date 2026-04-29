import 'package:equatable/equatable.dart';
import 'package:flymap/entity/flight.dart';

enum HistorySort { name, distance, date }

class HistoryItem extends Equatable {
  const HistoryItem({required this.flight});

  final Flight flight;

  @override
  List<Object?> get props => [flight];
}

sealed class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

final class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

final class HistorySuccess extends HistoryState {
  const HistorySuccess({
    required this.items,
    required this.sort,
    required this.totalFlights,
    required this.totalDistanceKm,
  });

  final List<HistoryItem> items;
  final HistorySort sort;
  final int totalFlights;
  final double totalDistanceKm;

  String get formattedTotalDistanceKm => totalDistanceKm.toStringAsFixed(0);

  HistorySuccess copyWith({
    List<HistoryItem>? items,
    HistorySort? sort,
    int? totalFlights,
    double? totalDistanceKm,
  }) {
    return HistorySuccess(
      items: items ?? this.items,
      sort: sort ?? this.sort,
      totalFlights: totalFlights ?? this.totalFlights,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
    );
  }

  @override
  List<Object?> get props => [items, sort, totalFlights, totalDistanceKm];
}

final class HistoryError extends HistoryState {
  const HistoryError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

