import 'package:equatable/equatable.dart';

class FlightTimestamp extends Equatable {
  const FlightTimestamp({
    required this.createdAt,
    this.inProgressAt,
    this.completedAt,
  });

  final DateTime createdAt;
  final DateTime? inProgressAt;
  final DateTime? completedAt;

  FlightTimestamp copyWith({
    DateTime? createdAt,
    DateTime? inProgressAt,
    bool clearInProgressAt = false,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return FlightTimestamp(
      createdAt: createdAt ?? this.createdAt,
      inProgressAt: clearInProgressAt
          ? null
          : inProgressAt ?? this.inProgressAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [createdAt, inProgressAt, completedAt];
}
