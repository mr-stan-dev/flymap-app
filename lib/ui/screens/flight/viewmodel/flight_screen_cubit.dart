import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/data/gps_data_provider.dart';
import 'package:flymap/domain/entity/flight.dart';
import 'package:flymap/domain/entity/gps_data.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/logger.dart';
import 'package:flymap/ui/screens/flight/viewmodel/flight_screen_state.dart';
import 'package:flymap/ui/screens/flight/viewmodel/geo_awareness_engine.dart';
import 'package:flymap/domain/usecase/complete_flight_use_case.dart';
import 'package:flymap/domain/usecase/delete_flight_use_case.dart';
import 'package:flymap/domain/usecase/start_flight_use_case.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';

class FlightScreenCubit extends Cubit<FlightScreenState> {
  final _logger = Logger('FlightScreenCubit');
  static const _gpsStaleThreshold = Duration(seconds: 20);
  final Flight flight;
  Flight _currentFlight;
  final DeleteFlightUseCase _deleteFlightUseCase;
  final CompleteFlightUseCase _completeFlightUseCase;
  final StartFlightUseCase _startFlightUseCase;
  final GpsDataProvider _gpsProvider;
  final GeoAwarenessEngine _geoAwarenessEngine;
  Timer? _gpsCheckTimer;
  int _gpsUpdateTick = 0;
  DateTime? _lastGpsEventAt;

  FlightScreenCubit({
    required this.flight,
    DeleteFlightUseCase? deleteFlightUseCase,
    CompleteFlightUseCase? completeFlightUseCase,
    StartFlightUseCase? startFlightUseCase,
    GpsDataProvider? gpsProvider,
    GeoAwarenessEngine? geoAwarenessEngine,
  }) : _currentFlight = flight,
       _deleteFlightUseCase = deleteFlightUseCase ?? GetIt.I.get(),
       _completeFlightUseCase = completeFlightUseCase ?? GetIt.I.get(),
       _startFlightUseCase = startFlightUseCase ?? GetIt.I.get(),
       _gpsProvider = gpsProvider ?? GpsDataProvider(),
       _geoAwarenessEngine = geoAwarenessEngine ?? const GeoAwarenessEngine(),
       super(FlightScreenLoading()) {
    _logger.log('flight flightInfo: ${flight.info}');
    load();
  }

  Future<void> load() async {
    await _startGpsListening();
  }

  Future<void> _startGpsListening() async {
    await _gpsProvider.stop();
    _gpsCheckTimer?.cancel();

    await _gpsProvider.start(
      onUpdate: (status, {data}) {
        final current = state is FlightScreenLoaded
            ? state as FlightScreenLoaded
            : null;
        switch (status) {
          case GpsStatus.gpsActive:
          case GpsStatus.weakSignal:
          case GpsStatus.searching:
            _lastGpsEventAt = DateTime.now();
            break;
          case GpsStatus.off:
          case GpsStatus.permissionsNotGranted:
            _lastGpsEventAt = null;
            break;
        }
        final previousGeo = current == null
            ? null
            : GeoAwarenessSnapshot(
                currentRegionIds: current.currentRegionIds,
                nextRegionId: current.nextRegionId,
                nextRegionEtaMinutes: current.nextRegionEtaMinutes,
              );
        final geo = _geoAwarenessEngine.compute(
          route: _currentFlight.route,
          routeRegions: _currentFlight.info.routeRegions,
          cruiseSpeedKmh: _currentFlight.info.routeCruiseSpeedKmh,
          gpsData: data,
          previous: previousGeo,
        );

        var lastVisitedRegionId = current?.lastVisitedRegionId;
        if (geo.currentRegionIds.isNotEmpty) {
          lastVisitedRegionId = geo.currentRegionIds.last;
        }
        _gpsUpdateTick++;
        emit(
          FlightScreenLoaded(
            gpsStatus: status,
            gpsData: data,
            gpsUpdateTick: _gpsUpdateTick,
            flight: _currentFlight,
            routeRegions: _currentFlight.info.routeRegions,
            lastVisitedRegionId: lastVisitedRegionId,
            currentRegionIds: geo.currentRegionIds,
            nextRegionId: geo.nextRegionId,
            nextRegionEtaMinutes: geo.nextRegionEtaMinutes,
          ),
        );
      },
    );
    _gpsCheckTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkGpsStatus(),
    );
  }

  Future<void> deleteFlight() async {
    emit(const FlightScreenLoading());
    try {
      final ok = await _deleteFlightUseCase(_currentFlight.id);
      if (!ok) {
        emit(
          FlightScreenError(t.home.failedDeleteFlight, flight: _currentFlight),
        );
        return;
      }

      emit(FlightScreenDeleted(t.flight.deleted));
    } catch (e) {
      emit(
        FlightScreenError(
          t.flight.deleteError(error: e.toString()),
          flight: _currentFlight,
        ),
      );
    }
  }

  Future<bool> checkInFlight() async {
    if (_currentFlight.status == FlightStatus.inProgress) {
      return true;
    }
    try {
      final ok = await _startFlightUseCase(flightId: _currentFlight.id);
      if (!ok) {
        return false;
      }

      _currentFlight = Flight(
        id: _currentFlight.id,
        route: _currentFlight.route,
        maps: _currentFlight.maps,
        info: _currentFlight.info,
        createdAt: _currentFlight.createdAt,
        inProgressAt: DateTime.now(),
        completedAt: _currentFlight.completedAt,
        status: FlightStatus.inProgress,
        flightAccessTier: _currentFlight.flightAccessTier,
      );

      final currentState = state;
      if (currentState is FlightScreenLoaded) {
        emit(currentState.copyWith(flight: _currentFlight));
      } else {
        emit(
          FlightScreenLoaded(
            flight: _currentFlight,
            routeRegions: _currentFlight.info.routeRegions,
          ),
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> completeFlight({required bool deleteOfflineData}) async {
    try {
      final ok = await _completeFlightUseCase(
        flightId: _currentFlight.id,
        deleteOfflineData: deleteOfflineData,
      );
      if (!ok) return false;

      if (deleteOfflineData) {
        final current = state;
        if (current is FlightScreenLoaded) {
          _currentFlight = Flight(
            id: current.flight.id,
            route: current.flight.route,
            maps: const [],
            info: current.flight.info.copyWith(articles: const []),
            createdAt: current.flight.createdAt,
            inProgressAt: null,
            completedAt: DateTime.now(),
            status: FlightStatus.completed,
            flightAccessTier: current.flight.flightAccessTier,
          );
          emit(current.copyWith(flight: _currentFlight));
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _checkGpsStatus() async {
    final current = state;
    if (current is! FlightScreenLoaded) return;

    if (current.gpsStatus == GpsStatus.off ||
        current.gpsStatus == GpsStatus.permissionsNotGranted) {
      return;
    }

    final lastEventAt = _lastGpsEventAt;
    if (lastEventAt == null) {
      if (current.gpsStatus != GpsStatus.searching) {
        emit(current.copyWith(gpsStatus: GpsStatus.searching));
      }
      return;
    }

    final stale = DateTime.now().difference(lastEventAt) > _gpsStaleThreshold;
    if (stale && current.gpsStatus != GpsStatus.searching) {
      emit(current.copyWith(gpsStatus: GpsStatus.searching));
    }
  }

  Future<void> requestLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return;
    }

    await _startGpsListening();
  }

  void openLocationSettings() {
    Geolocator.openLocationSettings();
  }

  @override
  Future<void> close() {
    _gpsCheckTimer?.cancel();
    _gpsProvider.stop();
    return super.close();
  }
}
