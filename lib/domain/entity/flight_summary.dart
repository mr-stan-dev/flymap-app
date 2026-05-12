import 'package:equatable/equatable.dart';
import 'package:flymap/domain/entity/airport.dart';
import 'package:flymap/domain/entity/flight_route_metrics.dart';

class FlightSummary extends Equatable {
  const FlightSummary({
    required this.flightNumber,
    required this.origIcao,
    required this.destIcao,
    this.airlineCode,
    this.airlineName,
    this.historicalFlightDate,
    this.actualDistanceKm,
    this.actualDurationMinutes,
    this.departure,
    this.arrival,
  });

  final String? flightNumber;
  final String? origIcao;
  final String? destIcao;
  final String? airlineCode;
  final String? airlineName;
  final DateTime? historicalFlightDate;
  final double? actualDistanceKm;
  final int? actualDurationMinutes;
  final Airport? departure;
  final Airport? arrival;

  int? get displayActualDistanceKm {
    final distanceKm = _toFiniteDouble(actualDistanceKm);
    if (distanceKm == null || distanceKm <= 0) return null;
    return FlightRouteMetrics.roundDistanceKmForDisplay(
      distanceKm,
      isActual: true,
    );
  }

  int? get displayActualDurationMinutes {
    final durationMinutes = _toInt(actualDurationMinutes);
    if (durationMinutes == null || durationMinutes <= 0) return null;
    return FlightRouteMetrics.roundDurationMinutesForDisplay(
      durationMinutes,
      isActual: true,
    );
  }

  factory FlightSummary.fromApi(
    Map<String, dynamic> map,
    String fallbackFlightNumber,
  ) {
    // Check multiple possible key formats (camelCase, snake_case, nested)
    final origCode = _toNonEmptyString(
      map['origIata'] ??
          map['orig_iata'] ??
          map['originIata'] ??
          map['origin_iata'] ??
          map['origIcao'] ??
          map['orig_icao'] ??
          map['originIcao'] ??
          map['origin_icao'] ??
          map['origin']?['iata'] ??
          map['origin']?['icao'] ??
          map['departure']?['iata'] ??
          map['departure']?['icao'],
    );

    final destCode = _toNonEmptyString(
      map['destIata'] ??
          map['dest_iata'] ??
          map['destinationIata'] ??
          map['destination_iata'] ??
          map['destIcao'] ??
          map['dest_icao'] ??
          map['destinationIcao'] ??
          map['destination_icao'] ??
          map['destination']?['iata'] ??
          map['destination']?['icao'] ??
          map['arrival']?['iata'] ??
          map['arrival']?['icao'],
    );

    return FlightSummary(
      flightNumber:
          _toNonEmptyString(map['flightNumber'] ?? map['flight_number']) ??
          fallbackFlightNumber,
      origIcao: origCode,
      destIcao: destCode,
      airlineCode: _toNonEmptyString(
        map['airlineCode'] ??
            map['airline_code'] ??
            map['operatingAs'] ??
            map['operating_as'] ??
            map['paintedAs'] ??
            map['painted_as'],
      ),
      airlineName: _toNonEmptyString(
        map['airlineName'] ?? map['airline_name'] ?? map['airline'],
      ),
      historicalFlightDate: _toDate(
        map['historicalFlightDate'] ??
            map['historical_flight_date'] ??
            map['historicalDate'] ??
            map['historical_date'],
      ),
      actualDistanceKm: _toFiniteDouble(
        map['actualDistanceKm'] ??
            map['actual_distance'] ??
            map['actual_distance_km'] ??
            map['distanceKm'] ??
            map['distance_km'],
      ),
      actualDurationMinutes: _toInt(
        map['actualDurationMinutes'] ??
            map['actual_duration_minutes'] ??
            map['actualTimeMin'] ??
            map['actual_time_min'] ??
            map['flightDuration'] ??
            map['flight_duration'] ??
            map['durationMin'] ??
            map['duration_min'],
      ),
    );
  }

  FlightSummary copyWith({
    String? flightNumber,
    String? origIcao,
    String? destIcao,
    String? airlineCode,
    String? airlineName,
    DateTime? historicalFlightDate,
    double? actualDistanceKm,
    int? actualDurationMinutes,
    Airport? departure,
    Airport? arrival,
  }) {
    return FlightSummary(
      flightNumber: flightNumber ?? this.flightNumber,
      origIcao: origIcao ?? this.origIcao,
      destIcao: destIcao ?? this.destIcao,
      airlineCode: airlineCode ?? this.airlineCode,
      airlineName: airlineName ?? this.airlineName,
      historicalFlightDate: historicalFlightDate ?? this.historicalFlightDate,
      actualDistanceKm: actualDistanceKm ?? this.actualDistanceKm,
      actualDurationMinutes:
          actualDurationMinutes ?? this.actualDurationMinutes,
      departure: departure ?? this.departure,
      arrival: arrival ?? this.arrival,
    );
  }

  static String? _toNonEmptyString(dynamic raw) {
    if (raw == null) return null;
    final value = raw.toString().trim();
    return value.isEmpty ? null : value;
  }

  static double? _toFiniteDouble(dynamic raw) {
    if (raw is num) {
      final value = raw.toDouble();
      return value.isFinite ? value : null;
    }
    if (raw is String) {
      final parsed = double.tryParse(raw);
      if (parsed == null || !parsed.isFinite) return null;
      return parsed;
    }
    return null;
  }

  static int? _toInt(dynamic raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  static DateTime? _toDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) {
      return DateTime.utc(raw.year, raw.month, raw.day);
    }
    if (raw is int) {
      final dt = DateTime.fromMillisecondsSinceEpoch(raw * 1000, isUtc: true);
      return DateTime.utc(dt.year, dt.month, dt.day);
    }
    if (raw is num) {
      final dt = DateTime.fromMillisecondsSinceEpoch(
        raw.toInt() * 1000,
        isUtc: true,
      );
      return DateTime.utc(dt.year, dt.month, dt.day);
    }
    if (raw is String) {
      final parsed = DateTime.tryParse(raw);
      if (parsed == null) return null;
      return DateTime.utc(parsed.year, parsed.month, parsed.day);
    }
    return null;
  }

  @override
  List<Object?> get props => [
    flightNumber,
    origIcao,
    destIcao,
    airlineCode,
    airlineName,
    historicalFlightDate,
    actualDistanceKm,
    actualDurationMinutes,
    departure,
    arrival,
  ];
}
