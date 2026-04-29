import 'package:flutter/material.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/design_system/tokens/ds_brand_colors.dart';
import 'package:flymap/ui/design_system/tokens/ds_radii.dart';
import 'package:flymap/ui/design_system/tokens/ds_spacing.dart';

class HomeSummaryHeaderPro extends StatelessWidget {
  const HomeSummaryHeaderPro({
    required this.displayName,
    required this.hasInternet,
    super.key,
  });

  final String displayName;
  final bool hasInternet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius = BorderRadius.circular(DsRadii.xl);
    final gradientColors = [
      colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
      DsBrandColors.proAmber.withValues(
        alpha: theme.brightness == Brightness.light ? 0.16 : 0.22,
      ),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        border: Border.all(
          color: DsBrandColors.proAmber.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DsSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: DsBrandColors.proAmber.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: DsBrandColors.proAmber,
                    size: 20,
                  ),
                ),
                const SizedBox(width: DsSpacing.sm),
                Expanded(
                  child: Text(
                    _resolveWelcomeTitle(context),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _resolveWelcomeTitle(BuildContext context) {
    final trimmedName = displayName.trim();
    if (trimmedName.isNotEmpty) {
      return hasInternet
          ? context.t.home.greetingOnlineWithName(name: trimmedName)
          : context.t.home.greetingOfflineWithName(name: trimmedName);
    }
    return hasInternet
        ? context.t.home.greetingOnline
        : context.t.home.greetingOffline;
  }
}
