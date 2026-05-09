import 'package:flutter/material.dart';
import 'package:zo_animated_border/zo_animated_border.dart';

class PulsingHighlightCard extends StatelessWidget {
  const PulsingHighlightCard({
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.pulseColor = const Color(0xFF34C759),
    this.layerCount = 2,
    this.animationDuration = const Duration(milliseconds: 1800),
    super.key,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final Color pulseColor;
  final double layerCount;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    return ZoPulsatingBorder(
      borderRadius: borderRadius,
      pulseColor: pulseColor,
      layerCount: layerCount,
      animationDuration: animationDuration,
      type: ZoPulsatingBorderType.radarPulse,
      child: child,
    );
  }
}
