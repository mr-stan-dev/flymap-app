import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flymap/analytics/app_analytics.dart';
import 'package:flymap/analytics/app_analytics_context.dart';
import 'package:flymap/analytics/app_analytics_identity.dart';
import 'package:flymap/auth/app_auth_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppAnalyticsInitializer {
  const AppAnalyticsInitializer({
    required AppAnalytics analytics,
    required AppAuthRepository authRepository,
    required AppAnalyticsContextStore contextStore,
    bool authIdentityEnabled = kReleaseMode,
  }) : _analytics = analytics,
       _authRepository = authRepository,
       _contextStore = contextStore,
       _authIdentityEnabled = authIdentityEnabled;

  final AppAnalytics _analytics;
  final AppAuthRepository _authRepository;
  final AppAnalyticsContextStore _contextStore;
  final bool _authIdentityEnabled;

  Future<void> initialize() async {
    final analyticsEnabled = kReleaseMode;
    var appVersion = 'unknown';
    var buildNumber = '0';
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    } catch (_) {
      // Keep startup non-blocking if package info is unavailable.
    }

    final context = AppAnalyticsGlobalContext(
      appVersion: appVersion,
      buildNumber: buildNumber,
      platform: defaultTargetPlatform.name,
      appEnv: kReleaseMode
          ? 'release'
          : kProfileMode
          ? 'profile'
          : 'debug',
    );
    _contextStore.setGlobal(context);

    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(
      analyticsEnabled,
    );

    if (_analytics is InitializableAppAnalytics) {
      await (_analytics as InitializableAppAnalytics).initialize();
    }

    await _analytics.setGlobalContext(
      appVersion: context.appVersion,
      buildNumber: context.buildNumber,
      platform: context.platform,
      appEnv: context.appEnv,
    );

    if (!_authIdentityEnabled) return;

    final userId = await _authRepository.initialize();
    if (userId != null &&
        userId.trim().isNotEmpty &&
        _analytics is UserIdentifyingAppAnalytics) {
      await (_analytics as UserIdentifyingAppAnalytics).identifyUser(
        userId: userId,
        context: context,
      );
    }
  }
}
