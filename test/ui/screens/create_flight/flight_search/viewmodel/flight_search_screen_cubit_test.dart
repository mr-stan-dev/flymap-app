import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/analytics/app_analytics.dart';
import 'package:flymap/crashlytics/app_crashlytics.dart';
import 'package:flymap/data/network/connectivity_checker.dart';
import 'package:flymap/entity/airport.dart';
import 'package:flymap/entity/flight.dart';
import 'package:flymap/entity/flight_info.dart';
import 'package:flymap/entity/user_profile.dart';
import 'package:flymap/entity/route_poi_summary.dart';
import 'package:flymap/entity/route_poi.dart';
import 'package:flymap/entity/flight_poi_type.dart';
import 'package:flymap/entity/flight_route.dart';
import 'package:flymap/entity/map_detail_level.dart';
import 'package:flymap/entity/route_overview.dart';
import 'package:flymap/entity/route_region.dart';
import 'package:flymap/entity/route_region_type.dart';
import 'package:flymap/entity/route_timeline.dart';
import 'package:flymap/entity/user_flight_prefs.dart';
import 'package:flymap/entity/wiki_article_candidate.dart';
import 'package:flymap/repository/flight_repository.dart';
import 'package:flymap/repository/subscription_repository.dart';
import 'package:flymap/repository/user_flight_prefs_repository.dart';
import 'package:flymap/subscription/subscription_paywall_result.dart';
import 'package:flymap/subscription/subscription_product.dart';
import 'package:flymap/subscription/subscription_status.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/viewmodel/flight_preview_cubit.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/viewmodel/flight_preview_state.dart';
import 'package:flymap/usecase/download_map_use_case.dart';
import 'package:flymap/usecase/download_poi_summaries_use_case.dart';
import 'package:flymap/usecase/download_region_wiki_articles_use_case.dart';
import 'package:flymap/usecase/download_wikipedia_articles_use_case.dart';
import 'package:flymap/usecase/get_wiki_articles_use_case.dart';
import 'package:flymap/usecase/delete_flight_use_case.dart';
import 'package:flymap/usecase/get_route_overview_use_case.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('FlightPreviewCubit wiki selection', () {
    late _FakeDownloadWikipediaArticlesUseCase wikiDownloadUseCase;
    late _FakeDownloadPoiSummariesUseCase poiDownloadUseCase;
    late _FakeDownloadRegionWikiArticlesUseCase regionWikiDownloadUseCase;
    late _FakeDownloadMapUseCase mapUseCase;
    late _FakeConnectivityChecker connectivityChecker;
    late _FakeSubscriptionRepository subscriptionRepository;
    late _TestFlightPreviewCubit cubit;

    setUp(() {
      wikiDownloadUseCase = _FakeDownloadWikipediaArticlesUseCase();
      poiDownloadUseCase = _FakeDownloadPoiSummariesUseCase();
      regionWikiDownloadUseCase = _FakeDownloadRegionWikiArticlesUseCase();
      mapUseCase = _FakeDownloadMapUseCase();
      connectivityChecker = _FakeConnectivityChecker();
      subscriptionRepository = _FakeSubscriptionRepository();
      final route = _route();
      cubit = _TestFlightPreviewCubit(
        departure: route.departure,
        arrival: route.arrival,
        connectivityChecker: connectivityChecker,
        getRouteOverviewUseCase: _FakeGetRouteOverviewUseCase(),
        downloadMapUseCase: mapUseCase,
        downloadPoiSummariesUseCase: poiDownloadUseCase,
        downloadRegionWikiArticlesUseCase: regionWikiDownloadUseCase,
        downloadWikipediaArticlesUseCase: wikiDownloadUseCase,
        getWikiArticlesUseCase: _FakeGetWikiArticlesUseCase(),
        userFlightPrefsRepository: _FakeUserFlightPrefsRepository(),
        flightRepository: _FakeFlightRepository(),
        subscriptionRepository: subscriptionRepository,
        deleteFlightUseCase: _FakeDeleteFlightUseCase(),
        analytics: _FakeAppAnalytics(),
        crashlytics: _FakeAppCrashlytics(),
      );
      cubit.setStateForTest(
        cubit.state.copyWith(
          step: CreateFlightStep.wikipediaArticles,
          articleCandidates: _candidates(4),
          selectedArticleUrls: const [],
          flightRoute: _route(),
        ),
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    test('free user can select more than 3 articles in UI state', () {
      cubit.toggleWikiArticleSelection(_url(1));
      cubit.toggleWikiArticleSelection(_url(2));
      cubit.toggleWikiArticleSelection(_url(3));
      cubit.toggleWikiArticleSelection(_url(4));

      expect(cubit.state.selectedArticleUrls, [
        _url(1),
        _url(2),
        _url(3),
        _url(4),
      ]);
    });

    test('user can deselect and select a different article', () {
      cubit.toggleWikiArticleSelection(_url(1));
      cubit.toggleWikiArticleSelection(_url(2));
      cubit.toggleWikiArticleSelection(_url(3));
      cubit.toggleWikiArticleSelection(_url(2)); // deselect
      cubit.toggleWikiArticleSelection(_url(4)); // select new one

      expect(cubit.state.selectedArticleUrls, [_url(1), _url(3), _url(4)]);
    });

    test('select all selects all candidates', () {
      cubit.toggleAllWikiArticleSelections();
      expect(cubit.state.selectedArticleUrls, _candidates(4).map((e) => e.url));
    });

    test(
      'startDownload as free never passes more than 3 urls to article downloader',
      () async {
        subscriptionRepository.isPro = false;
        cubit.setStateForTest(
          cubit.state.copyWith(
            selectedArticleUrls: [_url(1), _url(2), _url(3), _url(4)],
          ),
        );

        await cubit.startDownload();

        expect(wikiDownloadUseCase.lastRequestedUrls, [
          _url(1),
          _url(2),
          _url(3),
        ]);
        expect(cubit.state.selectedArticleUrls, [_url(1), _url(2), _url(3)]);
      },
    );

    test(
      'startDownload as pro passes all selected urls to article downloader',
      () async {
        subscriptionRepository.isPro = true;
        cubit.setStateForTest(
          cubit.state.copyWith(
            selectedArticleUrls: [_url(1), _url(2), _url(3), _url(4)],
          ),
        );

        await cubit.startDownload();

        expect(wikiDownloadUseCase.lastRequestedUrls, [
          _url(1),
          _url(2),
          _url(3),
          _url(4),
        ]);
      },
    );

    test('default selected map detail level is basic', () {
      expect(cubit.state.selectedMapDetailLevel, MapDetailLevel.basic);
    });

    test('default selected map detail level is pro for pro users', () async {
      final proSubscriptionRepository = _FakeSubscriptionRepository()
        ..isPro = true;
      final route = _route();
      final proCubit = _TestFlightPreviewCubit(
        departure: route.departure,
        arrival: route.arrival,
        connectivityChecker: _FakeConnectivityChecker(),
        getRouteOverviewUseCase: _FakeGetRouteOverviewUseCase(),
        downloadMapUseCase: _FakeDownloadMapUseCase(),
        downloadPoiSummariesUseCase: _FakeDownloadPoiSummariesUseCase(),
        downloadRegionWikiArticlesUseCase:
            _FakeDownloadRegionWikiArticlesUseCase(),
        downloadWikipediaArticlesUseCase:
            _FakeDownloadWikipediaArticlesUseCase(),
        getWikiArticlesUseCase: _FakeGetWikiArticlesUseCase(),
        userFlightPrefsRepository: _FakeUserFlightPrefsRepository(),
        flightRepository: _FakeFlightRepository(),
        subscriptionRepository: proSubscriptionRepository,
        deleteFlightUseCase: _FakeDeleteFlightUseCase(),
        analytics: _FakeAppAnalytics(),
        crashlytics: _FakeAppCrashlytics(),
      );
      addTearDown(proCubit.close);

      expect(proCubit.state.selectedMapDetailLevel, MapDetailLevel.pro);
    });

    test('selectMapDetailLevel updates state in overview step', () {
      cubit.setStateForTest(
        cubit.state.copyWith(step: CreateFlightStep.overview),
      );

      cubit.selectMapDetailLevel(MapDetailLevel.pro);

      expect(cubit.state.selectedMapDetailLevel, MapDetailLevel.pro);
    });

    test('startDownload passes z10 for basic short route', () async {
      subscriptionRepository.isPro = true;
      cubit.setStateForTest(
        cubit.state.copyWith(
          selectedArticleUrls: const [],
          selectedMapDetailLevel: MapDetailLevel.basic,
          flightRoute: _route(),
        ),
      );

      await cubit.startDownload();

      expect(mapUseCase.lastMaxZoom, 10);
    });

    test('startDownload passes z9 for basic long route', () async {
      subscriptionRepository.isPro = true;
      cubit.setStateForTest(
        cubit.state.copyWith(
          selectedArticleUrls: const [],
          selectedMapDetailLevel: MapDetailLevel.basic,
          flightRoute: _longRoute(),
        ),
      );

      await cubit.startDownload();

      expect(mapUseCase.lastMaxZoom, 9);
    });

    test('startDownload passes z11 for pro short route', () async {
      subscriptionRepository.isPro = true;
      cubit.setStateForTest(
        cubit.state.copyWith(
          selectedArticleUrls: const [],
          selectedMapDetailLevel: MapDetailLevel.pro,
          flightRoute: _route(),
        ),
      );

      await cubit.startDownload();

      expect(mapUseCase.lastMaxZoom, 11);
    });

    test('startDownload passes z10 for pro long route', () async {
      subscriptionRepository.isPro = true;
      cubit.setStateForTest(
        cubit.state.copyWith(
          selectedArticleUrls: const [],
          selectedMapDetailLevel: MapDetailLevel.pro,
          flightRoute: _longRoute(),
        ),
      );

      await cubit.startDownload();

      expect(mapUseCase.lastMaxZoom, 10);
    });

    test('offline overview shows error state flag', () async {
      connectivityChecker.hasInternet = false;
      cubit.setStateForTest(
        cubit.state.copyWith(step: CreateFlightStep.overview),
      );
      await cubit.preparePreview();

      expect(cubit.state.step, CreateFlightStep.overview);
      expect(cubit.state.isPreviewLoading, isFalse);
      expect(cubit.state.hasInternetForMapPreview, isFalse);
    });

    test('refreshPoisForPro applies cached pro POI slice', () async {
      final pois = _routePoiSummaries(80);
      cubit.setStateForTest(
        cubit.state.copyWith(
          allRoutePois: pois,
          flightInfo: cubit.state.flightInfo.copyWith(
            poi: pois.take(10).toList(),
          ),
          flightRoute: _route(),
          selectedMapDetailLevel: MapDetailLevel.basic,
        ),
      );

      await cubit.refreshPoisForPro();

      expect(cubit.state.flightInfo.poi.length, 60);
    });

    test('region wiki resolution uses english language for download', () async {
      subscriptionRepository.isPro = true;
      cubit.setStateForTest(
        cubit.state.copyWith(
          selectedArticleUrls: const [],
          flightRoute: _route(),
          flightInfo: cubit.state.flightInfo.copyWith(
            routeRegions: const [
              RouteRegion(
                qid: 'Q84',
                name: 'London',
                regionType: RouteRegionType.region,
                pathFirstEncounterKm: 0,
                pathLengthInsideKm: 42,
                geometry: RouteRegionGeometry(type: 'Polygon', geoJson: {}),
              ),
            ],
          ),
        ),
      );

      await cubit.startDownload();

      expect(regionWikiDownloadUseCase.lastPreferredLanguageCode, 'en');
    });
  });
}

