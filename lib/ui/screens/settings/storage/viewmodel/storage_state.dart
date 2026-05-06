import 'package:equatable/equatable.dart';
import 'package:flymap/domain/entity/flight.dart';

enum StorageSort { name, size }

class StorageItem extends Equatable {
  const StorageItem({
    required this.flight,
    required this.totalSizeBytes,
  });

  final Flight flight;
  final int totalSizeBytes;

  @override
  List<Object?> get props => [flight, totalSizeBytes];
}

sealed class StorageState extends Equatable {
  const StorageState();

  @override
  List<Object?> get props => [];
}

final class StorageLoading extends StorageState {
  const StorageLoading();
}

final class StorageSuccess extends StorageState {
  const StorageSuccess({
    required this.items,
    required this.sort,
    required this.totalMapsCount,
    required this.totalSizeBytes,
  });

  final List<StorageItem> items;
  final StorageSort sort;
  final int totalMapsCount;
  final int totalSizeBytes;

  StorageSuccess copyWith({
    List<StorageItem>? items,
    StorageSort? sort,
    int? totalMapsCount,
    int? totalSizeBytes,
  }) {
    return StorageSuccess(
      items: items ?? this.items,
      sort: sort ?? this.sort,
      totalMapsCount: totalMapsCount ?? this.totalMapsCount,
      totalSizeBytes: totalSizeBytes ?? this.totalSizeBytes,
    );
  }

  @override
  List<Object?> get props => [items, sort, totalMapsCount, totalSizeBytes];
}

final class StorageError extends StorageState {
  const StorageError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
