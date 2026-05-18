import 'package:flutter/material.dart';
import 'package:flymap/domain/entity/airport.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/design_system/design_system.dart';
import 'package:country_flags/country_flags.dart';

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
        final code = primary.isNotEmpty
            ? primary
            : airport.displayCode.trim().toUpperCase();
        final isHomeAirport =
            homeAirportCode.isNotEmpty && code == homeAirportCode;
        return SelectionChip(
          label: context.t.createFlight.search.airportNameCode(
            name: airport.nameShort,
            code: airport.displayCode,
          ),
          leading: SizedBox(
            width: 18,
            height: 18,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Opacity(
                  opacity: 0.75,
                  child: CountryFlag.fromCountryCode(
                    airport.countryCode,
                    width: 18,
                    height: 18,
                    shape: Circle(),
                  ),
                ),
                if (isHomeAirport)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.home_rounded,
                        size: 8,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
          ),
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
