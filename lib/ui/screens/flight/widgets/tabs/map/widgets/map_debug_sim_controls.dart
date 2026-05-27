import 'package:flutter/material.dart';

class MapDebugSimControls extends StatelessWidget {
  const MapDebugSimControls({
    required this.isPlaying,
    required this.speedMultiplier,
    required this.onTogglePlayPause,
    required this.onRestart,
    required this.onSpeedSelected,
    super.key,
  });

  final bool isPlaying;
  final int speedMultiplier;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onRestart;
  final ValueChanged<int> onSpeedSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onTogglePlayPause,
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  iconSize: 20,
                  tooltip: isPlaying ? 'Pause simulation' : 'Play simulation',
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  onPressed: onRestart,
                  icon: const Icon(Icons.replay),
                  iconSize: 20,
                  tooltip: 'Restart simulation',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: const [1, 5, 10, 20]
                  .map(
                    (speed) => _SpeedChipData(speed: speed, label: 'x$speed'),
                  )
                  .map(
                    (entry) => ChoiceChip(
                      label: Text(entry.label),
                      selected: speedMultiplier == entry.speed,
                      onSelected: (_) => onSpeedSelected(entry.speed),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeedChipData {
  const _SpeedChipData({required this.speed, required this.label});

  final int speed;
  final String label;
}
