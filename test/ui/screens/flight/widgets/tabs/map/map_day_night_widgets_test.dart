import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/domain/entity/offline_map_style.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/day_night/route_sun_event_forecast.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/map_controls.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/map_initializing_overlay.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/widgets/map_sun_event_hint.dart';
import 'package:flymap/ui/theme/app_theme.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('map controls render day-night toggle state', (tester) async {
    await tester.pumpWidget(
      _testApp(
        child: Stack(
          children: [
            FlightMapControls(
              topOffset: 0,
              visible: true,
              offlineMapStyle: OfflineMapStyle.liberty,
              mapStyleLoading: false,
              dayNightEnabled: true,
              is3D: false,
              followUser: false,
              showResetNorth: false,
              mapBearingDegrees: 0,
              onToggleMapStyle: () async {},
              onToggleDayNight: () async {},
              onToggle3D: () async {},
              onToggleFollowUser: () async {},
              onResetNorth: () async {},
            ),
          ],
        ),
      ),
    );

    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
  });

  testWidgets('map controls render style toggle state and loading spinner', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        child: Stack(
          children: [
            FlightMapControls(
              topOffset: 0,
              visible: true,
              offlineMapStyle: OfflineMapStyle.fiord,
              mapStyleLoading: true,
              dayNightEnabled: false,
              is3D: false,
              followUser: false,
              showResetNorth: false,
              mapBearingDegrees: 0,
              onToggleMapStyle: () async {},
              onToggleDayNight: () async {},
              onToggle3D: () async {},
              onToggleFollowUser: () async {},
              onResetNorth: () async {},
            ),
          ],
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byTooltip('Switch to light map style'), findsOneWidget);
  });

  testWidgets('sun event hint shows compact sunrise copy', (tester) async {
    await tester.pumpWidget(
      _testApp(
        child: MapSunEventHint(
          forecast: RouteSunEventForecast(
            type: RouteSunEventType.sunrise,
            eta: const Duration(minutes: 30),
            eventTimeUtc: DateTime.utc(2026, 3, 20, 6, 30),
          ),
        ),
      ),
    );

    expect(find.text('Sunrise in 30 min'), findsOneWidget);
  });

  testWidgets('map initializing overlay keeps map visible underneath', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        child: const Stack(
          children: [
            ColoredBox(color: Colors.red),
            MapInitializingOverlay(),
          ],
        ),
      ),
    );

    final loadingText = find.text('Loading map');
    final overlay = find.byType(MapInitializingOverlay);

    expect(overlay, findsOneWidget);
    expect(loadingText, findsOneWidget);
    expect(
      find.descendant(of: overlay, matching: find.byType(IgnorePointer)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: overlay, matching: find.byType(DecoratedBox)),
      findsAtLeastNWidgets(1),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

Widget _testApp({required Widget child}) {
  return TranslationProvider(
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      locale: AppLocale.en.flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Scaffold(body: child),
    ),
  );
}
