import 'package:flutter/material.dart';

/// The visual chip representation used in geo-awareness overlays.
class GeoChipView extends StatelessWidget {
  const GeoChipView({
    required this.icon,
    required this.label,
    required this.isCurrent,
    this.extraRegionsCounter,
    this.chevron = false,
    this.chevronExpanded = false,
    this.onTap,
    this.onSecondaryTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool isCurrent;
  final String? extraRegionsCounter;
  final bool chevron;
  final bool chevronExpanded;
  final VoidCallback? onTap;
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final chipColor = isCurrent
        ? colorScheme.primary.withValues(alpha: 0.15)
        : colorScheme.surfaceContainerHigh.withValues(alpha: 0.85);
    final borderColor = isCurrent
        ? colorScheme.primary.withValues(alpha: 0.4)
        : colorScheme.outlineVariant.withValues(alpha: 0.5);
    final textColor = isCurrent
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main interactive part (Icon + Label)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: textColor),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: textColor,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Secondary interactive part (Badge + Chevron)
          if (extraRegionsCounter != null || chevron)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onSecondaryTap ?? onTap,
              child: Padding(
                padding: const EdgeInsets.only(left: 2, right: 6, top: 2, bottom: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (extraRegionsCounter != null) ...[
                      const SizedBox(width: 2),
                      Visibility(
                        visible: !chevronExpanded,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            extraRegionsCounter!,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (chevron) ...[
                      const SizedBox(width: 2),
                      AnimatedRotation(
                        turns: chevronExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        child: Icon(
                          Icons.expand_more_rounded,
                          size: 16,
                          color: textColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
