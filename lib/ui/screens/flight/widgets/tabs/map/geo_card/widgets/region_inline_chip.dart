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
    super.key,
  });

  final RouteRegion region;
  final bool isLocked;
  final VoidCallback onTap;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgAlpha = isNext ? 0.82 : 1.0;
    final textAlpha = isNext ? 0.9 : 1.0;

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
                isLocked
                    ? context.t.flight.route.premiumLockedChipLabel
                    : region.name,
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
}
