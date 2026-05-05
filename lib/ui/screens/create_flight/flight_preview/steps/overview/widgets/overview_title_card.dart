import 'package:flutter/material.dart';
import 'package:flymap/ui/design_system/design_system.dart';

class OverviewTitleCard extends StatelessWidget {
  const OverviewTitleCard({
    required this.routeTitleLabel,
    required this.routeCodeLine,
    required this.routeCitiesLine,
    required this.routeMetaLine,
    required this.reviewRouteLabel,
    required this.onReviewRoute,
    required this.skipReviewLabel,
    required this.onSkipReview,
    super.key,
  });

  final String routeTitleLabel;
  final String routeCodeLine;
  final String routeCitiesLine;
  final String routeMetaLine;
  final String reviewRouteLabel;
  final VoidCallback onReviewRoute;
  final String skipReviewLabel;
  final VoidCallback onSkipReview;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text(
              routeCodeLine,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              routeCitiesLine,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Text(
              routeMetaLine,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            Spacer(),
            const SizedBox(height: 16),
            PrimaryButton(label: reviewRouteLabel, onPressed: onReviewRoute, expand: true),
            const SizedBox(height: 4),
            TertiaryButton(label: skipReviewLabel, onPressed: onSkipReview, expand: true),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
