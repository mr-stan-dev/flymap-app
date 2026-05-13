import 'package:flutter/material.dart';
import 'package:flymap/ui/design_system/design_system.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/instruments/instrument_shell.dart';

class InstrumentValueScaleColumn extends StatelessWidget {
  const InstrumentValueScaleColumn({
    required this.title,
    required this.value,
    required this.scale,
    super.key,
  });

  final String title;
  final Widget value;
  final Widget scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PanelLabel(title),
        const SizedBox(height: DsSpacing.sm),
        value,
        const SizedBox(height: DsSpacing.sm),
        Expanded(child: scale),
      ],
    );
  }
}
