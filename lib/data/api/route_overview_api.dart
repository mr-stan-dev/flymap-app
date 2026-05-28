import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flymap/domain/entity/airport.dart';
import 'package:flymap/i18n/app_localization.dart';
import 'package:flymap/logger.dart';

class RouteOverviewApi {
  RouteOverviewApi({FirebaseFunctions? functions}) : _functions = functions;

  static const _function = 'flight_get_route_overview';
  static const _requestTimeout = Duration(seconds: 25);

  final FirebaseFunctions? _functions;
  final _logger = const Logger('RouteOverviewApi');

  Future<Map<String, dynamic>> getRouteOverview({
    required Airport departure,
    required Airport arrival,
    required int placesLimit,
    required int regionsLimit,
  }) async {
    final payload = <String, dynamic>{
      'from': '${departure.latLon.latitude},${departure.latLon.longitude}',
      'to': '${arrival.latLon.latitude},${arrival.latLon.longitude}',
      'fromCountryCode': departure.countryCode,
      'toCountryCode': arrival.countryCode,
      'placesLimit': placesLimit,
      'regionsLimit': regionsLimit,
      'lang': AppLocalization.currentLanguageCode,
    };
    _logger.log(
      'callable=$_function dep=${departure.primaryCode} arr=${arrival.primaryCode} '
      'placesLimit=$placesLimit regionsLimit=$regionsLimit',
    );

    try {
      final functions = _functions ?? FirebaseFunctions.instance;
      final result = await functions
          .httpsCallable(_function)
          .call(payload)
          .timeout(_requestTimeout);
      final decoded = _decodeFunctionData(result.data);
      if (decoded is! Map) {
        throw const FormatException(
          'flight_get_route_overview returned non-object payload',
        );
      }

      final responsePayload = decoded.cast<String, dynamic>();
      final placesCount =
          responsePayload['places'] is Map &&
              (responsePayload['places'] as Map)['features'] is List
          ? ((responsePayload['places'] as Map)['features'] as List).length
          : -1;
      final regionsCount = responsePayload['regions'] is List
          ? (responsePayload['regions'] as List).length
          : -1;
      _logger.log(
        'parsed callable=$_function places=$placesCount regions=$regionsCount '
        'dep=${departure.primaryCode} arr=${arrival.primaryCode}',
      );
      return responsePayload;
    } on FirebaseFunctionsException catch (error) {
      _logger.error(
        'failed callable=$_function code=${error.code} '
        'message=${error.message} details=${error.details}',
      );
      rethrow;
    } catch (error) {
      _logger.error(
        'failed callable=$_function dep=${departure.primaryCode} '
        'arr=${arrival.primaryCode} error=$error',
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
}
