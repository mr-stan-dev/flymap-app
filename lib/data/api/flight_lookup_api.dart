import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flymap/logger.dart';

class FlightLookupApi {
  FlightLookupApi({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

  static const _function = 'lookup_flight_by_number';

  final FirebaseFunctions _functions;
  final _logger = const Logger('FlightLookupApi');

  Future<Map<String, dynamic>> lookupFlightByNumber(String flightNumber) async {
    final normalizedFlightNumber = _normalizeFlightNumber(flightNumber);
    if (normalizedFlightNumber == null) {
      throw ArgumentError('flightNumber must be non-empty');
    }
    _logger.log('callable=$_function flightNumber=$normalizedFlightNumber');
    try {
      final result = await _functions.httpsCallable(_function).call({
        'flightNumber': normalizedFlightNumber,
      });
      final decoded = _decodeFunctionData(result.data);
      if (decoded is! Map) {
        const error = FormatException(
          'lookup_flight_by_number returned non-object payload',
        );
        _logger.error(error);
        throw error;
      }
      final payload = decoded.cast<String, dynamic>();
      final summary = payload['flightSummary'];
      if (summary is! Map) {
        const error = FormatException(
          'lookup_flight_by_number payload missing flightSummary',
        );
        _logger.error(error);
        throw error;
      }
      _logger.log(
        'parsed fr24Id=${summary['fr24Id']} orig=${summary['origIcao'] ?? "-"} dest=${summary['destIcao'] ?? "-"}',
      );
      return summary.cast<String, dynamic>();
    } catch (e) {
      _logger.error(
        'failed callable=$_function flightNumber=$normalizedFlightNumber error=$e',
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

  String? _normalizeFlightNumber(String? raw) {
    if (raw == null) return null;
    final value = raw.replaceAll(RegExp(r'\s+'), '').trim().toUpperCase();
    return value.isEmpty ? null : value;
  }
}
