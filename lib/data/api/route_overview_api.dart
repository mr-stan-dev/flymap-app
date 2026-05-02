import 'dart:convert';
import 'dart:ui';

import 'package:flymap/data/api/api_config.dart';
import 'package:flymap/entity/airport.dart';
import 'package:http/http.dart' as http;

class RouteOverviewApi {
  RouteOverviewApi({required http.Client httpClient})
    : _httpClient = httpClient;

  final http.Client _httpClient;

  Future<Map<String, dynamic>> getRouteOverview({
    required Airport departure,
    required Airport arrival,
    required int placesLimit,
    required int regionsLimit,
  }) async {
    final uri = Uri.parse('${ApiConfig.geoFunctionsBaseUrl}/get_route_overview')
        .replace(
          queryParameters: {
            'from':
                '${departure.latLon.latitude},${departure.latLon.longitude}',
            'to': '${arrival.latLon.latitude},${arrival.latLon.longitude}',
            'fromCountryCode': departure.countryCode,
            'toCountryCode': arrival.countryCode,
            'placesLimit': placesLimit.toString(),
            'regionsLimit': regionsLimit.toString(),
            'lang': _preferredLanguageCode(),
          },
        );
    final response = await _httpClient
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(ApiConfig.routeRegionsRequestTimeout);

    if (response.statusCode != 200) {
      final snippet = _compact(response.body);
      throw StateError(
        'get_route_overview failed status=${response.statusCode} body="$snippet"',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException(
        'get_route_overview returned non-object JSON',
      );
    }
    return decoded.cast<String, dynamic>();
  }

  String _compact(String raw) {
    final oneLine = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (oneLine.length <= 220) return oneLine;
    return '${oneLine.substring(0, 220)}...';
  }

  String _preferredLanguageCode() {
    final lang = PlatformDispatcher.instance.locale.languageCode.trim();
    if (lang.isEmpty) return 'en';
    return lang.toLowerCase();
  }
}
