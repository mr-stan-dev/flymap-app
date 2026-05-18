import 'package:flutter/foundation.dart';

class RevenueCatEnvConfig {
  const RevenueCatEnvConfig({
    this.iosApiKey = '',
    this.androidApiKey = '',
    this.entitlementPro = 'Flymap Pro',
    this.weeklyPackageId = 'weekly',
    this.monthlyPackageId = 'monthly',
    this.yearlyPackageId = 'yearly',
    this.iosFlightUnlockProductId = '',
    this.androidFlightUnlockProductId = '',
  });

  factory RevenueCatEnvConfig.fromEnvironment() {
    return const RevenueCatEnvConfig(
      iosApiKey: String.fromEnvironment('RC_API_KEY_IOS', defaultValue: ''),
      androidApiKey: String.fromEnvironment(
        'RC_API_KEY_ANDROID',
        defaultValue: '',
      ),
      iosFlightUnlockProductId: String.fromEnvironment(
        'RC_UNLOCK_FLIGHT_PRODUCT_ID_IOS',
        defaultValue: '',
      ),
      androidFlightUnlockProductId: String.fromEnvironment(
        'RC_UNLOCK_FLIGHT_PRODUCT_ID_ANDROID',
        defaultValue: '',
      ),
    );
  }

  final String iosApiKey;
  final String androidApiKey;
  final String entitlementPro;
  final String weeklyPackageId;
  final String monthlyPackageId;
  final String yearlyPackageId;
  final String iosFlightUnlockProductId;
  final String androidFlightUnlockProductId;

  String get entitlementId {
    final value = entitlementPro.trim();
    return value.isEmpty ? 'Flymap Pro' : value;
  }

  List<String> get packageIdsInDisplayOrder {
    return [
      weeklyPackageId.trim(),
      monthlyPackageId.trim(),
      yearlyPackageId.trim(),
    ].where((id) => id.isNotEmpty).toList();
  }

  String apiKeyForPlatform(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.iOS:
        return iosApiKey.trim();
      case TargetPlatform.android:
        return androidApiKey.trim();
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return '';
    }
  }

  String apiKeyForCurrentPlatform({TargetPlatform? platform}) {
    return apiKeyForPlatform(platform ?? defaultTargetPlatform);
  }

  String flightUnlockProductIdForPlatform(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.iOS:
        return iosFlightUnlockProductId.trim();
      case TargetPlatform.android:
        return androidFlightUnlockProductId.trim();
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return '';
    }
  }

  String flightUnlockProductIdForCurrentPlatform({TargetPlatform? platform}) {
    return flightUnlockProductIdForPlatform(platform ?? defaultTargetPlatform);
  }
}
