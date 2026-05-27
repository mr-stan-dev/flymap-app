import 'package:flutter/material.dart';
import 'package:flymap/domain/entity/airport.dart';
import 'package:flymap/ui/screens/shared/airport_artwork.dart';

class AirportInlineChip extends StatelessWidget {
  const AirportInlineChip({
    required this.airport,
    this.isNext = false,
    super.key,
  });

  final Airport airport;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgAlpha = isNext ? 0.82 : 1.0;
    final textAlpha = isNext ? 0.9 : 1.0;

    return Material(
      color: colorScheme.surfaceContainerLow.withValues(alpha: bgAlpha),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 4, 8, 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AirportArtwork(
              size: 18,
              borderRadius: 4,
              isCircle: true,
              showCountryBadge: false,
            ),
            const SizedBox(width: 6),
            Text(
              airport.nameShort,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: textAlpha),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
