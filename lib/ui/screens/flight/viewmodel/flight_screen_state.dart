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

/// Flight in progress state
final class FlightScreenLoaded extends FlightScreenState {
  final Flight flight;
  final GpsStatus gpsStatus;
  final GpsData? gpsData;
  final int gpsUpdateTick;
  final List<RouteRegion> routeRegions;
  final String? lastVisitedRegionId;
  final List<String> currentRegionIds;
  final String? nextRegionId;
  final int? nextRegionEtaMinutes;

  const FlightScreenLoaded({
    required this.flight,
    this.gpsStatus = GpsStatus.off,
    this.gpsData,
    this.gpsUpdateTick = 0,
    required this.routeRegions,
    this.lastVisitedRegionId,
    this.currentRegionIds = const [],
    this.nextRegionId,
    this.nextRegionEtaMinutes,
  });

  FlightScreenLoaded copyWith({
    Flight? flight,
    GpsStatus? gpsStatus,
    GpsData? gpsData,
    int? gpsUpdateTick,
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
      gpsStatus: gpsStatus ?? this.gpsStatus,
      gpsData: gpsData ?? this.gpsData,
      gpsUpdateTick: gpsUpdateTick ?? this.gpsUpdateTick,
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
    gpsStatus,
    gpsData,
    gpsUpdateTick,
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
        'gpsStatus:${gpsStatus.name}, '
        'hasGpsData:${gpsData != null ? 1 : 0}, '
        'lastVisitedRegionId:${lastVisitedRegionId ?? '-'}, '
        'tick:$gpsUpdateTick, '
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
