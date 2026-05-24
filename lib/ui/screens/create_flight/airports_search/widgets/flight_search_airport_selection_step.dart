import 'package:flutter/material.dart';
import 'package:flymap/domain/entity/airport.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/design_system/design_system.dart';
import 'package:flymap/ui/screens/create_flight/airports_search/viewmodel/airport_selection_screen_state.dart';
import 'package:flymap/ui/screens/create_flight/airports_search/widgets/airport_category_section.dart';
import 'package:flymap/ui/screens/create_flight/airports_search/widgets/search_input_area.dart';
import 'package:flymap/ui/screens/create_flight/airports_search/widgets/search_results_area.dart';
import 'package:flymap/ui/screens/create_flight/airports_search/widgets/selected_departure_row.dart';

class FlightSearchAirportSelectionStep extends StatelessWidget {
  const FlightSearchAirportSelectionStep({
    required this.step,
    required this.selectedDeparture,
    required this.searchController,
    required this.searchQuery,
    required this.isSearchLoading,
    required this.selectedAirport,
    required this.selectedAirportIsFavorite,
    required this.favorites,
    required this.recent,
    required this.popular,
    required this.results,
    required this.homeAirportCode,
    this.continueLabel,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onToggleFavoriteForSelected,
    required this.onClearSelectedAirport,
    required this.onSelectAirport,
    required this.onToggleFavoriteForAirport,
    required this.onEditDeparture,
    required this.onContinue,
    super.key,
  });

  final AirportSelectionStep step;
  final Airport? selectedDeparture;
  final TextEditingController searchController;
  final String searchQuery;
  final bool isSearchLoading;
  final Airport? selectedAirport;
  final bool selectedAirportIsFavorite;
  final List<Airport> favorites;
  final List<Airport> recent;
  final List<Airport> popular;
  final List<Airport> results;
  final String homeAirportCode;
  final String? continueLabel;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onToggleFavoriteForSelected;
  final VoidCallback onClearSelectedAirport;
  final Future<void> Function(Airport airport) onSelectAirport;
  final Future<void> Function(Airport airport) onToggleFavoriteForAirport;
  final VoidCallback onEditDeparture;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (step == AirportSelectionStep.arrival &&
                    selectedDeparture != null) ...[
                  SelectedDepartureRow(
                    airport: selectedDeparture!,
                    onEdit: onEditDeparture,
                  ),
                  const SizedBox(height: 12),
                ],
                SearchInputArea(
                  step: step,
                  searchController: searchController,
                  selectedAirport: selectedAirport,
                  selectedAirportIsFavorite: selectedAirportIsFavorite,
                  homeAirportCode: homeAirportCode,
                  onSearchChanged: onSearchChanged,
                  onClearSearch: onClearSearch,
                  onClearSelectedAirport: onClearSelectedAirport,
                  onToggleFavoriteForSelected: onToggleFavoriteForSelected,
                ),
                const SizedBox(height: 12),
                SearchResultsArea(
                  step: step,
                  isSearchLoading: isSearchLoading,
                  searchQuery: searchQuery,
                  results: results,
                  selectedAirport: selectedAirport,
                  onSelectAirport: onSelectAirport,
                ),
                AirportCategorySection(
                  title: context.t.createFlight.search.favorites,
                  airports: favorites,
                  onSelectAirport: onSelectAirport,
                  homeAirportCode: homeAirportCode,
                  showFavoriteTrailingIcon: true,
                  onToggleFavorite: onToggleFavoriteForAirport,
                ),
                AirportCategorySection(
                  title: context.t.createFlight.search.recentAirports,
                  airports: recent,
                  onSelectAirport: onSelectAirport,
                ),
                AirportCategorySection(
                  title: context.t.createFlight.search.popularAirports,
                  airports: popular,
                  onSelectAirport: onSelectAirport,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: PrimaryButton(
              onPressed: selectedAirport == null ? null : onContinue,
              label: continueLabel ?? context.t.common.kContinue,
            ),
          ),
        ),
      ],
    );
  }
}
