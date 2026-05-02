import 'package:equatable/equatable.dart';
import 'package:flymap/entity/flight.dart';
import 'package:flymap/entity/gps_data.dart';

/// Sealed class for flight screen states
sealed class FlightScreenState extends Equatable {
  const FlightScreenState();

  @override
  List<Object?> get props => [];
}

/// Loading state
final class FlightScreenLoading extends FlightScreenState {
  const FlightScreenLoading();

  @override
  String toString() => 'FlightScreenLoading()';
}

/// Flight in progress state
final class FlightScreenLoaded extends FlightScreenState {
  final Flight flight;
  final GpsStatus gpsStatus;
  final GpsData? gpsData;
  final int gpsUpdateTick;
  final String? lastVisitedRegionQid;

  const FlightScreenLoaded({
    required this.flight,
    this.gpsStatus = GpsStatus.off,
    this.gpsData,
    this.gpsUpdateTick = 0,
    this.lastVisitedRegionQid,
  });

  FlightScreenLoaded copyWith({
    Flight? flight,
    GpsStatus? gpsStatus,
    GpsData? gpsData,
    int? gpsUpdateTick,
    String? lastVisitedRegionQid,
    bool clearLastVisitedRegionQid = false,
  }) {
    return FlightScreenLoaded(
      flight: flight ?? this.flight,
      gpsStatus: gpsStatus ?? this.gpsStatus,
      gpsData: gpsData ?? this.gpsData,
      gpsUpdateTick: gpsUpdateTick ?? this.gpsUpdateTick,
      lastVisitedRegionQid: clearLastVisitedRegionQid
          ? null
          : lastVisitedRegionQid ?? this.lastVisitedRegionQid,
    );
  }

  @override
  List<Object?> get props => [
    flight,
    gpsStatus,
    gpsData,
    gpsUpdateTick,
    lastVisitedRegionQid,
  ];

  @override
  String toString() {
    return 'FlightScreenLoaded('
        'flightId:${flight.id}, '
        'gpsStatus:${gpsStatus.name}, '
        'hasGpsData:${gpsData != null ? 1 : 0}, '
        'lastVisitedRegionQid:${lastVisitedRegionQid ?? '-'}, '
        'tick:$gpsUpdateTick'
        ')';
  }
}

/// Deleted/Completed state to notify UI
final class FlightScreenDeleted extends FlightScreenState {
  final String message;
  const FlightScreenDeleted(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'FlightScreenDeleted(message:$message)';
}

/// Error state
final class FlightScreenError extends FlightScreenState {
  final String message;
  final Flight? flight;

  const FlightScreenError(this.message, {this.flight});

  @override
  List<Object?> get props => [message, flight];

  @override
  String toString() =>
      'FlightScreenError(message:$message, hasFlight:${flight != null ? 1 : 0})';
}
