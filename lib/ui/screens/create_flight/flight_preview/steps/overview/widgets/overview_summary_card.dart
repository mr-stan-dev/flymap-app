import 'package:flutter/material.dart';
import 'package:flymap/ui/design_system/design_system.dart';
import 'package:flymap/ui/theme/app_colours.dart';

class OverviewSummaryCard extends StatelessWidget {
  const OverviewSummaryCard({
    required this.title,
    required this.subtitle,
    required this.fullSummaryLabel,
    required this.onFullSummary,
    required this.continueLabel,
    required this.onContinue,
    super.key,
  });

  final String title;
  final String subtitle;
  final String fullSummaryLabel;
  final VoidCallback onFullSummary;
  final String continueLabel;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColoursCommon.success.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: AppColoursCommon.brandWhite,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              PrimaryButton(
                label: continueLabel,
                onPressed: onContinue,
                expand: true,
              ),
              const SizedBox(height: 4),
              TertiaryButton(
                label: fullSummaryLabel,
                onPressed: onFullSummary,
                compact: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
