part of '../real_route_airport_search_screen.dart';

class _RouteResultsRouterView extends StatelessWidget {
  const _RouteResultsRouterView({
    required this.state,
    required this.hasPendingFlightUnlock,
  });

  final RealRouteAirportSearchState state;
  final bool hasPendingFlightUnlock;

  @override
  Widget build(BuildContext context) {
    final searchT = context.t.createFlight.realRouteAirportSearch;
    final departure = state.selectedDeparture;
    final arrival = state.selectedArrival;
    final noMatchTitle = _fallbackTitle(
      searchT: searchT,
      departure: departure,
      arrival: arrival,
    );

    if (state.isRouteSearchLoading) {
      return const _LoadingRouteSearchView();
    }

    if (state.routeSearchErrorMessage == searchT.emptyResults) {
      return _EmptyRouteSearchView(
        title: noMatchTitle,
        message: searchT.emptyResults,
        state: state,
        hasPendingFlightUnlock: hasPendingFlightUnlock,
      );
    }

    if (state.routeSearchErrorMessage != null) {
      return _ErrorRouteSearchView(
        title: noMatchTitle,
        message: state.routeSearchErrorMessage!,
        state: state,
        hasPendingFlightUnlock: hasPendingFlightUnlock,
      );
    }

    if (state.matchedFlights.isEmpty) {
      return _EmptyRouteSearchView(
        title: noMatchTitle,
        message: searchT.emptyResults,
        state: state,
        hasPendingFlightUnlock: hasPendingFlightUnlock,
      );
    }

    return _FoundRouteSearchView(state: state);
  }

  String _fallbackTitle({
    required dynamic searchT,
    required Airport? departure,
    required Airport? arrival,
  }) {
    if (departure == null || arrival == null) {
      return searchT.emptyTitle as String;
    }
    return searchT.sorryNoFlightFromTo(
      departure: departure.name,
      arrival: arrival.name,
    );
  }
}
