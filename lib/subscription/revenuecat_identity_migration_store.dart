import 'package:flymap/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class RevenueCatIdentityMigrationStore {
  Future<bool> hasSyncedPurchasesForUser(String appUserId);

  Future<void> markSyncedPurchasesForUser(String appUserId);
}

class SharedPrefsRevenueCatIdentityMigrationStore
    implements RevenueCatIdentityMigrationStore {
  SharedPrefsRevenueCatIdentityMigrationStore();

  static const _keyPrefix = 'subscription.revenuecat_identity_sync.v1';
  final _logger = const Logger('RevenueCatIdentityMigrationStore');

  @override
  Future<bool> hasSyncedPurchasesForUser(String appUserId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyFor(appUserId)) ?? false;
    } catch (e) {
      _logger.error('Failed to read RevenueCat migration marker: $e');
      return false;
    }
  }

  @override
  Future<void> markSyncedPurchasesForUser(String appUserId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyFor(appUserId), true);
    } catch (e) {
      _logger.error('Failed to persist RevenueCat migration marker: $e');
    }
  }

  String _keyFor(String appUserId) => '$_keyPrefix.$appUserId';
}
