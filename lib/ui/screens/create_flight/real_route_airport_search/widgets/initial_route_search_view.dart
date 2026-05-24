part of '../real_route_airport_search_screen.dart';

class _InitialRouteSearchView extends StatelessWidget {
  const _InitialRouteSearchView({
    required this.state,
    required this.searchController,
  });

  final RealRouteAirportSearchState state;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RealRouteAirportSearchCubit>();
    final selectedAirport = state.selectedAirport;
    final filteredFavorites = _filterAirportsForCurrentStep(
      state.favoriteAirports,
      state,
    );
    final homeAirport = _filterHomeAirportForCurrentStep(state);
    final favorites = _pinHomeAirportFirst(filteredFavorites, homeAirport);
    final favoriteCodes = favorites.map(_airportCode).toSet();
    final recentCodes = <String>{};
    final recent = _filterAirportsForCurrentStep(state.recentAirports, state)
        .where((airport) {
          final code = _airportCode(airport);
          if (favoriteCodes.contains(code)) return false;
          recentCodes.add(code);
          return true;
        })
        .toList();
    final popular = recent.isNotEmpty
        ? const <Airport>[]
        : _filterAirportsForCurrentStep(state.popularAirports, state)
              .where(
                (airport) =>
                    !favoriteCodes.contains(_airportCode(airport)) &&
                    !recentCodes.contains(_airportCode(airport)),
              )
              .toList();
    final results = _filterAirportsForCurrentStep(state.searchResults, state);
    final searchT = context.t.createFlight.realRouteAirportSearch;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: FlightSearchAirportSelectionStep(
            step: state.airportStep,
            selectedDeparture: state.selectedDeparture,
            searchController: searchController,
            searchQuery: state.searchQuery,
            isSearchLoading: state.isSearchLoading,
            selectedAirport: selectedAirport,
            selectedAirportIsFavorite: state.selectedAirportIsFavorite,
            favorites: favorites,
            recent: recent,
            popular: popular,
            results: results,
            homeAirportCode: _airportCode(homeAirport),
            continueLabel: state.airportStep == AirportSelectionStep.departure
                ? context.t.common.kContinue
                : searchT.searchAction,
            onSearchChanged: cubit.searchAirports,
            onClearSearch: () {
              searchController.clear();
              cubit.searchAirports('');
            },
            onToggleFavoriteForSelected: cubit.toggleFavoriteForSelectedAirport,
            onClearSelectedAirport: () {
              searchController.clear();
              cubit.clearSelectedAirportForCurrentStep();
            },
            onSelectAirport: cubit.selectAirport,
            onToggleFavoriteForAirport: cubit.toggleFavoriteForAirport,
            onEditDeparture: () => unawaited(cubit.handleBackAction()),
            onContinue: () => unawaited(cubit.continueFromAirportStep()),
          ),
        ),
        if (state.isRouteSearchLoading)
          const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  List<Airport> _filterAirportsForCurrentStep(
    List<Airport> airports,
    RealRouteAirportSearchState state,
  ) {
    if (state.airportStep != AirportSelectionStep.arrival) return airports;

    final departureCode = _airportCode(state.selectedDeparture);
    if (departureCode.isEmpty) return airports;

    return airports
        .where((airport) => _airportCode(airport) != departureCode)
        .toList();
  }

  Airport? _filterHomeAirportForCurrentStep(RealRouteAirportSearchState state) {
    final home = state.homeAirport;
    if (home == null) return null;
    if (state.airportStep != AirportSelectionStep.arrival) return home;
    final departureCode = _airportCode(state.selectedDeparture);
    if (departureCode.isEmpty) return home;
    return _airportCode(home) == departureCode ? null : home;
  }

  List<Airport> _pinHomeAirportFirst(List<Airport> favorites, Airport? home) {
    if (home == null) return favorites;
    final homeCode = _airportCode(home);
    final filtered = favorites
        .where((airport) => _airportCode(airport) != homeCode)
        .toList();
    return [home, ...filtered];
  }

  String _airportCode(Airport? airport) {
    if (airport == null) return '';
    final primary = airport.primaryCode.trim().toUpperCase();
    if (primary.isNotEmpty) return primary;
    return airport.displayCode.trim().toUpperCase();
  }
}
