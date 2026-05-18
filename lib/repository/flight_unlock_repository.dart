import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flymap/logger.dart';
import 'package:flymap/subscription/flight_unlock_product.dart';
import 'package:flymap/subscription/flight_unlock_purchase_result.dart';
import 'package:flymap/subscription/revenuecat_client.dart';
import 'package:flymap/subscription/revenuecat_env_config.dart';
import 'package:purchases_flutter/errors.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class FlightUnlockRepository {
  Stream<int> get balanceStream;

  int get currentUnusedUnlockCount;

  Future<int> initialize();

  Future<FlightUnlockProduct?> getUnlockProduct();

  Future<FlightUnlockPurchaseResult> purchaseUnlock();

  Future<int> consumeUnlock();

  Future<int> restoreUnlock();

  Future<void> close();
}

class RevenueCatFlightUnlockRepository implements FlightUnlockRepository {
  RevenueCatFlightUnlockRepository({
    required RevenueCatClient client,
    required RevenueCatEnvConfig config,
    TargetPlatform? platformOverride,
  }) : _client = client,
       _config = config,
       _platformOverride = platformOverride;

  static const _unusedUnlockCountKey = 'flight_unlock.unused_count.v1';

  final RevenueCatClient _client;
  final RevenueCatEnvConfig _config;
  final TargetPlatform? _platformOverride;
  final _logger = const Logger('FlightUnlockRepository');
  final StreamController<int> _balanceController =
      StreamController<int>.broadcast();

  int _currentUnusedUnlockCount = 0;
  bool _initialized = false;

  @override
  Stream<int> get balanceStream => _balanceController.stream;

  @override
  int get currentUnusedUnlockCount => _currentUnusedUnlockCount;

  @override
  Future<int> initialize() async {
    if (_initialized) return _currentUnusedUnlockCount;
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_unusedUnlockCountKey) ?? 0;
    _currentUnusedUnlockCount = count < 0 ? 0 : count;
    _initialized = true;
    _publish();
    return _currentUnusedUnlockCount;
  }

  @override
  Future<FlightUnlockProduct?> getUnlockProduct() async {
    await initialize();
    final productId = _config.flightUnlockProductIdForCurrentPlatform(
      platform: _platformOverride,
    );
    if (productId.isEmpty) {
      _logger.error(
        'RevenueCat flight unlock product ID is missing for this platform. '
        'Set RC_UNLOCK_FLIGHT_PRODUCT_ID_IOS / RC_UNLOCK_FLIGHT_PRODUCT_ID_ANDROID.',
      );
      return null;
    }

    try {
      final product = await _client.getNonSubscriptionProduct(
        productId: productId,
      );
      if (product == null) return null;
      return FlightUnlockProduct(
        productId: product.productId,
        title: product.title,
        priceText: product.priceText,
        description: product.description,
      );
    } catch (e) {
      _logger.error('Failed to load flight unlock product "$productId": $e');
      return null;
    }
  }

  @override
  Future<FlightUnlockPurchaseResult> purchaseUnlock() async {
    await initialize();
    final productId = _config.flightUnlockProductIdForCurrentPlatform(
      platform: _platformOverride,
    );
    if (productId.isEmpty) {
      return const FlightUnlockPurchaseResult.error();
    }

    try {
      await _client.purchaseNonSubscriptionProduct(productId: productId);
      await _setBalance(_currentUnusedUnlockCount + 1);
      return const FlightUnlockPurchaseResult.purchased();
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return const FlightUnlockPurchaseResult.cancelled();
      }
      _logger.error('Failed to purchase flight unlock "$productId": $e');
      return FlightUnlockPurchaseResult.error(message: e.message);
    } catch (e) {
      _logger.error('Failed to purchase flight unlock "$productId": $e');
      return FlightUnlockPurchaseResult.error(message: e.toString());
    }
  }

  @override
  Future<int> consumeUnlock() async {
    await initialize();
    final next = _currentUnusedUnlockCount <= 0
        ? 0
        : _currentUnusedUnlockCount - 1;
    await _setBalance(next);
    return _currentUnusedUnlockCount;
  }

  @override
  Future<int> restoreUnlock() async {
    await initialize();
    await _setBalance(_currentUnusedUnlockCount + 1);
    return _currentUnusedUnlockCount;
  }

  @override
  Future<void> close() async {
    await _balanceController.close();
  }

  Future<void> _setBalance(int value) async {
    final normalized = value < 0 ? 0 : value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_unusedUnlockCountKey, normalized);
    _currentUnusedUnlockCount = normalized;
    _publish();
  }

  void _publish() {
    if (_balanceController.isClosed) return;
    _balanceController.add(_currentUnusedUnlockCount);
  }
}
