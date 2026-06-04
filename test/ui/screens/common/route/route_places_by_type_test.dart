import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/domain/entity/flight_poi_type.dart';
import 'package:flymap/domain/entity/route_poi.dart';
import 'package:flymap/domain/entity/route_poi_summary.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/screens/common/route/route_places_by_type.dart';
import 'package:latlong2/latlong.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('tapping a place chip opens the poi preview bottom sheet', (
    tester,
  ) async {
    const poi = RoutePoiSummary(
      poi: RoutePoi(
        qid: 'Q90',
        name: 'Paris',
        latLon: LatLng(48.8566, 2.3522),
        type: FlightPoiType.city,
        sitelinks: 100,
      ),
      description:
          'Paris is the capital and most populous city of France with a long history and many landmarks.',
      wiki: 'https://en.wikipedia.org/wiki/Paris',
    );

    await tester.pumpWidget(
      _testApp(child: const RoutePlacesByTypeSection(places: [poi])),
    );

    await tester.tap(find.text('Paris'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Paris'), findsWidgets);
    expect(
      find.textContaining('capital and most populous city of France'),
      findsOneWidget,
    );
  });
}

Widget _testApp({required Widget child}) {
  return TranslationProvider(
    child: MaterialApp(
      locale: AppLocale.en.flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Scaffold(body: child),
    ),
  );
}
