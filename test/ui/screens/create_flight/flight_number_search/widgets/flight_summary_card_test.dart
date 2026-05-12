import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/domain/entity/airport.dart';
import 'package:flymap/domain/entity/flight_summary.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/screens/create_flight/flight_number_search/widgets/flight_summary_card.dart';
import 'package:latlong2/latlong.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('prefers actual FR24 distance and duration when available', (
    tester,
  ) async {
    const departure = Airport(
      name: 'Abu Dhabi International Airport',
      city: 'Abu Dhabi',
      countryCode: 'AE',
      latLon: LatLng(24.4330, 54.6511),
      iataCode: 'AUH',
      icaoCode: 'OMAA',
      wikipediaUrl: '',
    );
    const arrival = Airport(
      name: 'John F. Kennedy International Airport',
      city: 'New York',
      countryCode: 'US',
      latLon: LatLng(40.6413, -73.7781),
      iataCode: 'JFK',
      icaoCode: 'KJFK',
      wikipediaUrl: '',
    );
    final summary = FlightSummary(
      flightNumber: 'EY22',
      origIcao: 'OMAA',
      destIcao: 'KJFK',
      historicalFlightDate: DateTime.utc(2026, 5, 10),
      actualDistanceKm: 11121,
      actualDurationMinutes: 823,
      departure: departure,
      arrival: arrival,
    );

    await tester.pumpWidget(_testApp(summary: summary));

    expect(find.text('11120 km'), findsOneWidget);
    expect(find.text('13h 45m'), findsOneWidget);
    expect(find.textContaining('Based on same flight on'), findsOneWidget);
  });

  testWidgets('falls back to estimated values when actual metrics are absent', (
    tester,
  ) async {
    const departure = Airport(
      name: 'Heathrow Airport',
      city: 'London',
      countryCode: 'GB',
      latLon: LatLng(51.4700, -0.4543),
      iataCode: 'LHR',
      icaoCode: 'EGLL',
      wikipediaUrl: '',
    );
    const arrival = Airport(
      name: 'Charles de Gaulle Airport',
      city: 'Paris',
      countryCode: 'FR',
      latLon: LatLng(49.0097, 2.5479),
      iataCode: 'CDG',
      icaoCode: 'LFPG',
      wikipediaUrl: '',
    );
    const summary = FlightSummary(
      flightNumber: 'BA304',
      origIcao: 'EGLL',
      destIcao: 'LFPG',
      departure: departure,
      arrival: arrival,
    );

    await tester.pumpWidget(_testApp(summary: summary));

    expect(find.text('347 km'), findsOneWidget);
    expect(find.text('54m'), findsOneWidget);
  });
}

Widget _testApp({required FlightSummary summary}) {
  return TranslationProvider(
    child: MaterialApp(
      locale: AppLocale.en.flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      home: Scaffold(body: FlightSummaryCard(summary: summary)),
    ),
  );
}
