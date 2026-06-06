import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/analytics/app_analytics.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/repository/flight_unlock_repository.dart';
import 'package:flymap/repository/subscription_repository.dart';
import 'package:flymap/subscription/flight_unlock_product.dart';
import 'package:flymap/subscription/flight_unlock_purchase_result.dart';
import 'package:flymap/subscription/subscription_paywall_result.dart';
import 'package:flymap/subscription/subscription_product.dart';
import 'package:flymap/subscription/subscription_status.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/widgets/flight_unlock_bottom_sheet.dart';
import 'package:flymap/ui/screens/subscription/viewmodel/subscription_cubit.dart';
import 'package:flymap/ui/screens/subscription/viewmodel/subscription_state.dart';
import 'package:flymap/ui/theme/app_theme.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('shows loading state while unlock product is resolving', (
    tester,
  ) async {
    final cubit = _TestSubscriptionCubit(
      const SubscriptionState(
        unusedFlightUnlockCount: 0,
        isFlightUnlockLoading: true,
      ),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(_testApp(cubit: cubit));

    expect(find.text('Loading...'), findsOneWidget);
    expect(find.text('One-time purchase'), findsNothing);
    expect(find.text('Flymap Pro subscription'), findsNothing);
  });

  testWidgets('shows only Pro option when unlock product is unavailable', (
    tester,
  ) async {
    final cubit = _TestSubscriptionCubit(
      const SubscriptionState(unusedFlightUnlockCount: 0),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(_testApp(cubit: cubit));

    expect(find.text('One-time purchase'), findsNothing);
    expect(find.text('Flymap Pro subscription'), findsOneWidget);
  });

  testWidgets('shows both options when unlock product is available', (
    tester,
  ) async {
    final cubit = _TestSubscriptionCubit(
      const SubscriptionState(
        unusedFlightUnlockCount: 0,
        flightUnlockProduct: FlightUnlockProduct(
          productId: 'unlock.flight',
          title: 'Unlock Flight',
          priceText: r'$4.99',
        ),
      ),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(_testApp(cubit: cubit));

    expect(find.text('One-time purchase'), findsOneWidget);
    expect(find.text('Flymap Pro subscription'), findsOneWidget);
    expect(find.text(r'$4.99'), findsOneWidget);
  });
}

Widget _testApp({required SubscriptionCubit cubit}) {
  return TranslationProvider(
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      locale: AppLocale.en.flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Scaffold(
        body: BlocProvider<SubscriptionCubit>.value(
          value: cubit,
          child: FlightUnlockBottomSheet(
            routePreview: null,
            onUnlockFlight: (_) async {},
            onViewProPlans: (_) async {},
          ),
        ),
      ),
    ),
  );
}

class _TestSubscriptionCubit extends SubscriptionCubit {
  _TestSubscriptionCubit(SubscriptionState state)
    : super(
        repository: _FakeSubscriptionRepository(),
        flightUnlockRepository: _FakeFlightUnlockRepository(),
        analytics: _FakeAppAnalytics(),
      ) {
    emit(state);
  }
}

class _FakeSubscriptionRepository implements SubscriptionRepository {
  final StreamController<SubscriptionStatus> _controller =
      StreamController<SubscriptionStatus>.broadcast();

  @override
  SubscriptionStatus get currentStatus => _status();

  @override
  Stream<SubscriptionStatus> get statusStream => _controller.stream;

  @override
  Future<void> close() async {
    await _controller.close();
  }

  @override
  Future<List<SubscriptionProduct>> getProducts() async =>
      const <SubscriptionProduct>[];

  @override
  Future<SubscriptionStatus> initialize() async => _status();

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
  Future<SubscriptionStatus> refresh() async => _status();

  @override
  Future<SubscriptionStatus> restorePurchases() async => _status();
}

class _FakeFlightUnlockRepository implements FlightUnlockRepository {
  @override
  Stream<int> get balanceStream => const Stream<int>.empty();

  @override
  int get currentUnusedUnlockCount => 0;

  @override
  Future<void> close() async {}

  @override
  Future<int> consumeUnlock() async => 0;

  @override
  Future<FlightUnlockProduct?> getUnlockProduct() async => null;

  @override
  Future<int> initialize() async => 0;

  @override
  Future<FlightUnlockPurchaseResult> purchaseUnlock() async {
    return const FlightUnlockPurchaseResult.cancelled();
  }

  @override
  Future<int> restoreUnlock() async => 0;
}

class _FakeAppAnalytics implements AppAnalytics {
  @override
  Future<void> setSubscriptionContext({required bool isPro}) async {}

  @override
  Future<void> setGlobalContext({
    required String appVersion,
    required String buildNumber,
    required String platform,
    required String appEnv,
  }) async {}

  @override
  Future<void> log(AnalyticsEvent event) async {}
}

SubscriptionStatus _status({bool isPro = false}) {
  return SubscriptionStatus(
    isPro: isPro,
    entitlementId: 'pro',
    lastUpdatedAt: DateTime(2026, 1, 1),
  );
}
