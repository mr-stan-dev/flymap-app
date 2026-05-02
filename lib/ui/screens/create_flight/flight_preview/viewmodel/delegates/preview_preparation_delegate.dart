part of '../flight_preview_cubit.dart';

class PreviewPreparationDelegate {
  PreviewPreparationDelegate(
    this._cubit, {
    required ConnectivityChecker connectivityChecker,
    required GetRouteOverviewUseCase getRouteOverviewUseCase,
    required GetWikiArticlesUseCase getWikiArticlesUseCase,
    required UserFlightPrefsRepository userFlightPrefsRepository,
  }) : _connectivityChecker = connectivityChecker,
       _getRouteOverviewUseCase = getRouteOverviewUseCase,
       _getWikiArticlesUseCase = getWikiArticlesUseCase,
       _userFlightPrefsRepository = userFlightPrefsRepository;

  final FlightPreviewCubit _cubit;
  final ConnectivityChecker _connectivityChecker;
  final GetRouteOverviewUseCase _getRouteOverviewUseCase;
  final GetWikiArticlesUseCase _getWikiArticlesUseCase;
  final UserFlightPrefsRepository _userFlightPrefsRepository;

  Future<void> preparePreview() async {
    final departure = _cubit.departure;
    final arrival = _cubit.arrival;

    try {
      final hasInternet = await _connectivityChecker.hasInternetConnectivity();
      if (!hasInternet) {
        _cubit._emitState(
          _cubit.state.copyWith(
            isPreviewLoading: false,
            isWikiSuggestionsLoading: false,
            isOverviewLoading: false,
            hasInternetForMapPreview: false,
            clearErrorMessage: true,
          ),
        );
        return;
      }

      final overview = await _getRouteOverviewUseCase.call(
        departure: departure,
        arrival: arrival,
      );
      final route = overview.route;
      final timeline = overview.timeline;
      final routeLength = MapDownloadConfig.resolveRouteLength(
        route.distanceInKm,
      );
      unawaited(
        _cubit._analytics.log(
          SearchRoutePreparedEvent(
            routeLengthKm: route.distanceInKm,
            routeLength: routeLength,
            mapDetail: _cubit.state.selectedMapDetailLevel,
          ),
        ),
      );
      unawaited(
        _cubit._crashlytics.setContext(
          screen: 'create_flight_map_preview',
          routeLengthKm: route.distanceInKm.round(),
          mapDetail: _cubit.state.selectedMapDetailLevel.name,
        ),
      );
      if (_isAntimeridianRoute(route)) {
        unawaited(
          _cubit._analytics.log(
            SearchRouteNotSupportedEvent(
              reason: 'antimeridian',
              routeLengthKm: route.distanceInKm,
            ),
          ),
        );
        unawaited(
          _cubit._crashlytics.setContext(
            screen: 'create_flight_route_not_supported',
          ),
        );
        _cubit._emitState(
          _cubit.state.copyWith(
            step: CreateFlightStep.routeNotSupported,
            flightRoute: route,
            isPreviewLoading: false,
            isWikiSuggestionsLoading: false,
            isOverviewLoading: false,
            flightInfo: FlightInfo.empty,
            articleCandidates: const [],
            clearSelectedArticleUrls: true,
            errorMessage: t.createFlight.mapPreview.routeNotSupportedMsg,
          ),
        );
        return;
      }

      _cubit._emitState(
        _cubit.state.copyWith(
          flightRoute: route,
          allRoutePois: overview.topPois,
          routeRegions: timeline.regions,
          routeTotalMinutes: timeline.totalRouteMinutes,
          routeCruiseSpeedKmh: timeline.cruiseSpeedKmh,
          isPreviewLoading: false,
          hasInternetForMapPreview: true,
          flightInfo: FlightInfo.empty.copyWith(
            poi: overview.topPois
                .take(
                  PoiSelectionConfig.maxPois(
                    _cubit.state.selectedMapDetailLevel,
                  ),
                )
                .toList(growable: false),
            routeRegions: timeline.regions,
            routeTotalMinutes: timeline.totalRouteMinutes,
            routeCruiseSpeedKmh: timeline.cruiseSpeedKmh,
          ),
          proPoiCount: overview.topPois.length < PoiSelectionConfig.proMaxPois
              ? overview.topPois.length
              : PoiSelectionConfig.proMaxPois,
          articleCandidates: const [],
          clearSelectedArticleUrls: true,
          isWikiSuggestionsLoading: true,
          isOverviewLoading: false,
        ),
      );

      final userPrefs = await _loadUserPrefs();
      unawaited(_prefetchWiki(route, userPrefs: userPrefs));
    } catch (e, stackTrace) {
      _cubit._logger.error('Failed to prepare map preview: $e');
      unawaited(
        _cubit._crashlytics.recordError(
          e,
          stackTrace,
          reason: 'prepare_preview_failed',
        ),
      );
      _cubit._emitState(
        _cubit.state.copyWith(
          isPreviewLoading: false,
          isWikiSuggestionsLoading: false,
          isOverviewLoading: false,
          errorMessage: t.createFlight.errors.failedBuildPreview,
        ),
      );
    }
  }

  Future<void> _prefetchWiki(
    FlightRoute route, {
    UserFlightPrefs? userPrefs,
  }) async {
    final prefs = userPrefs ?? await _loadUserPrefs();

    try {
      final suggestedCandidates = await _getWikiArticlesUseCase.call(
        airportArrival: route.arrival.name,
        airportDeparture: route.departure.name,
        waypoints: route.waypoints,
        interests: prefs.interests,
      );

      final routeAfterWikiCall = _cubit.state.flightRoute;
      if (routeAfterWikiCall == null ||
          routeAfterWikiCall.routeCode != route.routeCode) {
        return;
      }

      _cubit._emitState(
        _cubit.state.copyWith(
          articleCandidates: suggestedCandidates,
          selectedArticleUrls: _retainSelectedArticleUrls(
            selectedUrls: _cubit.state.selectedArticleUrls,
            candidates: suggestedCandidates,
          ),
          isWikiSuggestionsLoading: false,
        ),
      );
    } catch (e) {
      _cubit._emitState(_cubit.state.copyWith(isWikiSuggestionsLoading: false));
    }
  }

  List<String> _retainSelectedArticleUrls({
    required List<String> selectedUrls,
    required List<WikiArticleCandidate> candidates,
  }) {
    final candidateUrls = candidates.map((candidate) => candidate.url).toSet();
    return selectedUrls.where(candidateUrls.contains).toList();
  }

  bool _isAntimeridianRoute(FlightRoute route) {
    final points = route.waypoints.length >= 2
        ? route.waypoints
        : [route.departure.latLon, route.arrival.latLon];
    for (var i = 1; i < points.length; i++) {
      final deltaLon = points[i].longitude - points[i - 1].longitude;
      if (deltaLon.abs() > 180) {
        return true;
      }
    }
    return false;
  }

  Future<UserFlightPrefs> _loadUserPrefs() async {
    try {
      return await _userFlightPrefsRepository.getPrefs();
    } catch (e) {
      _cubit._logger.error('Failed to load user flight prefs: $e');
      return const UserFlightPrefs.empty();
    }
  }
}
