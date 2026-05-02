import 'package:flutter/material.dart';
import 'package:flymap/ui/design_system/design_system.dart';

class OverviewTitleCard extends StatelessWidget {
  const OverviewTitleCard({
    required this.routeTitleLabel,
    required this.routeCodeLine,
    required this.routeCitiesLine,
    required this.routeMetaLine,
    required this.startLabel,
    required this.onStart,
    super.key,
  });

  final String routeTitleLabel;
  final String routeCodeLine;
  final String routeCitiesLine;
  final String routeMetaLine;
  final String startLabel;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              routeTitleLabel,
              style: Theme.of(context).textTheme.labelLarge,
            ),
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
            const SizedBox(height: 12),
            SecondaryButton(label: startLabel, onPressed: onStart, expand: false),
          ],
        ),
      ),
    );
  }
}
