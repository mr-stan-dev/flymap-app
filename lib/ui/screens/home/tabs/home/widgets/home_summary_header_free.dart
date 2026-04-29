import 'package:flutter/material.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/screens/home/tabs/home/viewmodel/home_tab_state.dart';

class HomeSummaryHeaderFree extends StatelessWidget {
  const HomeSummaryHeaderFree({
    required this.statistics,
    required this.displayName,
    required this.hasInternet,
    super.key,
  });

  final FlightStatistics statistics;
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
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FreeSummaryPill(
                  icon: Icons.flight,
                  label: context.t.home.totalFlights,
                  value: '${statistics.totalFlights}',
                ),
                _FreeSummaryPill(
                  icon: Icons.route,
                  label: context.t.home.totalDistance,
                  value: '${statistics.formattedTotalDistanceKm} km',
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

class _FreeSummaryPill extends StatelessWidget {
  const _FreeSummaryPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
