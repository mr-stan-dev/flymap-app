import 'dart:convert';

import 'package:flymap/entity/airport.dart';
import 'package:flymap/logger.dart';
import 'package:http/http.dart' as http;

class RoutePlacesApi {
  RoutePlacesApi({required http.Client httpClient, String? baseUrl})
    : _httpClient = httpClient,
      _baseUrl = _resolveBaseUrl(baseUrl);

  final http.Client _httpClient;
  final String _baseUrl;
  final _logger = Logger('RoutePlacesApi');

  static const _hardcodedBaseUrl =
      'https://us-central1-flymap-app.cloudfunctions.net';

  Future<Map<String, dynamic>> getRoutePlaces({
    required Airport departure,
    required Airport arrival,
    required int limit,
  }) async {
    final uri = Uri.parse('$_baseUrl/get_route_places').replace(
      queryParameters: {
        'from': '${departure.latLon.latitude},${departure.latLon.longitude}',
        'to': '${arrival.latLon.latitude},${arrival.latLon.longitude}',
        'limit': limit.toString(),
      },
    );
    _logger.log(
      'getRoutePlaces dep=${departure.primaryCode} arr=${arrival.primaryCode} limit=$limit host=${uri.host}',
    );
    final response = await _httpClient
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 12));

    if (response.statusCode != 200) {
      final snippet = _compact(response.body);
      throw StateError(
        'get_route_places failed status=${response.statusCode} body="$snippet"',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('get_route_places returned non-object JSON');
    }
    return decoded.cast<String, dynamic>();
  }

  static String _resolveBaseUrl(String? explicit) {
    final candidate = (explicit ?? _hardcodedBaseUrl).trim();
    return _normalizeFunctionsBaseUrl(candidate);
  }

  static String _normalizeFunctionsBaseUrl(String raw) {
    var normalized = raw.trim().replaceFirst(RegExp(r'/+$'), '');
    normalized = normalized.replaceFirst(
      RegExp(r'/geoapi/?$', caseSensitive: false),
      '',
    );
    return normalized.replaceFirst(RegExp(r'/+$'), '');
  }

  String _compact(String raw) {
    final oneLine = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (oneLine.length <= 220) return oneLine;
    return '${oneLine.substring(0, 220)}...';
  }
}
