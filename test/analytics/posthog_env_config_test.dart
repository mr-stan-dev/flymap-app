import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/analytics/posthog_env_config.dart';

void main() {
  group('PostHogEnvConfig', () {
    test('is configured when enabled with token and host', () {
      const config = PostHogEnvConfig(
        enabled: true,
        projectToken: 'token',
        host: 'https://us.i.posthog.com',
      );

      expect(config.isConfigured, isTrue);
    });

    test('is disabled when flag is false', () {
      const config = PostHogEnvConfig(
        enabled: false,
        projectToken: 'token',
        host: 'https://us.i.posthog.com',
      );

      expect(config.isConfigured, isFalse);
    });

    test('is disabled when token or host is blank', () {
      const missingToken = PostHogEnvConfig(
        enabled: true,
        projectToken: '',
        host: 'https://us.i.posthog.com',
      );
      const missingHost = PostHogEnvConfig(
        enabled: true,
        projectToken: 'token',
        host: '',
      );

      expect(missingToken.isConfigured, isFalse);
      expect(missingHost.isConfigured, isFalse);
    });
  });
}
