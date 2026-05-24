import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flymap/logger.dart';

class FlightRouteSearchApi {
  FlightRouteSearchApi({
    FirebaseFunctions? functions,
    Future<dynamic> Function(String function, Map<String, dynamic> payload)?
    invokeCallable,
  }) : _functions = functions,
       _invokeCallable = invokeCallable;

  static const _function = 'search_flights_by_route';

  final FirebaseFunctions? _functions;
  final Future<dynamic> Function(String function, Map<String, dynamic> payload)?
  _invokeCallable;
  final _logger = const Logger('FlightRouteSearchApi');

  Future<List<Map<String, dynamic>>> searchFlightsByRoute({
    required String departureCode,
    required String arrivalCode,
  }) async {
    final normalizedDepartureCode = _normalizeAirportCode(departureCode);
    final normalizedArrivalCode = _normalizeAirportCode(arrivalCode);
    if (normalizedDepartureCode == null || normalizedArrivalCode == null) {
      throw ArgumentError('departureCode and arrivalCode must be non-empty');
    }

    _logger.log(
      'callable=$_function departure=$normalizedDepartureCode arrival=$normalizedArrivalCode',
    );
    try {
      final decoded = _decodeFunctionData(
        await _callFunction(
          normalizedDepartureCode: normalizedDepartureCode,
          normalizedArrivalCode: normalizedArrivalCode,
        ),
      );
      if (decoded is! Map) {
        throw const FormatException(
          'search_flights_by_route returned non-object payload',
        );
      }

      final payload = decoded.cast<String, dynamic>();
      final flights = payload['flights'];
      if (flights is! List) {
        throw const FormatException(
          'search_flights_by_route payload missing flights list',
        );
      }

      final parsedFlights = flights
          .map<Map<String, dynamic>>((dynamic item) {
            if (item is! Map) {
              throw const FormatException(
                'search_flights_by_route flights item was not an object',
              );
            }
            return item.cast<String, dynamic>();
          })
          .toList(growable: false);

      _logger.log(
        'parsed count=${parsedFlights.length} departure=$normalizedDepartureCode arrival=$normalizedArrivalCode',
      );
      for (final flight in parsedFlights) {
        _logger.log(
          'item flightNumber=${flight['flightNumber'] ?? "-"} fr24Id=${flight['fr24Id'] ?? "-"} airlineCode=${flight['airlineCode'] ?? "-"} orig=${flight['origIcao'] ?? flight['origIata'] ?? "-"} dest=${flight['destIcao'] ?? flight['destIata'] ?? "-"}',
        );
      }
      return parsedFlights;
    } catch (e) {
      _logger.error(
        'failed callable=$_function departure=$normalizedDepartureCode arrival=$normalizedArrivalCode error=$e',
      );
      rethrow;
    }
  }

  dynamic _decodeFunctionData(dynamic rawData) {
    if (rawData is String) {
      try {
        return jsonDecode(rawData);
      } catch (_) {
        return rawData;
      }
    }
    return rawData;
  }

  String? _normalizeAirportCode(String? raw) {
    if (raw == null) return null;
    final value = raw.trim().toUpperCase();
    return value.isEmpty ? null : value;
  }

  Future<dynamic> _callFunction({
    required String normalizedDepartureCode,
    required String normalizedArrivalCode,
  }) async {
    final payload = <String, dynamic>{
      'departureCode': normalizedDepartureCode,
      'arrivalCode': normalizedArrivalCode,
    };
    final invokeCallable = _invokeCallable;
    if (invokeCallable != null) {
      return invokeCallable(_function, payload);
    }
    final functions = _functions ?? FirebaseFunctions.instance;
    final result = await functions.httpsCallable(_function).call(payload);
    return result.data;
  }
}
