import 'package:flutter/material.dart';
import 'package:flymap/ui/design_system/design_system.dart';

class TimelinePremiumGateCard extends StatelessWidget {
  const TimelinePremiumGateCard({
    required this.title,
    required this.description,
    required this.ctaLabel,
    required this.onTap,
    super.key,
  });

  final String title;
  final String description;
  final String ctaLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          PremiumButton(
            label: ctaLabel,
            onPressed: onTap,
            trailingIcon: Icons.arrow_forward_rounded,
          ),
        ],
      ),
    );
  }
}
