import 'package:flutter/material.dart';
import 'package:flymap/domain/entity/airport.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/design_system/design_system.dart';
import 'package:flymap/ui/screens/create_flight/airport_selection/viewmodel/airport_selection_screen_state.dart';

class SearchInputArea extends StatelessWidget {
  const SearchInputArea({
    required this.step,
    required this.searchController,
    required this.selectedAirport,
    required this.selectedAirportIsFavorite,
    required this.homeAirportCode,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onClearSelectedAirport,
    required this.onToggleFavoriteForSelected,
    super.key,
  });

  final AirportSelectionStep step;
  final TextEditingController searchController;
  final Airport? selectedAirport;
  final bool selectedAirportIsFavorite;
  final String homeAirportCode;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onClearSelectedAirport;
  final VoidCallback onToggleFavoriteForSelected;

  @override
  Widget build(BuildContext context) {
    final gpsActiveColor = DsSemanticColors.success(context);
    final primary = selectedAirport?.primaryCode.trim().toUpperCase() ?? '';
    final selectedAirportCode = primary.isNotEmpty ? primary : (selectedAirport?.displayCode.trim().toUpperCase() ?? '');
    final isSelectedAirportHome =
        selectedAirportCode.isNotEmpty &&
        homeAirportCode.isNotEmpty &&
        selectedAirportCode == homeAirportCode;

    return SearchInputField(
      controller: searchController,
      onChanged: (value) {
        if (selectedAirport != null) {
          onClearSelectedAirport();
        }
        onSearchChanged(value);
      },
      hintText: step == AirportSelectionStep.departure
          ? context.t.createFlight.search.departureHint
          : context.t.createFlight.search.arrivalHint,
      isSelected: selectedAirport != null,
      selectedBorderColor: gpsActiveColor,
      onClear: onClearSearch,
      suffixActions: selectedAirport != null
          ? [
              if (isSelectedAirportHome)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    Icons.home_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                )
              else
                IconButton(
                  icon: Icon(
                    selectedAirportIsFavorite ? Icons.star : Icons.star_border,
                    color: selectedAirportIsFavorite
                        ? DsSemanticColors.warning(context)
                        : null,
                  ),
                  tooltip: selectedAirportIsFavorite
                      ? context.t.createFlight.search.removeFavorite
                      : context.t.createFlight.search.addFavorite,
                  onPressed: onToggleFavoriteForSelected,
                ),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: context.t.createFlight.search.removeSelectedAirport,
                onPressed: onClearSelectedAirport,
              ),
            ]
          : const [],
    );
  }
}
