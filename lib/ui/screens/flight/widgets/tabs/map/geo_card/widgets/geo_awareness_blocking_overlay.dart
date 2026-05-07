import 'package:flutter/material.dart';

class GeoAwarenessBlockingOverlay extends StatelessWidget {
  const GeoAwarenessBlockingOverlay({
    required this.child,
    required this.enabled,
    required this.message,
    super.key,
  });

  final Widget child;
  final bool enabled;
  final String message;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: true,
          child: Opacity(opacity: 0.35, child: child),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
