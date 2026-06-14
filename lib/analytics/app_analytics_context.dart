class AppAnalyticsGlobalContext {
  const AppAnalyticsGlobalContext({
    required this.appVersion,
    required this.buildNumber,
    required this.platform,
    required this.appEnv,
  });

  final String appVersion;
  final String buildNumber;
  final String platform;
  final String appEnv;

  static const unknown = AppAnalyticsGlobalContext(
    appVersion: 'unknown',
    buildNumber: '0',
    platform: 'unknown',
    appEnv: 'unknown',
  );

  Map<String, Object> toAnalyticsProperties() {
    return <String, Object>{
      'app_version': appVersion,
      'build_number': buildNumber,
      'platform': platform,
      'app_env': appEnv,
    };
  }

  Map<String, String> toRevenueCatAttributes({
    required String firebaseUid,
    required String posthogDistinctId,
  }) {
    return <String, String>{
      'firebase_uid': firebaseUid,
      'posthog_distinct_id': posthogDistinctId,
      'app_version': appVersion,
      'platform': platform,
    };
  }
}

class AppAnalyticsContextStore {
  AppAnalyticsGlobalContext _global = AppAnalyticsGlobalContext.unknown;

  AppAnalyticsGlobalContext get global => _global;

  void setGlobal(AppAnalyticsGlobalContext context) {
    _global = context;
  }
}
