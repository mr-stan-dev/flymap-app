import 'package:flutter/material.dart';
import 'package:flymap/ui/design_system/design_system.dart';

class SearchFallbackAction extends StatelessWidget {
  const SearchFallbackAction({
    required this.message,
    required this.actionLabel,
    required this.onPressed,
    this.title,
    super.key,
  });

  final String? title;
  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (title != null) ...[
          Text(
            title!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
        ],
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        TertiaryButton(
          label: actionLabel,
          onPressed: onPressed,
          expand: false,
        ),
      ],
    );
  }
}
