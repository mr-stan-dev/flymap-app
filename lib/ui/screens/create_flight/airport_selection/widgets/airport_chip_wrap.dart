import 'package:flutter/material.dart';
import 'package:flymap/entity/airport.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/design_system/design_system.dart';

class AirportChipWrap extends StatelessWidget {
  const AirportChipWrap({
    required this.airports,
    required this.onSelectAirport,
    this.homeAirportCode = '',
    this.showFavoriteTrailingIcon = false,
    this.onToggleFavorite,
    super.key,
  });

  final List<Airport> airports;
  final Future<void> Function(Airport airport) onSelectAirport;
  final String homeAirportCode;
  final bool showFavoriteTrailingIcon;
  final Future<void> Function(Airport airport)? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: airports.map((airport) {
        final primary = airport.primaryCode.trim().toUpperCase();
        final code = primary.isNotEmpty ? primary : airport.displayCode.trim().toUpperCase();
        final isHomeAirport =
            homeAirportCode.isNotEmpty && code == homeAirportCode;
        return SelectionChip(
          label: context.t.createFlight.search.airportNameCode(
            name: airport.nameShort,
            code: airport.displayCode,
          ),
          leading: isHomeAirport
              ? Icon(
                  Icons.home_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
          onPressed: () => onSelectAirport(airport),
          onDeleted:
              showFavoriteTrailingIcon &&
                  onToggleFavorite != null &&
                  !isHomeAirport
              ? () => onToggleFavorite!(airport)
              : null,
          deleteIcon: showFavoriteTrailingIcon && !isHomeAirport
              ? Icon(
                  Icons.star,
                  color: DsSemanticColors.warning(context),
                  size: 18,
                )
              : null,
          deleteTooltip: showFavoriteTrailingIcon
              ? context.t.createFlight.search.removeFromFavorites
              : null,
        );
      }).toList(),
    );
  }
}
