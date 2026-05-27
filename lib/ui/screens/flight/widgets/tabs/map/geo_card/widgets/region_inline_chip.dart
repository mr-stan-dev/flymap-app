import 'package:flutter/material.dart';
import 'package:flymap/domain/entity/route_region.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/screens/shared/region_artwork.dart';

class RegionInlineChip extends StatelessWidget {
  const RegionInlineChip({
    required this.region,
    required this.isLocked,
    required this.onTap,
    this.isNext = false,
    this.nextRegionEtaMinutes,
    super.key,
  });

  final RouteRegion region;
  final bool isLocked;
  final VoidCallback onTap;
  final bool isNext;
  final int? nextRegionEtaMinutes;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgAlpha = isNext ? 0.82 : 1.0;
    final textAlpha = isNext ? 0.9 : 1.0;
    final label = isLocked
        ? context.t.flight.route.premiumLockedChipLabel
        : _buildRegionLabel(context);

    return Material(
      color: colorScheme.surfaceContainerLow.withValues(alpha: bgAlpha),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 4, 8, 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLocked)
                Icon(
                  Icons.lock_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )
              else
                RegionArtwork(
                  regionName: region.name,
                  regionType: region.regionType,
                  size: 18,
                  borderRadius: 4,
                  isCircle: true,
                ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: textAlpha),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildRegionLabel(BuildContext context) {
    final suffix = _formatNextRegionEtaLabel(context);
    if (suffix == null) {
      return region.name;
    }
    return '${region.name} ($suffix)';
  }

  String? _formatNextRegionEtaLabel(BuildContext context) {
    final minutesRaw = nextRegionEtaMinutes;
    if (minutesRaw == null) return null;

    final minutes = minutesRaw.clamp(0, 99999).toInt();
    final timelineT = context.t.createFlight.overview.timeline;
    final timeLabel = switch (minutes) {
      < 60 => '$minutes ${timelineT.minuteUnit}',
      _ => _formatHoursAndMinutes(
        totalMinutes: minutes,
        hourUnit: timelineT.hourCompactUnit,
        minuteUnit: timelineT.minuteCompactUnit,
      ),
    };
    return context.t.flight.route.etaInLabel(time: timeLabel);
  }

  String _formatHoursAndMinutes({
    required int totalMinutes,
    required String hourUnit,
    required String minuteUnit,
  }) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (minutes == 0) {
      return '$hours$hourUnit';
    }
    return '$hours$hourUnit $minutes$minuteUnit';
  }
}
