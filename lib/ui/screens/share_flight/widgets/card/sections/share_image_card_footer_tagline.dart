import 'package:flutter/material.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/theme/app_theme_ext.dart';

class ShareImageCardFooterTagline extends StatelessWidget {
  const ShareImageCardFooterTagline({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final taglineStyle = context.textTheme.button18Bold.copyWith(
      color: const Color(0xFF47EFFF),
      fontFamily: 'Caveat',
      fontSize: 22,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      height: 1,
      letterSpacing: 0,
    );

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.white.withValues(alpha: 0.35),
            thickness: 0.8,
          ),
        ),
        const SizedBox(width: 14),
        Text(t.shareImage.tagline, style: taglineStyle),
        const SizedBox(width: 8),
        const Icon(
          Icons.favorite_border_rounded,
          size: 16,
          color: Color(0xFF47EFFF),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Divider(
            color: Colors.white.withValues(alpha: 0.35),
            thickness: 0.8,
          ),
        ),
      ],
    );
  }
}
