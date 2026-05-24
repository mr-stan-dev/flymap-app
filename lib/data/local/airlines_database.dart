import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:flymap/logger.dart';

class Airline {
  const Airline({
    required this.name,
    required this.iataCode,
    required this.icaoCode,
  });

  final String name;
  final String iataCode;
  final String icaoCode;
}

class AirlinesDatabase {
  static AirlinesDatabase? _instance;
  final _logger = const Logger('AirlinesDatabase');
  final List<Airline> _airlines = [];
  bool _isInitialized = false;
  Future<void>? _initializing;

  AirlinesDatabase._();
  AirlinesDatabase.test({Iterable<Airline> seedAirlines = const []}) {
    _airlines.addAll(seedAirlines);
    _isInitialized = true;
  }

  /// Get singleton instance
  static AirlinesDatabase get instance {
    _instance ??= AirlinesDatabase._();
    return _instance!;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    final inFlightInitialization = _initializing;
    if (inFlightInitialization != null) {
      await inFlightInitialization;
      return;
    }

    _initializing = _initializeInternal();
    try {
      await _initializing;
    } finally {
      _initializing = null;
    }
  }

  Future<void> _initializeInternal() async {
    try {
      _logger.log('Initializing airlines database...');

      final String csvData = await rootBundle.loadString(
        'assets/data/iata_airlines.csv',
      );

      final rows = const CsvToListConverter(
        fieldDelimiter: '^',
        eol: '\n',
        shouldParseNumbers: false,
      ).convert(csvData);

      _logger.log('Found ${rows.length} rows in airlines CSV');

      final loadedAirlines = <Airline>[];

      // iata_code^icao_code^name^alias
      for (int i = 1; i < rows.length; i++) {
        final parts = rows[i].map((e) => (e ?? '').toString().trim()).toList();
        if (parts.length < 3) continue;

        final iata = parts[0].toUpperCase();
        final icao = parts[1].toUpperCase();
        final name = parts[2];

        loadedAirlines.add(Airline(name: name, iataCode: iata, icaoCode: icao));
      }

      _airlines
        ..clear()
        ..addAll(loadedAirlines);
      _isInitialized = true;
      _logger.log('Successfully loaded ${_airlines.length} airlines');
    } catch (e) {
      _logger.error('Error initializing airlines database: $e');
    }
  }

  String? findNameByCode(String code) {
    if (!_isInitialized) return null;
    final upper = code.toUpperCase();
    for (final a in _airlines) {
      if ((a.iataCode.isNotEmpty && a.iataCode == upper) ||
          (a.icaoCode.isNotEmpty && a.icaoCode == upper)) {
        return a.name;
      }
    }
    return null;
  }
}
