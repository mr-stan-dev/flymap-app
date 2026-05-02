import 'dart:convert';

import 'package:flymap/data/api/api_config.dart';
import 'package:flymap/entity/airport.dart';
import 'package:flymap/logger.dart';
import 'package:http/http.dart' as http;

class RouteRegionsApi {
  RouteRegionsApi({required http.Client httpClient}) : _httpClient = httpClient;

  final http.Client _httpClient;
  final _logger = const Logger('RouteRegionsApi');

  Future<Map<String, dynamic>> getRouteRegions({
    required Airport departure,
    required Airport arrival,
    required int limit,
  }) async {
    final startedMs = DateTime.now().millisecondsSinceEpoch;
    final uri = Uri.parse('${ApiConfig.geoFunctionsBaseUrl}/get_route_regions')
        .replace(
          queryParameters: {
            'from':
                '${departure.latLon.latitude},${departure.latLon.longitude}',
            'to': '${arrival.latLon.latitude},${arrival.latLon.longitude}',
            'fromCountryCode': departure.countryCode,
            'toCountryCode': arrival.countryCode,
            'limit': limit.toString(),
          },
        );
    _logger.log(
      'getRouteRegions dep=${departure.primaryCode} arr=${arrival.primaryCode} limit=$limit host=${uri.host}',
    );
    try {
      final response = await _httpClient
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(ApiConfig.routeRegionsRequestTimeout);
      final latencyMs = DateTime.now().millisecondsSinceEpoch - startedMs;
      _logger.log(
        'getRouteRegions status=${response.statusCode} latencyMs=$latencyMs bytes=${response.bodyBytes.length}',
      );

      if (response.statusCode != 200) {
        final snippet = _compact(response.body);
        final error = StateError(
          'get_route_regions failed status=${response.statusCode} body="$snippet"',
        );
        _logger.error(error);
        throw error;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        const error = FormatException(
          'get_route_regions returned non-object JSON',
        );
        _logger.error(error);
        throw error;
      }
      final payload = decoded.cast<String, dynamic>();
      final regionsCount = payload['regions'] is List
          ? (payload['regions'] as List).length
          : -1;
      final totalMinutes = payload['meta'] is Map
          ? (payload['meta'] as Map)['totalRouteMinutes']
          : null;
      _logger.log(
        'getRouteRegions parsed regions=$regionsCount totalRouteMinutes=$totalMinutes latencyMs=$latencyMs',
      );
      return payload;
    } catch (e) {
      final latencyMs = DateTime.now().millisecondsSinceEpoch - startedMs;
      _logger.error(
        'getRouteRegions failed dep=${departure.primaryCode} arr=${arrival.primaryCode} latencyMs=$latencyMs error=$e',
      );
      rethrow;
    }
  }

  String _compact(String raw) {
    final oneLine = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (oneLine.length <= 220) return oneLine;
    return '${oneLine.substring(0, 220)}...';
  }
}
