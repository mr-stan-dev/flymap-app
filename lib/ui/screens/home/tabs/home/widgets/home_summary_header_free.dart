import 'package:flutter/material.dart';
import 'package:flymap/i18n/strings.g.dart';

class HomeSummaryHeaderFree extends StatelessWidget {
  const HomeSummaryHeaderFree({
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
    final radius = BorderRadius.circular(20);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.15),
            colorScheme.primary.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _resolveWelcomeTitle(context),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
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
