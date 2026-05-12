import 'package:flutter/material.dart';
import 'package:flymap/domain/entity/airport.dart';
import 'package:flymap/ui/screens/create_flight/airports_search/viewmodel/airport_selection_screen_state.dart';
import 'package:flymap/ui/screens/create_flight/airports_search/widgets/empty_search_results.dart';
import 'package:flymap/ui/screens/create_flight/airports_search/widgets/search_result_list.dart';

class SearchResultsArea extends StatelessWidget {
  const SearchResultsArea({
    required this.step,
    required this.isSearchLoading,
    required this.searchQuery,
    required this.results,
    required this.selectedAirport,
    required this.onSelectAirport,
    super.key,
  });

  final AirportSelectionStep step;
  final bool isSearchLoading;
  final String searchQuery;
  final List<Airport> results;
  final Airport? selectedAirport;
  final Future<void> Function(Airport airport) onSelectAirport;

  @override
  Widget build(BuildContext context) {
    if (selectedAirport != null) return const SizedBox.shrink();

    if (isSearchLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchQuery.isNotEmpty && results.isEmpty) {
      return EmptySearchResults(step: step);
    }

    if (results.isNotEmpty) {
      return SearchResultList(
        airports: results,
        searchQuery: searchQuery,
        onSelectAirport: onSelectAirport,
      );
    }

    return const SizedBox.shrink();
  }
}