String _url(int i) => 'https://en.wikipedia.org/wiki/Article_$i';

List<WikiArticleCandidate> _candidates(int count) {
  return List.generate(
    count,
    (index) => WikiArticleCandidate(
      url: _url(index + 1),
      title: 'Article ${index + 1}',
      languageCode: 'en',
    ),
  );
}

FlightRoute _route() {
  const departure = Airport(
    name: 'A',
    city: 'A',
    countryCode: 'US',
    latLon: LatLng(10, 10),
    iataCode: 'AAA',
    icaoCode: 'AAAA',
    wikipediaUrl: '',
  );
  const arrival = Airport(
    name: 'B',
    city: 'B',
    countryCode: 'US',
    latLon: LatLng(20, 20),
    iataCode: 'BBB',
    icaoCode: 'BBBB',
    wikipediaUrl: '',
  );
  return const FlightRoute(
    departure: departure,
    arrival: arrival,
    waypoints: [LatLng(10, 10), LatLng(20, 20)],
    corridor: [LatLng(10, 10), LatLng(20, 20)],
  );
}

FlightRoute _longRoute() {
  const departure = Airport(
    name: 'C',
    city: 'C',
    countryCode: 'US',
    latLon: LatLng(10, 10),
    iataCode: 'CCC',
    icaoCode: 'CCCC',
    wikipediaUrl: '',
  );
  const arrival = Airport(
    name: 'D',
    city: 'D',
    countryCode: 'US',
    latLon: LatLng(35, 35),
    iataCode: 'DDD',
    icaoCode: 'DDDD',
    wikipediaUrl: '',
  );
  return const FlightRoute(
    departure: departure,
    arrival: arrival,
    waypoints: [LatLng(10, 10), LatLng(35, 35)],
    corridor: [LatLng(10, 10), LatLng(35, 35)],
  );
}

