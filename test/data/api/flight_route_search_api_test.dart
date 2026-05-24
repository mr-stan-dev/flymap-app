import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/data/api/flight_route_search_api.dart';

void main() {
  group('FlightRouteSearchApi', () {
    test('normalizes airport codes before invoking callable', () async {
      String? calledFunction;
      Map<String, dynamic>? calledPayload;
      final api = FlightRouteSearchApi(
        invokeCallable: (function, payload) async {
          calledFunction = function;
          calledPayload = payload;
          return <String, dynamic>{
            'flights': <Map<String, dynamic>>[
              <String, dynamic>{'flightNumber': 'BA117'},
            ],
          };
        },
      );

      await api.searchFlightsByRoute(
        departureCode: ' egll ',
        arrivalCode: ' kjfk ',
      );

      expect(calledFunction, 'search_flights_by_route');
      expect(calledPayload, <String, dynamic>{
        'departureCode': 'EGLL',
        'arrivalCode': 'KJFK',
      });
    });

    test('throws format exception when flights list is missing', () async {
      final api = FlightRouteSearchApi(
        invokeCallable: (_, __) async => <String, dynamic>{'foo': 'bar'},
      );

      await expectLater(
        api.searchFlightsByRoute(departureCode: 'EGLL', arrivalCode: 'KJFK'),
        throwsA(isA<FormatException>()),
      );
    });

    test('parses flights array into typed maps', () async {
      final api = FlightRouteSearchApi(
        invokeCallable: (_, __) async => <String, dynamic>{
          'flights': <Map<String, dynamic>>[
            <String, dynamic>{'flightNumber': 'BA117'},
            <String, dynamic>{'flightNumber': 'VS3'},
          ],
        },
      );

      final flights = await api.searchFlightsByRoute(
        departureCode: 'EGLL',
        arrivalCode: 'KJFK',
      );

      expect(flights, hasLength(2));
      expect(flights.first['flightNumber'], 'BA117');
      expect(flights.last['flightNumber'], 'VS3');
    });
  });
}
