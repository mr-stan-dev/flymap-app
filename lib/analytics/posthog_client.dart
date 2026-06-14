import 'package:posthog_flutter/posthog_flutter.dart';

abstract class PostHogAnalyticsClient {
  Future<void> setup({
    required String projectToken,
    required String host,
    required bool debug,
    required bool captureApplicationLifecycleEvents,
  });

  Future<void> capture({
    required String eventName,
    Map<String, Object>? properties,
    Map<String, Object>? userProperties,
    Map<String, Object>? userPropertiesSetOnce,
  });

  Future<void> identify({
    required String userId,
    Map<String, Object>? userProperties,
    Map<String, Object>? userPropertiesSetOnce,
  });

  Future<void> setPersonProperties({
    Map<String, Object>? userPropertiesToSet,
    Map<String, Object>? userPropertiesToSetOnce,
  });
}

class PackagePostHogAnalyticsClient implements PostHogAnalyticsClient {
  PackagePostHogAnalyticsClient({Posthog? posthog})
    : _posthog = posthog ?? Posthog();

  final Posthog _posthog;
  bool _isSetup = false;

  @override
  Future<void> setup({
    required String projectToken,
    required String host,
    required bool debug,
    required bool captureApplicationLifecycleEvents,
  }) async {
    if (_isSetup) return;
    final config = PostHogConfig(projectToken);
    config.host = host;
    config.debug = debug;
    config.captureApplicationLifecycleEvents =
        captureApplicationLifecycleEvents;
    config.preloadFeatureFlags = false;
    config.sendFeatureFlagEvents = false;
    config.sessionReplay = false;
    config.personProfiles = PostHogPersonProfiles.identifiedOnly;
    await _posthog.setup(config);
    _isSetup = true;
  }

  @override
  Future<void> capture({
    required String eventName,
    Map<String, Object>? properties,
    Map<String, Object>? userProperties,
    Map<String, Object>? userPropertiesSetOnce,
  }) {
    return _posthog.capture(
      eventName: eventName,
      properties: properties,
      userProperties: userProperties,
      userPropertiesSetOnce: userPropertiesSetOnce,
    );
  }

  @override
  Future<void> identify({
    required String userId,
    Map<String, Object>? userProperties,
    Map<String, Object>? userPropertiesSetOnce,
  }) {
    return _posthog.identify(
      userId: userId,
      userProperties: userProperties,
      userPropertiesSetOnce: userPropertiesSetOnce,
    );
  }

  @override
  Future<void> setPersonProperties({
    Map<String, Object>? userPropertiesToSet,
    Map<String, Object>? userPropertiesToSetOnce,
  }) {
    return _posthog.setPersonProperties(
      userPropertiesToSet: userPropertiesToSet,
      userPropertiesToSetOnce: userPropertiesToSetOnce,
    );
  }
}