List<RoutePoiSummary> _routePoiSummaries(int count) {
  return List.generate(
    count,
    (i) => RoutePoiSummary(
      poi: RoutePoi(
        qid: 'Q${1000 + i}',
        name: 'POI ${i + 1}',
        latLon: LatLng(10 + i / 10, 10 + i / 10),
        type: FlightPoiType.mountain,
        sitelinks: 1000 - i,
      ),
      routeProgress: i / count,
    ),
  );
}

class _TestFlightPreviewCubit extends FlightPreviewCubit {
  _TestFlightPreviewCubit({
    required super.departure,
    required super.arrival,
    required super.connectivityChecker,
    required super.getRouteOverviewUseCase,
    required super.downloadMapUseCase,
    required super.downloadPoiSummariesUseCase,
    required super.downloadRegionWikiArticlesUseCase,
    required super.downloadWikipediaArticlesUseCase,
    required super.getWikiArticlesUseCase,
    required super.userFlightPrefsRepository,
    required super.flightRepository,
    required super.subscriptionRepository,
    required super.deleteFlightUseCase,
    required super.analytics,
    required super.crashlytics,
  }) : super(autoPrepare: false);

  void setStateForTest(FlightPreviewState state) => emit(state);
}

class _FakeConnectivityChecker implements ConnectivityChecker {
  bool hasInternet = true;

