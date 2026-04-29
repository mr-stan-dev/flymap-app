import 'package:flutter/material.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/theme/app_theme_ext.dart';

class HomeFlightsSectionHeader extends StatelessWidget {
  const HomeFlightsSectionHeader({
    required this.count,
    required this.onViewAll,
    super.key,
  });

  final int count;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.t.home.upcomingFlightsCount(count: count),
            style: context.textTheme.button18Bold,
          ),
        ),
        TextButton.icon(
          onPressed: onViewAll,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.chevron_right, size: 18),
          label: Text(context.t.home.viewAll),
        ),
      ],
    );
  }
}
