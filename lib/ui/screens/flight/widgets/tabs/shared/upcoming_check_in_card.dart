import 'package:flutter/material.dart';
import 'package:flymap/i18n/strings.g.dart';

class UpcomingCheckInCard extends StatelessWidget {
  const UpcomingCheckInCard({
    required this.onCheckInPressed,
    required this.title,
    required this.subtitle,
    this.horizontalPadding = 12,
    super.key,
  });

  final VoidCallback onCheckInPressed;
  final String title;
  final String subtitle;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Card(
        margin: EdgeInsets.zero,
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: onCheckInPressed,
                child: Text(context.t.flight.upcoming.checkInButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
