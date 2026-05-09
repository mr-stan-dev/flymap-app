import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/analytics/app_analytics.dart';
import 'package:flymap/data/gps_data_provider.dart';
import 'package:flymap/domain/entity/airport.dart';
import 'package:flymap/domain/entity/flight.dart';
import 'package:flymap/domain/entity/flight_info.dart';
import 'package:flymap/domain/entity/flight_route.dart';
import 'package:flymap/domain/entity/gps_data.dart';
import 'package:flymap/domain/usecase/complete_flight_use_case.dart';
import 'package:flymap/domain/usecase/delete_flight_use_case.dart';
import 'package:flymap/domain/usecase/start_flight_use_case.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/repository/subscription_repository.dart';
import 'package:flymap/subscription/subscription_paywall_result.dart';
import 'package:flymap/subscription/subscription_product.dart';
import 'package:flymap/subscription/subscription_status.dart';
import 'package:flymap/ui/screens/flight/viewmodel/flight_screen_cubit.dart';
import 'package:flymap/ui/screens/flight/viewmodel/flight_screen_state.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/dashboard_panel.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/dashboard_tab_view.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/geo_card/geo_awareness_card.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/widgets/map_bottom_status_card.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/route/flight_route_tab_view.dart';
import 'package:flymap/ui/screens/subscription/viewmodel/subscription_cubit.dart';
import 'package:flymap/ui/theme/app_theme.dart';
import 'package:latlong2/latlong.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('map bottom card shows check-in card for upcoming', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        child: MapBottomStatusCard(
          status: FlightStatus.upcoming,
          onSelectedRegionChanged: (_) {},
          onCheckInPressed: () {},
        ),
      ),
    );

    expect(find.text('Begin your flight journey'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('map bottom card uses geo-awareness card for in-progress', (
    tester,
  ) async {
    final cubit = FlightScreenCubit(
      flight: _buildFlight(status: FlightStatus.inProgress),
      deleteFlightUseCase: _NoopDeleteFlightUseCase(),
      completeFlightUseCase: _NoopCompleteFlightUseCase(),
      startFlightUseCase: _FakeStartFlightUseCase(result: true),
      gpsProvider: _FakeGpsDataProvider(),
    );

    await tester.pumpWidget(
      _testApp(
        child: BlocProvider.value(
          value: cubit,
          child: MapBottomStatusCard(
            status: FlightStatus.inProgress,
            onSelectedRegionChanged: (_) {},
            onCheckInPressed: () {},
          ),
        ),
      ),
    );

    expect(find.byType(GeoAwarenessCard), findsOneWidget);
    await cubit.close();
    await tester.pump();
  });

  testWidgets('dashboard tab shows bottom check-in card for upcoming', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        child: FlightDashboardTabView(
          state: _loadedState(status: FlightStatus.upcoming),
          topPadding: 0,
        ),
      ),
    );

    expect(find.text('Begin your flight journey'), findsOneWidget);
    expect(find.text('Start to see your live dashboard'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.byType(FlightDashboardPanel), findsOneWidget);
  });

  testWidgets('dashboard tab keeps telemetry layout for in-progress', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        child: FlightDashboardTabView(
          state: _loadedState(status: FlightStatus.inProgress),
          topPadding: 0,
        ),
      ),
    );

    expect(find.byType(FlightDashboardPanel), findsOneWidget);
  });

  testWidgets('route tab upcoming hides route progress and shows facts strip', (
    tester,
  ) async {
    final subscriptionCubit = _buildSubscriptionCubit();
    addTearDown(subscriptionCubit.close);

    await tester.pumpWidget(
      _testApp(
        child: BlocProvider.value(
          value: subscriptionCubit,
          child: FlightRouteTabView(
            state: _loadedState(status: FlightStatus.upcoming),
            topPadding: 0,
          ),
        ),
      ),
    );

    expect(find.text('Route progress'), findsNothing);
    expect(find.text('LHR → MUC'), findsOneWidget);
  });

  testWidgets('route tab in-progress keeps route progress card behavior', (
    tester,
  ) async {
    final subscriptionCubit = _buildSubscriptionCubit();
    addTearDown(subscriptionCubit.close);

    await tester.pumpWidget(
      _testApp(
        child: BlocProvider.value(
          value: subscriptionCubit,
          child: FlightRouteTabView(
            state: _loadedState(
              status: FlightStatus.inProgress,
              gpsData: const GpsData(latitude: 50.0, longitude: 10.0),
            ),
            topPadding: 0,
          ),
        ),
      ),
    );

    expect(find.text('Route progress'), findsOneWidget);
  });
}

