import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/repository/flight_unlock_repository.dart';
import 'package:flymap/subscription/flight_unlock_product.dart';
import 'package:flymap/subscription/flight_unlock_purchase_result.dart';
import 'package:flymap/subscription/revenuecat_client.dart';
import 'package:flymap/subscription/revenuecat_env_config.dart';
import 'package:flymap/subscription/subscription_paywall_result.dart';
import 'package:purchases_flutter/errors.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('RevenueCatFlightUnlockRepository', () {
    late _FakeRevenueCatClient client;
    late RevenueCatFlightUnlockRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      client = _FakeRevenueCatClient();
      repository = RevenueCatFlightUnlockRepository(
        client: client,
        config: const RevenueCatEnvConfig(
          androidFlightUnlockProductId: 'unlock.flight',
        ),
        platformOverride: TargetPlatform.android,
      );
    });

    tearDown(() async {
      await repository.close();
    });

    test('loads unused balance from shared preferences', () async {
      SharedPreferences.setMockInitialValues({
        'flight_unlock.unused_count.v1': 3,
      });
      repository = RevenueCatFlightUnlockRepository(
        client: client,
        config: const RevenueCatEnvConfig(
          androidFlightUnlockProductId: 'unlock.flight',
        ),
        platformOverride: TargetPlatform.android,
      );

      final count = await repository.initialize();

      expect(count, 3);
      expect(repository.currentUnusedUnlockCount, 3);
    });

    test('purchase success increments balance', () async {
      client.purchaseResult = const FlightUnlockPurchaseResult.purchased();

      final result = await repository.purchaseUnlock();

      expect(result.isPurchased, isTrue);
      expect(result.productId, 'unlock.flight');
      expect(repository.currentUnusedUnlockCount, 1);
    });

    test('purchase cancelled does not increment balance', () async {
      client.purchaseResult = const FlightUnlockPurchaseResult.cancelled();

      final result = await repository.purchaseUnlock();

      expect(result.status, FlightUnlockPurchaseStatus.cancelled);
      expect(result.productId, 'unlock.flight');
      expect(repository.currentUnusedUnlockCount, 0);
    });

    test('purchase error does not increment balance', () async {
      client.purchaseResult = const FlightUnlockPurchaseResult.error();

      final result = await repository.purchaseUnlock();

      expect(result.status, FlightUnlockPurchaseStatus.error);
      expect(result.productId, 'unlock.flight');
      expect(repository.currentUnusedUnlockCount, 0);
    });

    test('consume decrements balance without going below zero', () async {
      client.purchaseResult = const FlightUnlockPurchaseResult.purchased();
      await repository.purchaseUnlock();

      await repository.consumeUnlock();
      await repository.consumeUnlock();

      expect(repository.currentUnusedUnlockCount, 0);
    });

    test('restore increments balance', () async {
      await repository.restoreUnlock();

      expect(repository.currentUnusedUnlockCount, 1);
    });

    test('loads unlock product from revenuecat', () async {
      client.product = const RevenueCatStoreProductSnapshot(
        productId: 'unlock.flight',
        title: 'Unlock Flight',
        priceText: r'$4.99',
        description: 'Use all pro features for this specific flight',
      );

      final product = await repository.getUnlockProduct();

      expect(
        product,
        const FlightUnlockProduct(
          productId: 'unlock.flight',
          title: 'Unlock Flight',
          priceText: r'$4.99',
          description: 'Use all pro features for this specific flight',
        ),
      );
    });
  });
}

class _FakeRevenueCatClient implements RevenueCatClient {
  FlightUnlockPurchaseResult purchaseResult =
      const FlightUnlockPurchaseResult.purchased();
  RevenueCatStoreProductSnapshot? product;

  @override
  Stream<RevenueCatCustomerSnapshot> get customerInfoStream =>
      const Stream.empty();

  @override
  Future<bool> canMakePayments() async => true;

  @override
  Future<void> close() async {}

  @override
  Future<void> configure({required String apiKey}) async {}

  @override
  Future<RevenueCatCustomerSnapshot> getCustomerInfo() async =>
      const RevenueCatCustomerSnapshot(entitlements: {});

  @override
  Future<List<RevenueCatProductSnapshot>> getCurrentOfferingProducts() async =>
      const [];

  @override
  Future<RevenueCatStoreProductSnapshot?> getNonSubscriptionProduct({
    required String productId,
  }) async {
    return product;
  }

  @override
  Future<void> presentCustomerCenter() async {}

  @override
  Future<SubscriptionPaywallResult> presentPaywallIfNeeded({
    required String entitlementId,
  }) async {
    return SubscriptionPaywallResult.notPresented;
  }

  @override
  Future<void> purchaseNonSubscriptionProduct({
    required String productId,
  }) async {
    if (purchaseResult.status == FlightUnlockPurchaseStatus.error) {
      throw StateError('purchase failed');
    }
    if (purchaseResult.status == FlightUnlockPurchaseStatus.cancelled) {
      throw PlatformException(
        code: '${PurchasesErrorCode.purchaseCancelledError.index}',
      );
    }
  }

  @override
  Future<RevenueCatCustomerSnapshot> purchasePackage({
    required String packageId,
  }) async {
    return const RevenueCatCustomerSnapshot(entitlements: {});
  }

  @override
  Future<RevenueCatCustomerSnapshot> restorePurchases() async =>
      const RevenueCatCustomerSnapshot(entitlements: {});
}
