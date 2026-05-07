import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/data/local/mappers/flight_db_mapper.dart';
import 'package:flymap/domain/entity/airport.dart';
import 'package:flymap/domain/entity/flight.dart';
import 'package:flymap/domain/entity/flight_info.dart';
import 'package:flymap/domain/entity/flight_route.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('FlightDbMapper flightAccessTier', () {
    test('round-trip preserves pro tier', () {
      final mapper = FlightDbMapper();
      final flight = Flight(
        id: 'flight-1',
        route: _route(),
        info: FlightInfo.empty,
        createdAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
        flightAccessTier: Flight.accessTierPro,
      );

      final raw = mapper.toDb(flight);
      final restored = mapper.fromDb(raw);

      expect(restored.flightAccessTier, Flight.accessTierPro);
    });

    test('legacy map without key defaults to basic tier', () {
      final mapper = FlightDbMapper();
      final raw = mapper.toDb(
        Flight(
          id: 'flight-legacy',
          route: _route(),
          info: FlightInfo.empty,
          createdAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
          flightAccessTier: Flight.accessTierPro,
        ),
      );
      raw.remove(FlightDBKeys.flightAccessTier);

      final restored = mapper.fromDb(raw);

      expect(restored.flightAccessTier, Flight.accessTierBasic);
    });
  });
}

FlightRoute _route() {
  const departure = Airport(
    name: 'A',
    city: 'City A',
    countryCode: 'US',
    latLon: LatLng(10, 10),
    iataCode: 'AAA',
    icaoCode: 'AAAA',
    wikipediaUrl: '',
  );
  const arrival = Airport(
    name: 'B',
    city: 'City B',
    countryCode: 'US',
    latLon: LatLng(20, 20),
    iataCode: 'BBB',
    icaoCode: 'BBBB',
    wikipediaUrl: '',
  );
  return const FlightRoute(
    departure: departure,
    arrival: arrival,
    waypoints: [LatLng(10, 10), LatLng(20, 20)],
    corridor: [LatLng(10, 10), LatLng(20, 20)],
  );
}
