import 'package:equatable/equatable.dart';
import 'package:flymap/domain/entity/flight.dart';
import 'package:flymap/domain/entity/gps_data.dart';
import 'package:flymap/domain/entity/route_region.dart';

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

final class FlightGpsState extends Equatable {
  final GpsStatus status;
  final GpsData? data;
  final int updateTick;
  final DateTime? lastFixAt;

  const FlightGpsState({
    this.status = GpsStatus.off,
    this.data,
    this.updateTick = 0,
    this.lastFixAt,
  });

  FlightGpsState copyWith({
    GpsStatus? status,
    GpsData? data,
    bool preserveData = true,
    bool clearData = false,
    int? updateTick,
    DateTime? lastFixAt,
    bool preserveLastFixAt = true,
    bool clearLastFixAt = false,
  }) {
    return FlightGpsState(
      status: status ?? this.status,
      data: clearData ? null : data ?? (preserveData ? this.data : null),
      updateTick: updateTick ?? this.updateTick,
      lastFixAt: clearLastFixAt
          ? null
          : lastFixAt ?? (preserveLastFixAt ? this.lastFixAt : null),
    );
  }

  @override
  List<Object?> get props => [status, data, updateTick, lastFixAt];
}

/// Flight in progress state
final class FlightScreenLoaded extends FlightScreenState {
  final Flight flight;
  final FlightGpsState gps;
  final List<RouteRegion> routeRegions;
  final String? lastVisitedRegionId;
  final List<String> currentRegionIds;
  final String? nextRegionId;
  final int? nextRegionEtaMinutes;

  const FlightScreenLoaded({
    required this.flight,
    this.gps = const FlightGpsState(),
    required this.routeRegions,
    this.lastVisitedRegionId,
    this.currentRegionIds = const [],
    this.nextRegionId,
    this.nextRegionEtaMinutes,
  });

  FlightScreenLoaded copyWith({
    Flight? flight,
    FlightGpsState? gps,
    List<RouteRegion>? routeRegions,
    String? lastVisitedRegionId,
    bool clearLastVisitedRegionId = false,
    List<String>? currentRegionIds,
    String? nextRegionId,
    bool clearNextRegionId = false,
    int? nextRegionEtaMinutes,
    bool clearNextRegionEtaMinutes = false,
  }) {
    return FlightScreenLoaded(
      flight: flight ?? this.flight,
      gps: gps ?? this.gps,
      routeRegions: routeRegions ?? this.routeRegions,
      lastVisitedRegionId: clearLastVisitedRegionId
          ? null
          : lastVisitedRegionId ?? this.lastVisitedRegionId,
      currentRegionIds: currentRegionIds ?? this.currentRegionIds,
      nextRegionId: clearNextRegionId
          ? null
          : nextRegionId ?? this.nextRegionId,
      nextRegionEtaMinutes: clearNextRegionEtaMinutes
          ? null
          : nextRegionEtaMinutes ?? this.nextRegionEtaMinutes,
    );
  }

  @override
  List<Object?> get props => [
    flight,
    gps,
    routeRegions,
    lastVisitedRegionId,
    currentRegionIds,
    nextRegionId,
    nextRegionEtaMinutes,
  ];

  @override
  String toString() {
    return 'FlightScreenLoaded('
        'flightId:${flight.id}, '
        'gpsStatus:${gps.status.name}, '
        'hasGpsData:${gps.data != null ? 1 : 0}, '
        'lastFix:${gps.lastFixAt?.toIso8601String() ?? '-'}, '
        'lastVisitedRegionId:${lastVisitedRegionId ?? '-'}, '
        'tick:${gps.updateTick}, '
        'currentRegionCount:${currentRegionIds.length}, '
        'hasNext:${nextRegionId != null ? 1 : 0}, '
        'eta:${nextRegionEtaMinutes ?? '-'}'
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
