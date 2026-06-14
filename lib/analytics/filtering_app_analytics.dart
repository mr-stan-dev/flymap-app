import 'package:flymap/analytics/app_analytics.dart';
import 'package:flymap/analytics/app_analytics_context.dart';
import 'package:flymap/analytics/app_analytics_identity.dart';

abstract class AppAnalyticsEventFilter {
  const AppAnalyticsEventFilter();

  bool allows(AnalyticsEvent event);
}

class FilteringAppAnalytics
    implements
        AppAnalytics,
        InitializableAppAnalytics,
        UserIdentifyingAppAnalytics {
  const FilteringAppAnalytics({
    required AppAnalytics delegate,
    required AppAnalyticsEventFilter eventFilter,
  }) : _delegate = delegate,
       _eventFilter = eventFilter;

  final AppAnalytics _delegate;
  final AppAnalyticsEventFilter _eventFilter;

  @override
  Future<void> initialize() async {
    if (_delegate is InitializableAppAnalytics) {
      await (_delegate as InitializableAppAnalytics).initialize();
    }
  }

  @override
  Future<void> identifyUser({
    required String userId,
    required AppAnalyticsGlobalContext context,
    Map<String, Object> properties = const <String, Object>{},
    Map<String, Object> setOnceProperties = const <String, Object>{},
  }) async {
    if (_delegate is UserIdentifyingAppAnalytics) {
      await (_delegate as UserIdentifyingAppAnalytics).identifyUser(
        userId: userId,
        context: context,
        properties: properties,
        setOnceProperties: setOnceProperties,
      );
    }
  }

  @override
  Future<void> log(AnalyticsEvent event) async {
    if (!_eventFilter.allows(event)) return;
    await _delegate.log(event);
  }

  @override
  Future<void> setGlobalContext({
    required String appVersion,
    required String buildNumber,
    required String platform,
    required String appEnv,
  }) async {
    await _delegate.setGlobalContext(
      appVersion: appVersion,
      buildNumber: buildNumber,
      platform: platform,
      appEnv: appEnv,
    );
  }

  @override
  Future<void> setSubscriptionContext({required bool isPro}) async {
    await _delegate.setSubscriptionContext(isPro: isPro);
  }
}
