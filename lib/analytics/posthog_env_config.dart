import 'package:flutter/foundation.dart';

class PostHogEnvConfig {
  const PostHogEnvConfig({
    required this.enabled,
    required this.projectToken,
    required this.host,
  });

  factory PostHogEnvConfig.fromEnvironment() {
    return const PostHogEnvConfig(
      enabled: bool.fromEnvironment(
        'POSTHOG_ENABLED',
        defaultValue: kReleaseMode,
      ),
      projectToken: String.fromEnvironment('POSTHOG_PROJECT_TOKEN'),
      host: String.fromEnvironment(
        'POSTHOG_HOST',
        defaultValue: 'https://us.i.posthog.com',
      ),
    );
  }

  final bool enabled;
  final String projectToken;
  final String host;

  bool get isConfigured =>
      enabled && projectToken.trim().isNotEmpty && host.trim().isNotEmpty;
}
