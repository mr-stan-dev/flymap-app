import 'package:flutter/material.dart';
import 'package:flymap/ui/design_system/design_system.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/instruments/instrument_palette.dart';

class InstrumentPanel extends StatelessWidget {
  const InstrumentPanel({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = InstrumentPalette.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DsSpacing.md),
      decoration: BoxDecoration(
        color: palette.panel,
        borderRadius: BorderRadius.circular(DsRadii.md),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class PanelLabel extends StatelessWidget {
  const PanelLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = InstrumentPalette.of(context);
    return Text(
      text.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: palette.secondaryText,
        fontWeight: FontWeight.w900,
        fontFamily: 'monospace',
      ),
    );
  }
}

TextStyle? instrumentUnitStyle(BuildContext context, Color color) {
  return Theme.of(context).textTheme.labelLarge?.copyWith(
    color: color,
    fontWeight: FontWeight.w900,
    fontFamily: 'monospace',
  );
}
