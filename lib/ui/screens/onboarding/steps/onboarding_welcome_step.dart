import 'package:flutter/material.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/screens/onboarding/widgets/onboarding_step_scaffold.dart';
import 'package:flymap/ui/screens/onboarding/widgets/onboarding_window_image.dart';

class OnboardingWelcomeStep extends StatelessWidget {
  const OnboardingWelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return OnboardingStepScaffold(
      title: context.t.onboarding.welcomeTitle,
      centerHeader: true,
      body: Column(
        children: [
          const SizedBox(height: 16),
          const OnboardingWindowImage(
            assetPath: 'assets/images/onboarding2.webp',
          ),
          const SizedBox(height: 24),
          Text.rich(
            TextSpan(
              text: '${context.t.appName} ',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: context.t.onboarding.welcomeSubtitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
