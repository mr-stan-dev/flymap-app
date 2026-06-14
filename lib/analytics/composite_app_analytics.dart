import 'dart:async';

import 'package:flymap/analytics/app_analytics.dart';
import 'package:flymap/analytics/app_analytics_context.dart';
import 'package:flymap/analytics/app_analytics_identity.dart';

class CompositeAppAnalytics
    implements
        AppAnalytics,
        InitializableAppAnalytics,
        UserIdentifyingAppAnalytics {
  CompositeAppAnalytics({required List<AppAnalytics> sinks}) : _sinks = sinks;

  final List<AppAnalytics> _sinks;

  @override
  Future<void> initialize() async {
    await Future.wait(
      _sinks.whereType<InitializableAppAnalytics>().map(
        (sink) => _runSafely(sink.initialize),
      ),
    );
  }

  @override
  Future<void> setGlobalContext({
    required String appVersion,
    required String buildNumber,
    required String platform,
    required String appEnv,
  }) async {
    await Future.wait(
      _sinks.map(
        (sink) => _runSafely(
          () => sink.setGlobalContext(
            appVersion: appVersion,
            buildNumber: buildNumber,
            platform: platform,
            appEnv: appEnv,
          ),
        ),
      ),
    );
  }

  @override
  Future<void> setSubscriptionContext({required bool isPro}) async {
    await Future.wait(
      _sinks.map(
        (sink) => _runSafely(() => sink.setSubscriptionContext(isPro: isPro)),
      ),
    );
  }

  @override
  Future<void> identifyUser({
    required String userId,
    required AppAnalyticsGlobalContext context,
    Map<String, Object> properties = const <String, Object>{},
    Map<String, Object> setOnceProperties = const <String, Object>{},
  }) async {
    await Future.wait(
      _sinks.whereType<UserIdentifyingAppAnalytics>().map(
        (sink) => _runSafely(
          () => sink.identifyUser(
            userId: userId,
            context: context,
            properties: properties,
            setOnceProperties: setOnceProperties,
          ),
        ),
      ),
    );
  }

  @override
  Future<void> log(AnalyticsEvent event) async {
    await Future.wait(_sinks.map((sink) => _runSafely(() => sink.log(event))));
  }

  Future<void> _runSafely(FutureOr<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Analytics must never block product flows.
    }
  }
}
