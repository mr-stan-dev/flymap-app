import 'package:flutter/material.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/design_system/design_system.dart';

class CompleteFlightDialogResult {
  const CompleteFlightDialogResult({required this.deleteOfflineData});

  final bool deleteOfflineData;
}

class CompleteFlightConfirmationDialog extends StatefulWidget {
  const CompleteFlightConfirmationDialog({super.key});

  static Future<CompleteFlightDialogResult?> show(BuildContext context) {
    return showDialog<CompleteFlightDialogResult>(
      context: context,
      builder: (_) => const CompleteFlightConfirmationDialog(),
    );
  }

  @override
  State<CompleteFlightConfirmationDialog> createState() =>
      _CompleteFlightConfirmationDialogState();
}

class _CompleteFlightConfirmationDialogState
    extends State<CompleteFlightConfirmationDialog> {
  bool _deleteOfflineData = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.t.flight.completeDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.t.flight.completeDialogBody),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: _deleteOfflineData,
            onChanged: (value) =>
                setState(() => _deleteOfflineData = value ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(context.t.flight.completeDialogDeleteOffline),
          ),
        ],
      ),
      actions: [
        SecondaryButton(
          label: context.t.common.cancel,
          onPressed: () => Navigator.of(context).pop(),
          expand: false,
        ),
        PrimaryButton(
          label: context.t.flight.completeDialogConfirm,
          onPressed: () => Navigator.of(context).pop(
            CompleteFlightDialogResult(deleteOfflineData: _deleteOfflineData),
          ),
          expand: false,
        ),
      ],
    );
  }
}
