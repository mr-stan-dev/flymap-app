import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/data/gps_data_provider.dart';
import 'package:flymap/domain/entity/airport.dart';
import 'package:flymap/domain/entity/flight.dart';
import 'package:flymap/domain/entity/flight_info.dart';
import 'package:flymap/domain/entity/flight_route.dart';
import 'package:flymap/domain/entity/flight_route_metrics.dart';
import 'package:flymap/domain/entity/flight_status.dart';
import 'package:flymap/domain/entity/flight_timestamp.dart';
import 'package:flymap/domain/entity/flight_waypoint.dart';
import 'package:flymap/domain/entity/gps_data.dart';
import 'package:flymap/domain/usecase/complete_flight_use_case.dart';
import 'package:flymap/domain/usecase/delete_flight_use_case.dart';
import 'package:flymap/domain/usecase/start_flight_use_case.dart';
import 'package:flymap/ui/screens/flight/viewmodel/flight_screen_cubit.dart';
import 'package:flymap/ui/screens/flight/viewmodel/flight_screen_state.dart';
import 'package:flymap/ui/screens/flight/viewmodel/geo_awareness_engine.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('FlightScreenCubit.checkInFlight', () {
    test(
      'success updates status to inProgress and preserves it on GPS updates',
      () async {
        final gpsProvider = _FakeGpsDataProvider();
        final startUseCase = _FakeStartFlightUseCase(result: true);
        final cubit = FlightScreenCubit(
          flight: _buildFlight(status: FlightStatus.upcoming),
          deleteFlightUseCase: _NoopDeleteFlightUseCase(),
          completeFlightUseCase: _NoopCompleteFlightUseCase(),
          startFlightUseCase: startUseCase,
          gpsProvider: gpsProvider,
          geoAwarenessEngine: const GeoAwarenessEngine(),
        );
        addTearDown(cubit.close);

        await Future<void>.delayed(Duration.zero);
        gpsProvider.emit(GpsStatus.searching);
        await Future<void>.delayed(Duration.zero);

        final ok = await cubit.checkInFlight();

        expect(ok, isTrue);
        expect(startUseCase.calls, 1);
        expect(
          (cubit.state as FlightScreenLoaded).flight.status,
          FlightStatus.inProgress,
        );

        gpsProvider.emit(
          GpsStatus.gpsActive,
          data: const GpsData(
            latitude: 51.0,
            longitude: 0.1,
            speed: SpeedValue(800, 'km/h'),
            accuracy: 12,
          ),
        );
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state, isA<FlightScreenLoaded>());
        expect(
          (cubit.state as FlightScreenLoaded).flight.status,
          FlightStatus.inProgress,
        );
      },
    );

    test('failure keeps existing status unchanged', () async {
      final gpsProvider = _FakeGpsDataProvider();
      final cubit = FlightScreenCubit(
        flight: _buildFlight(status: FlightStatus.upcoming),
        deleteFlightUseCase: _NoopDeleteFlightUseCase(),
        completeFlightUseCase: _NoopCompleteFlightUseCase(),
        startFlightUseCase: _FakeStartFlightUseCase(result: false),
        gpsProvider: gpsProvider,
        geoAwarenessEngine: const GeoAwarenessEngine(),
      );
      addTearDown(cubit.close);

      await Future<void>.delayed(Duration.zero);
      gpsProvider.emit(GpsStatus.searching);
      await Future<void>.delayed(Duration.zero);

      final ok = await cubit.checkInFlight();

      expect(ok, isFalse);
      expect(
        (cubit.state as FlightScreenLoaded).flight.status,
        FlightStatus.upcoming,
      );
    });
  });
}

Flight _buildFlight({required FlightStatus status}) {
  const departure = Airport(
    name: 'London Heathrow',
    city: 'London',
    countryCode: 'GB',
    latLon: LatLng(51.47, -0.45),
    iataCode: 'LHR',
    icaoCode: 'EGLL',
    wikipediaUrl: '',
  );
  const arrival = Airport(
    name: 'Munich Airport',
    city: 'Munich',
    countryCode: 'DE',
    latLon: LatLng(48.35, 11.79),
    iataCode: 'MUC',
    icaoCode: 'EDDM',
    wikipediaUrl: '',
  );
  const route = FlightRoute(
    departure: departure,
    arrival: arrival,
    waypoints: [
      FlightWaypoint(latLon: LatLng(51.47, -0.45)),
      FlightWaypoint(latLon: LatLng(48.35, 11.79)),
    ],
    corridor: [
      LatLng(51.47, -0.45),
      LatLng(48.35, -0.45),
      LatLng(48.35, 11.79),
    ],
    metrics: FlightRouteMetrics(
      greatCircleDistanceKm: 1487.5,
      approxDurationMinutes: 105,
    ),
  );

  return Flight(
    id: 'flight-1',
    route: route,
    routeInsights: FlightInfo.empty.routeInsights,
    offlineContent: FlightInfo.empty.offlineContent,
    timestamp: FlightTimestamp(createdAt: DateTime(2026, 1, 1)),
    status: status,
  );
}

class _FakeGpsDataProvider extends GpsDataProvider {
  void Function(GpsStatus status, {GpsData? data})? _onUpdate;

  @override
  Future<void> start({
    required void Function(GpsStatus status, {GpsData? data}) onUpdate,
  }) async {
    _onUpdate = onUpdate;
  }

  @override
  Future<void> stop() async {}

  void emit(GpsStatus status, {GpsData? data}) {
    _onUpdate?.call(status, data: data);
  }
}

class _FakeStartFlightUseCase implements StartFlightUseCase {
  _FakeStartFlightUseCase({required this.result});

  final bool result;
  int calls = 0;

  @override
  Future<bool> call({required String flightId}) async {
    calls++;
    return result;
  }
}

class _NoopDeleteFlightUseCase implements DeleteFlightUseCase {
  @override
  Future<bool> call(String flightId) async => true;
}

class _NoopCompleteFlightUseCase implements CompleteFlightUseCase {
  @override
  Future<bool> call({
    required String flightId,
    required bool deleteOfflineData,
  }) async => true;
}
