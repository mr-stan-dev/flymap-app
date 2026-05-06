import 'package:flutter/material.dart';

class AirportArtwork extends StatelessWidget {
  const AirportArtwork({
    this.size = 64,
    this.borderRadius = 12,
    this.isCircle = false,
    super.key,
  });

  final double size;
  final double borderRadius;
  final bool isCircle;

  @override
  Widget build(BuildContext context) {
    final content = SizedBox.square(
      dimension: size,
      child: Image.asset('assets/images/airport.webp', fit: BoxFit.cover),
    );
    if (isCircle) {
      return ClipOval(child: content);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: content,
    );
  }
}
