import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flymap/entity/route_region_type.dart';
import 'package:flymap/utils/country_name_utils.dart';

class RegionArtwork extends StatelessWidget {
  const RegionArtwork({
    required this.regionName,
    required this.regionType,
    this.size = 64,
    this.borderRadius = 12,
    this.isCircle = false,
    super.key,
  });

  final String regionName;
  final RouteRegionType regionType;
  final double size;
  final double borderRadius;
  final bool isCircle;

  @override
  Widget build(BuildContext context) {
    final assetPath = regionType.assetImagePath;
    final content = SizedBox.square(
      dimension: size,
      child: _buildArtwork(context, assetPath),
    );
    if (isCircle) {
      return ClipOval(child: content);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: content,
    );
  }

  Widget _buildArtwork(BuildContext context, String? assetPath) {
    if (regionType == RouteRegionType.country) {
      final countryCode = CountryNameUtils.toCode(regionName);
      if (countryCode != null) {
        return Center(
          child: Opacity(
            opacity: 0.70,
            child: CountryFlag.fromCountryCode(
              countryCode,
              width: size,
              height: size,
              shape: Rectangle(),
            ),
          ),
        );
      }
    }
    if (assetPath != null) {
      return Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _fallbackIcon(context, size: size * 0.34),
      );
    }
    return _fallbackIcon(context, size: size * 0.34);
  }

  Widget _fallbackIcon(BuildContext context, {required double size}) {
    return Icon(
      Icons.public,
      size: size,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}
