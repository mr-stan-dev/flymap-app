import 'package:flutter/material.dart';
import 'package:flymap/ui/theme/app_colours.dart';

class RouteOverviewProgressTimeline extends StatelessWidget {
  const RouteOverviewProgressTimeline({
    required this.itemCount,
    required this.selectedIndex,
    required this.isTitleActive,
    required this.isSummaryActive,
    super.key,
  });

  final int itemCount;
  final int selectedIndex;
  final bool isTitleActive;
  final bool isSummaryActive;

  @override
  Widget build(BuildContext context) {
    final safeCount = itemCount < 2 ? 2 : itemCount;
    final safeSelected = selectedIndex.clamp(0, safeCount - 1);
    final timelineBlue = AppColoursCommon.brandBlue;
    final currentGreen = AppColoursCommon.success;
    final futureColor = Theme.of(
      context,
    ).colorScheme.outline.withValues(alpha: 0.45);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final slot = width / safeCount;
          final firstCenter = slot * 0.5;
          final lastCenter = width - slot * 0.5;
          final currentCenter = firstCenter + slot * safeSelected;
          final titleMode = isTitleActive;
          final summaryMode = isSummaryActive;
          final showBlueLine = !titleMode;
          final blueLineRight = summaryMode
              ? (width - lastCenter)
              : (width - currentCenter);

          return SizedBox(
            height: 26,
            child: Stack(
              children: [
                Positioned(
                  left: firstCenter,
                  right: width - lastCenter,
                  top: 12,
                  child: Container(height: 2, color: futureColor),
                ),
                if (showBlueLine)
                  Positioned(
                    left: firstCenter,
                    right: blueLineRight,
                    top: 12,
                    child: Container(height: 2, color: timelineBlue),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(safeCount, (index) {
                    final isCurrent = index == safeSelected;
                    final isCompleted = index < safeSelected;
                    final color = summaryMode
                        ? timelineBlue
                        : titleMode
                        ? futureColor
                        : isCurrent
                        ? currentGreen
                        : isCompleted
                        ? timelineBlue
                        : futureColor;
                    return Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: isCurrent ? 12 : 10,
                          height: isCurrent ? 12 : 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.surface,
                            border: Border.all(
                              color: color,
                              width: isCurrent ? 2.4 : 2,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
