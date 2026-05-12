import 'package:flutter/material.dart';
import 'package:flymap/domain/entity/airport.dart';
import 'package:flymap/ui/screens/create_flight/airports_search/widgets/airport_chip_wrap.dart';

class AirportCategorySection extends StatelessWidget {
  const AirportCategorySection({
    required this.title,
    required this.airports,
    required this.onSelectAirport,
    this.homeAirportCode = '',
    this.showFavoriteTrailingIcon = false,
    this.onToggleFavorite,
    super.key,
  });

  final String title;
  final List<Airport> airports;
  final Future<void> Function(Airport airport) onSelectAirport;
  final String homeAirportCode;
  final bool showFavoriteTrailingIcon;
  final Future<void> Function(Airport airport)? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    if (airports.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        AirportChipWrap(
          airports: airports,
          homeAirportCode: homeAirportCode,
          onSelectAirport: onSelectAirport,
          showFavoriteTrailingIcon: showFavoriteTrailingIcon,
          onToggleFavorite: onToggleFavorite,
        ),
      ],
    );
  }
}
