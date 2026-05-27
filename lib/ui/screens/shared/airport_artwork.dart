import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

class AirportArtwork extends StatelessWidget {
  const AirportArtwork({
    this.size = 64,
    this.borderRadius = 12,
    this.isCircle = false,
    this.countryCode,
    this.showCountryBadge = true,
    super.key,
  });

  final double size;
  final double borderRadius;
  final bool isCircle;
  final String? countryCode;
  final bool showCountryBadge;

  @override
  Widget build(BuildContext context) {
    final image = SizedBox.square(
      dimension: size,
      child: Image.asset('assets/images/airport.webp', fit: BoxFit.cover),
    );
    final clipped = isCircle
        ? ClipOval(child: image)
        : ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: image,
          );

    final normalizedCountryCode = countryCode?.trim().toUpperCase() ?? '';
    if (!showCountryBadge || normalizedCountryCode.length != 2) {
      return clipped;
    }

    final badgeSize = (size * 0.36).clamp(14.0, 24.0);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        clipped,
        Positioned(
          top: -2,
          right: -2,
          child: Container(
            width: badgeSize,
            height: badgeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: Theme.of(context).colorScheme.surface,
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: Opacity(
                opacity: 0.75,
                child: CountryFlag.fromCountryCode(
                  normalizedCountryCode,
                  width: badgeSize,
                  height: badgeSize,
                  shape: const Circle(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