  @override
  Future<bool> hasInternetConnectivity({
    Duration timeout = const Duration(seconds: 2),
  }) async => hasInternet;
}

class _FakeGetRouteOverviewUseCase implements GetRouteOverviewUseCase {
  @override
  Future<RouteOverview> call({
    required Airport departure,
    required Airport arrival,
  }) async {
    return const RouteOverview(
      route: FlightRoute(
        departure: Airport(
          name: 'A',
          city: 'A',
          countryCode: 'US',
          latLon: LatLng(10, 10),
          iataCode: 'AAA',
          icaoCode: 'AAAA',
          wikipediaUrl: '',
        ),
        arrival: Airport(
          name: 'B',
          city: 'B',
          countryCode: 'US',
          latLon: LatLng(20, 20),
          iataCode: 'BBB',
          icaoCode: 'BBBB',
          wikipediaUrl: '',
        ),
        waypoints: [LatLng(10, 10), LatLng(20, 20)],
        corridor: [LatLng(10, 10), LatLng(20, 20)],
      ),
      topPois: [],
      timeline: RouteTimeline(
        regions: [
          RouteRegion(
            qid: 'Q1',
            name: 'France',
            regionType: RouteRegionType.country,
            pathFirstEncounterKm: 100,
            pathLengthInsideKm: 120,
            geometry: RouteRegionGeometry(
              type: 'Polygon',
              geoJson: {
                'type': 'Polygon',
                'coordinates': [
                  [
                    [2.0, 45.0],
                    [2.1, 45.0],
                    [2.1, 45.1],
                    [2.0, 45.1],
                    [2.0, 45.0],
                  ],
                ],
              },
            ),
          ),
        ],
        totalRouteMinutes: 95,
        cruiseSpeedKmh: 850,
      ),
    );
  }
}

class _FakeDownloadMapUseCase implements DownloadMapUseCase {
  int? lastMaxZoom;

  @override
  void cancel() {}

  @override
  Stream<DownloadMapEvent> call({
    required String flightId,
    required FlightRoute flightRoute,
    required FlightInfo flightInfo,
    required int maxZoom,
  }) {
    lastMaxZoom = maxZoom;
    return Stream<DownloadMapEvent>.fromIterable([
      DownloadMapInitializing(),
      DownloadMapDone('/tmp/test.mbtiles', 1024),
    ]);
  }
}

class _FakeDownloadWikipediaArticlesUseCase
    implements DownloadWikipediaArticlesUseCase {
  List<String> lastRequestedUrls = const [];

  @override
  void cancel() {}

  @override
  Future<void> cleanupBundleMedia(String bundleId) async {}

  @override
  Future<WikipediaArticlesDownloadResult> call({
    required String bundleId,
    required List<String> articleUrls,
    required void Function(WikipediaArticlesDownloadProgress progress)
    onProgress,
  }) async {
    lastRequestedUrls = List<String>.from(articleUrls);
    return const WikipediaArticlesDownloadResult(
      articles: [],
      failedCount: 0,
      cancelled: false,
    );
  }
}

class _FakeDownloadPoiSummariesUseCase implements DownloadPoiSummariesUseCase {
  @override
  void cancel() {}

