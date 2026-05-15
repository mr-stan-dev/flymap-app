import 'package:flutter/material.dart';
import 'package:flymap/ui/screens/share_flight/widgets/card/config/share_image_card_config.dart';

class ShareImageCardMapShadow extends StatelessWidget {
  const ShareImageCardMapShadow({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0x24020B12)),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: ShareImageCardConfig.topShadowHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFD07131D),
                  Color(0x7807131D),
                  Color(0x0007131D),
                ],
                stops: [0, 0.75, 1],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: ShareImageCardConfig.bottomShadowHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x0007131D),
                  Color(0xA607131D),
                  Color(0xF007131D),
                ],
                stops: [0, 0.52, 1],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
