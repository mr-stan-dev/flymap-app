import 'package:flutter/material.dart';
import 'package:flymap/ui/design_system/design_system.dart';

class OverviewSummaryCard extends StatelessWidget {
  const OverviewSummaryCard({
    required this.title,
    required this.chipLabels,
    required this.fullSummaryLabel,
    required this.onFullSummary,
    super.key,
  });

  final String title;
  final List<String> chipLabels;
  final String fullSummaryLabel;
  final VoidCallback onFullSummary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chipLabels
                    .map((label) => _TypeCountChip(label: label))
                    .toList(),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: TertiaryButton(
                  label: fullSummaryLabel,
                  onPressed: onFullSummary,
                  expand: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeCountChip extends StatelessWidget {
  const _TypeCountChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
