import 'package:flymap/data/api/flight_lookup_api.dart';
import 'package:flymap/data/api/flight_route_preview_api.dart';
import 'package:flymap/data/local/airlines_database.dart';
import 'package:flymap/data/local/airports_database.dart';
import 'package:flymap/domain/entity/airport.dart';
import 'package:flymap/domain/entity/flight_summary.dart';
import 'package:flymap/ui/map/map_utils.dart';
import 'package:latlong2/latlong.dart';

abstract interface class FlightSearchRepository {
  Future<FlightSummary> lookupFlightByNumber(String flightNumber);

  Future<Map<String, dynamic>> buildFlightRoutePreview({
    required String flightNumber,
    required int placesLimit,
    required int regionsLimit,
    String lang = 'en',
  });

  Future<Airport> resolveAirport({
    LatLng? latLon,
    required String? code,
    required String fallbackName,
  });

  Future<String?> resolveAirlineNameByCode(String? code);
}

class ApiFlightSearchRepository implements FlightSearchRepository {
  ApiFlightSearchRepository({
    required FlightLookupApi lookupApi,
    required FlightRoutePreviewApi routePreviewApi,
    required AirportsDatabase airportsDb,
    required AirlinesDatabase airlinesDb,
  }) : _lookupApi = lookupApi,
       _routePreviewApi = routePreviewApi,
       _airportsDb = airportsDb,
       _airlinesDb = airlinesDb;

  final FlightLookupApi _lookupApi;
  final FlightRoutePreviewApi _routePreviewApi;
  final AirportsDatabase _airportsDb;
  final AirlinesDatabase _airlinesDb;

  @override
  Future<FlightSummary> lookupFlightByNumber(String flightNumber) async {
    final map = await _lookupApi.lookupFlightByNumber(flightNumber);
    return FlightSummary.fromApi(map, flightNumber);
  }

  @override
  Future<Map<String, dynamic>> buildFlightRoutePreview({
    required String flightNumber,
    required int placesLimit,
    required int regionsLimit,
    String lang = 'en',
  }) async {
    return await _routePreviewApi.buildFlightRoutePreview(
      flightNumber: flightNumber,
      placesLimit: placesLimit,
      regionsLimit: regionsLimit,
      lang: lang,
    );
  }

  @override
  Future<Airport> resolveAirport({
    LatLng? latLon,
    required String? code,
    required String fallbackName,
  }) async {
    await _airportsDb.initialize();

    final trimmedCode = _normalizeCode(code);
    if (trimmedCode != null) {
      final byCode = _airportsDb.findByCode(trimmedCode);
      if (byCode != null) return byCode;
    }

    final effectiveLatLon = latLon ?? const LatLng(0, 0);

    if (latLon != null) {
      final nearest = _findNearestAirport(latLon);
      if (nearest != null) return nearest;
    }

    final fallbackCode = trimmedCode ?? '';
    return Airport(
      name: fallbackCode.isNotEmpty ? fallbackCode : fallbackName,
      city: '',
      countryCode: '',
      latLon: effectiveLatLon,
      iataCode: fallbackCode.length == 3 ? fallbackCode : '',
      icaoCode: fallbackCode.length == 4 ? fallbackCode : '',
      wikipediaUrl: '',
      type: AirportType.other,
    );
  }

  Airport? _findNearestAirport(LatLng target) {
    Airport? bestAirport;
    var bestDistanceKm = double.infinity;
    for (final airport in _airportsDb.allAirports) {
      final distanceKm = MapUtils.distanceKm(
        departure: target,
        arrival: airport.latLon,
      );
      if (distanceKm < bestDistanceKm) {
        bestDistanceKm = distanceKm;
        bestAirport = airport;
      }
    }
    if (bestDistanceKm <= 120) {
      return bestAirport;
    }
    return null;
  }

  String? _normalizeCode(dynamic raw) {
    if (raw == null) return null;
    final value = raw.toString().trim().toUpperCase();
    return value.isEmpty ? null : value;
  }

  @override
  Future<String?> resolveAirlineNameByCode(String? code) async {
    final normalizedCode = _normalizeCode(code);
    if (normalizedCode == null) return null;

    await _airlinesDb.initialize();
    return _airlinesDb.findNameByCode(normalizedCode);
  }
}
