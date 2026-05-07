import 'package:flutter/material.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/screens/onboarding/widgets/onboarding_step_scaffold.dart';

class OnboardingProStep extends StatelessWidget {
  const OnboardingProStep({
    required this.title,
    required this.isPro,
    super.key,
  });

  final String title;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final subtitle = isPro
        ? context.t.onboarding.proActiveSubtitle
        : context.t.onboarding.proStepSubtitle;

    return OnboardingStepScaffold(
      title: title,
      subtitle: subtitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox.square(
                dimension: 240,
                child: Image.asset('assets/images/logo_pro.webp'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ProFeatureItem(
            icon: Icons.map_rounded,
            text: context.t.onboarding.proFeatureMaps,
          ),
          const SizedBox(height: 12),
          _ProFeatureItem(
            icon: Icons.timeline,
            text: context.t.onboarding.proFeatureTimeline,
          ),
          const SizedBox(height: 12),
          _ProFeatureItem(
            icon: Icons.place_rounded,
            text: context.t.onboarding.proFeaturePlaces,
          ),
          const SizedBox(height: 12),
          _ProFeatureItem(
            icon: Icons.text_fields_rounded,
            text: context.t.onboarding.proFeatureArticles,
          ),
        ],
      ),
    );
  }
}

class _ProFeatureItem extends StatelessWidget {
  const _ProFeatureItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.3),
          ),
        ),
      ],
    );
  }
}
