import 'package:flutter/material.dart';
import 'package:flymap/ui/design_system/design_system.dart';

class OverviewTitleCard extends StatelessWidget {
  const OverviewTitleCard({
    required this.routeCodeLine,
    required this.routeCitiesLine,
    required this.distanceLabel,
    required this.distanceValue,
    required this.durationLabel,
    required this.durationValue,
    required this.reviewRouteLabel,
    required this.onReviewRoute,
    required this.skipReviewLabel,
    required this.onSkipReview,
    super.key,
  });

  final String routeCodeLine;
  final String routeCitiesLine;
  final String distanceLabel;
  final String distanceValue;
  final String durationLabel;
  final String durationValue;
  final String reviewRouteLabel;
  final VoidCallback onReviewRoute;
  final String skipReviewLabel;
  final VoidCallback onSkipReview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                routeCodeLine,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                routeCitiesLine,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _IntroStat(
                      label: distanceLabel,
                      value: distanceValue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _IntroStat(
                      label: durationLabel,
                      value: durationValue,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              PrimaryButton(
                label: reviewRouteLabel,
                onPressed: onReviewRoute,
                expand: true,
                trailingIcon: Icons.arrow_forward_rounded,
              ),
              const SizedBox(height: 4),
              TertiaryButton(
                label: skipReviewLabel,
                onPressed: onSkipReview,
                compact: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroStat extends StatelessWidget {
  const _IntroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