  @override
  Future<PoiSummariesDownloadResult> call({
    required List<RoutePoiSummary> pois,
    required String preferredLanguageCode,
    required void Function(PoiSummariesDownloadProgress progress) onProgress,
  }) async {
    return PoiSummariesDownloadResult(
      pois: List<RoutePoiSummary>.from(pois),
      failedCount: 0,
      cancelled: false,
    );
  }
}

class _FakeDownloadRegionWikiArticlesUseCase
    implements DownloadRegionWikiArticlesUseCase {
  String? lastPreferredLanguageCode;

  @override
  void cancel() {}

  @override
  int downloadTargetCount(List<RouteRegion> regions) => regions.length;

  @override
  Future<RegionWikiArticlesDownloadResult> call({
    required List<RouteRegion> regions,
    required String preferredLanguageCode,
    required void Function(RegionWikiArticlesDownloadProgress progress)
    onProgress,
  }) async {
    lastPreferredLanguageCode = preferredLanguageCode;
    onProgress(
      RegionWikiArticlesDownloadProgress(
        completed: regions.length,
        total: regions.length,
        failed: 0,
      ),
    );
    return RegionWikiArticlesDownloadResult(
      regions: List<RouteRegion>.from(regions),
      articleUrls: const [],
      failedCount: 0,
      cancelled: false,
    );
  }
}

class _FakeGetWikiArticlesUseCase implements GetWikiArticlesUseCase {
  @override
  Future<List<WikiArticleCandidate>> call({
    required String airportDeparture,
    required String airportArrival,
    required List<LatLng> waypoints,
    List<UsersInterests>? interests,
  }) async => const [];
}

class _FakeUserFlightPrefsRepository implements UserFlightPrefsRepository {
  @override
  Future<UserFlightPrefs> getPrefs() async => const UserFlightPrefs.empty();
}

class _FakeAppAnalytics implements AppAnalytics {
  @override
  Future<void> setGlobalContext({
    required String appVersion,
    required String buildNumber,
    required String platform,
    required String appEnv,
  }) async {}

  @override
  Future<void> setSubscriptionContext({required bool isPro}) async {}

  @override
  Future<void> log(AnalyticsEvent event) async {}
}

class _FakeAppCrashlytics implements AppCrashlytics {
  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {}

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) async {}

  @override
  Future<void> setCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setContext({
    String? screen,
    int? routeLengthKm,
    String? mapDetail,
    int? articlesSelectedCount,
    String? downloadStage,
  }) async {}
}

class _FakeDeleteFlightUseCase implements DeleteFlightUseCase {
  @override
  Future<bool> call(String flightId) async => true;
}

class _FakeFlightRepository implements FlightRepository {
  @override
  Future<List<Flight>> getAllFlights() async => const [];

  @override
  Future<Flight?> getFlightById(String flightId) async => null;

  @override
  Future<int> getTotalDownloadedMaps() async => 0;

  @override
  Future<int> getTotalFlights() async => 0;

  @override
  Future<int> getTotalMapSize() async => 0;

  @override
  Future<double> getTotalFlightDistanceKm() async => 0;

  @override
  Future<String> insertFlight(Flight flight) async => flight.id;

  @override
  Future<String> saveOrUpdateFlight(Flight flight) async => flight.id;

  @override
  Future<bool> updateFlightInfo({
    required String flightId,
    required FlightInfo info,
  }) async => true;

  @override
  Future<bool> updateFlightStatus({
    required String flightId,
    required FlightStatus status,
    DateTime? completedAt,
  }) async => true;
}

class _FakeSubscriptionRepository implements SubscriptionRepository {
  bool isPro = false;

  @override
  Stream<SubscriptionStatus> get statusStream =>
      const Stream<SubscriptionStatus>.empty();

  @override
  SubscriptionStatus get currentStatus => SubscriptionStatus(
    isPro: isPro,
    entitlementId: 'Flymap Pro',
    lastUpdatedAt: DateTime.now(),
  );

  @override
  Future<SubscriptionStatus> initialize() async => currentStatus;

  @override
  Future<SubscriptionStatus> refresh() async => currentStatus;

  @override
  Future<SubscriptionStatus> restorePurchases() async => currentStatus;

  @override
  Future<List<SubscriptionProduct>> getProducts() async => const [];

  @override
  Future<SubscriptionStatus> purchasePackage({
    required String packageId,
  }) async {
    isPro = true;
    return currentStatus;
  }

  @override
  Future<SubscriptionPaywallResult> presentPaywallIfNeeded() async =>
      SubscriptionPaywallResult.cancelled;

  @override
  Future<void> presentCustomerCenter() async {}

  @override
  Future<void> close() async {}
}
