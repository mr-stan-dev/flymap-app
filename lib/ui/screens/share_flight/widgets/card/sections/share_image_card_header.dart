import 'package:flutter/material.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/theme/app_theme_ext.dart';

class ShareImageCardHeader extends StatelessWidget {
  const ShareImageCardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final brandStyle = context.textTheme.body16Semibold.copyWith(
      color: Colors.white,
      fontSize: 14,
      height: 1.1,
      letterSpacing: 0,
    );
    final ctaStyle = context.textTheme.caption14Regular.copyWith(
      color: const Color(0xFF9FFBFF),
      fontWeight: FontWeight.w700,
      fontSize: 12,
      height: 1.1,
      letterSpacing: 0,
    );

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Image.asset(
            'assets/app_icon.png',
            width: 32,
            height: 32,
            errorBuilder: (_, __, ___) => Container(
              width: 32,
              height: 32,
              color: const Color(0xFF0B58E8),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(t.shareImage.brand, style: brandStyle),
        const Spacer(),
        const Icon(Icons.auto_awesome, color: Color(0xFF9FFBFF), size: 12),
        const SizedBox(width: 6),
        Text(t.shareImage.exploreYourFlight, style: ctaStyle),
      ],
    );
  }
}
