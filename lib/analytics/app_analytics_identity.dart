import 'package:flymap/analytics/app_analytics_context.dart';

abstract class InitializableAppAnalytics {
  Future<void> initialize();
}

abstract class UserIdentifyingAppAnalytics {
  Future<void> identifyUser({
    required String userId,
    required AppAnalyticsGlobalContext context,
    Map<String, Object> properties = const <String, Object>{},
    Map<String, Object> setOnceProperties = const <String, Object>{},
  });
}
