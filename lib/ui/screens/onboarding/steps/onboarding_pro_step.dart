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
        ],
      ),
    );
  }
}