Widget _testApp({required Widget child}) {
  return TranslationProvider(
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      locale: AppLocale.en.flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Scaffold(body: child),
    ),
  );
}

FlightScreenLoaded _loadedState({
  required FlightStatus status,
  GpsData? gpsData,
}) {
  final flight = _buildFlight(status: status);
  return FlightScreenLoaded(
    flight: flight,
    routeRegions: flight.info.routeRegions,
    gpsData: gpsData,
    gpsStatus: gpsData == null ? GpsStatus.searching : GpsStatus.gpsActive,
  );
}

Flight _buildFlight({required FlightStatus status}) {
  const departure = Airport(
    name: 'London Heathrow',
    city: 'London',
    countryCode: 'GB',
    latLon: LatLng(51.47, -0.45),
    iataCode: 'LHR',
    icaoCode: 'EGLL',
    wikipediaUrl: '',
  );
  const arrival = Airport(
    name: 'Munich Airport',
    city: 'Munich',
    countryCode: 'DE',
    latLon: LatLng(48.35, 11.79),
    iataCode: 'MUC',
    icaoCode: 'EDDM',
    wikipediaUrl: '',
  );
  const route = FlightRoute(
    departure: departure,
    arrival: arrival,
    waypoints: [LatLng(51.47, -0.45), LatLng(48.35, 11.79)],
    corridor: [LatLng(51.47, -0.45), LatLng(48.35, 11.79)],
  );

  return Flight(
    id: 'flight-1',
    route: route,
    info: const FlightInfo('', [], [], [], 105, 850),
    createdAt: DateTime(2026, 1, 1),
    status: status,
  );
}

SubscriptionCubit _buildSubscriptionCubit() {
  return SubscriptionCubit(
    repository: _FakeSubscriptionRepository(),
    analytics: _FakeAppAnalytics(),
  );
}

class _FakeGpsDataProvider extends GpsDataProvider {
  @override
  Future<void> start({
    required void Function(GpsStatus status, {GpsData? data}) onUpdate,
  }) async {}

  @override
  Future<void> stop() async {}
}

class _FakeStartFlightUseCase implements StartFlightUseCase {
  _FakeStartFlightUseCase({required this.result});

  final bool result;

  @override
  Future<bool> call({required String flightId}) async => result;
}

class _NoopDeleteFlightUseCase implements DeleteFlightUseCase {
  @override
  Future<bool> call(String flightId) async => true;
}

class _NoopCompleteFlightUseCase implements CompleteFlightUseCase {
  @override
  Future<bool> call({
    required String flightId,
    required bool deleteOfflineData,
  }) async => true;
}

class _FakeSubscriptionRepository implements SubscriptionRepository {
  final _controller = StreamController<SubscriptionStatus>.broadcast();

  @override
  SubscriptionStatus get currentStatus => _status(isPro: false);

  @override
  Stream<SubscriptionStatus> get statusStream => _controller.stream;

  @override
  Future<void> close() async {
    await _controller.close();
  }

  @override
  Future<List<SubscriptionProduct>> getProducts() async => const [];

  @override
  Future<SubscriptionStatus> initialize() async => _status(isPro: false);

  @override
  Future<SubscriptionPaywallResult> presentPaywallIfNeeded() async {
    return SubscriptionPaywallResult.notPresented;
  }

  @override
  Future<void> presentCustomerCenter() async {}

  @override
  Future<SubscriptionStatus> purchasePackage({
    required String packageId,
  }) async => _status(isPro: true);

  @override
  Future<SubscriptionStatus> refresh() async => _status(isPro: false);

  @override
  Future<SubscriptionStatus> restorePurchases() async => _status(isPro: false);
}

class _FakeAppAnalytics implements AppAnalytics {
  @override
  Future<void> setGlobalContext({
    required String appVersion,
    required String buildNumber,
    required String platform,
    required String appEnv,
  }) async {}

  @override
  Future<void> setSubscriptionContext({required bool isPro}) async {}

  @override
  Future<void> log(AnalyticsEvent event) async {}
}

SubscriptionStatus _status({required bool isPro}) {
  return SubscriptionStatus(
    isPro: isPro,
    entitlementId: isPro ? 'pro' : 'free',
    lastUpdatedAt: DateTime(2026, 1, 1),
  );
}
