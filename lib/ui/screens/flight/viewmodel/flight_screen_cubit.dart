import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/data/gps_data_provider.dart';
import 'package:flymap/entity/flight.dart';
import 'package:flymap/entity/gps_data.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/logger.dart';
import 'package:flymap/ui/screens/flight/viewmodel/flight_screen_state.dart';
import 'package:flymap/usecase/complete_flight_use_case.dart';
import 'package:flymap/usecase/delete_flight_use_case.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';

class FlightScreenCubit extends Cubit<FlightScreenState> {
  final _logger = Logger('FlightScreenCubit');
  static const _gpsStaleThreshold = Duration(seconds: 20);
  final Flight flight;
  final DeleteFlightUseCase _deleteFlightUseCase = GetIt.I.get();
  final CompleteFlightUseCase _completeFlightUseCase = GetIt.I.get();
  final GpsDataProvider _gpsProvider = GpsDataProvider();
  Timer? _gpsCheckTimer;
  int _gpsUpdateTick = 0;
  DateTime? _lastGpsEventAt;

  FlightScreenCubit({required this.flight}) : super(FlightScreenLoading()) {
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
        _gpsUpdateTick++;
        emit(
          FlightScreenLoaded(
            flight: flight,
            gpsStatus: status,
            gpsData: data,
            gpsUpdateTick: _gpsUpdateTick,
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
      final ok = await _deleteFlightUseCase(flight.id);
      if (!ok) {
        emit(FlightScreenError(t.home.failedDeleteFlight, flight: flight));
        return;
      }

      emit(FlightScreenDeleted(t.flight.deleted));
    } catch (e) {
      emit(
        FlightScreenError(
          t.flight.deleteError(error: e.toString()),
          flight: flight,
        ),
      );
    }
  }

  Future<bool> completeFlight({required bool deleteOfflineData}) async {
    try {
      final ok = await _completeFlightUseCase(
        flightId: flight.id,
        deleteOfflineData: deleteOfflineData,
      );
      if (!ok) return false;

      if (deleteOfflineData) {
        final current = state;
        if (current is FlightScreenLoaded) {
          emit(
            current.copyWith(
              flight: Flight(
                id: current.flight.id,
                route: current.flight.route,
                maps: const [],
                info: current.flight.info.copyWith(articles: const []),
                createdAt: current.flight.createdAt,
                completedAt: DateTime.now(),
                status: FlightStatus.completed,
              ),
            ),
          );
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
