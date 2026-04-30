import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/analytics/app_analytics.dart';
import 'package:flymap/crashlytics/app_crashlytics.dart';
import 'package:flymap/data/network/connectivity_checker.dart';
import 'package:flymap/entity/airport.dart';
import 'package:flymap/entity/flight_article.dart';
import 'package:flymap/entity/flight_info.dart';
import 'package:flymap/entity/flight_route.dart';
import 'package:flymap/entity/route_poi_summary.dart';
import 'package:flymap/entity/map_detail_level.dart';
import 'package:flymap/entity/user_flight_prefs.dart';
import 'package:flymap/entity/wiki_article_candidate.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/logger.dart';
import 'package:flymap/map_download_config.dart';
import 'package:flymap/repository/flight_repository.dart';
import 'package:flymap/repository/subscription_repository.dart';
import 'package:flymap/repository/user_flight_prefs_repository.dart';
import 'package:flymap/subscription/pro_limits.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/viewmodel/flight_preview_state.dart';
import 'package:flymap/usecase/delete_flight_use_case.dart';
import 'package:flymap/usecase/download_map_use_case.dart';
import 'package:flymap/usecase/download_poi_summaries_use_case.dart';
import 'package:flymap/usecase/download_wikipedia_articles_use_case.dart';
import 'package:flymap/usecase/get_flight_info_use_case.dart';
import 'package:flymap/usecase/get_wiki_articles_use_case.dart';
import 'package:flymap/usecase/get_route_preview_use_case.dart';
import 'package:flymap/usecase/poi_selection_config.dart';

part 'delegates/preview_preparation_delegate.dart';
part 'delegates/map_and_step_navigation_delegate.dart';
part 'delegates/wiki_selection_delegate.dart';
part 'delegates/download_flow_delegate.dart';

class FlightPreviewCubit extends Cubit<FlightPreviewState> {
  FlightPreviewCubit({
    required this.departure,
    required this.arrival,
    required ConnectivityChecker connectivityChecker,
    required GetRoutePreviewUseCase getRoutePreviewUseCase,
    required DownloadMapUseCase downloadMapUseCase,
    required DownloadPoiSummariesUseCase downloadPoiSummariesUseCase,
    required DownloadWikipediaArticlesUseCase downloadWikipediaArticlesUseCase,
    required GetFlightInfoUseCase getFlightInfoUseCase,
    required GetWikiArticlesUseCase getWikiArticlesUseCase,
    required UserFlightPrefsRepository userFlightPrefsRepository,
    required FlightRepository flightRepository,
    required SubscriptionRepository subscriptionRepository,
    required DeleteFlightUseCase deleteFlightUseCase,
    required AppAnalytics analytics,
    required AppCrashlytics crashlytics,
    bool autoPrepare = true,
  }) : _analytics = analytics,
       _crashlytics = crashlytics,
       super(
         FlightPreviewState.initial(
           selectedMapDetailLevel: _defaultMapDetailLevel(
             subscriptionRepository,
           ),
         ),
       ) {
    _previewPreparationDelegate = PreviewPreparationDelegate(
      this,
      connectivityChecker: connectivityChecker,
      getRoutePreviewUseCase: getRoutePreviewUseCase,
      getFlightInfoUseCase: getFlightInfoUseCase,
      getWikiArticlesUseCase: getWikiArticlesUseCase,
      userFlightPrefsRepository: userFlightPrefsRepository,
    );
    _navigationDelegate = MapAndStepNavigationDelegate(this);
    _wikiSelectionDelegate = WikiSelectionDelegate(this);
    _downloadFlowDelegate = DownloadFlowDelegate(
      this,
      downloadMapUseCase: downloadMapUseCase,
      downloadPoiSummariesUseCase: downloadPoiSummariesUseCase,
      downloadWikipediaArticlesUseCase: downloadWikipediaArticlesUseCase,
      flightRepository: flightRepository,
      subscriptionRepository: subscriptionRepository,
      deleteFlightUseCase: deleteFlightUseCase,
    );
    if (autoPrepare) {
      unawaited(preparePreview());
    }
  }

  final _logger = Logger('FlightPreviewCubit');
  final AppAnalytics _analytics;
  final AppCrashlytics _crashlytics;
  final Airport departure;
  final Airport arrival;
  late final PreviewPreparationDelegate _previewPreparationDelegate;
  late final MapAndStepNavigationDelegate _navigationDelegate;
  late final WikiSelectionDelegate _wikiSelectionDelegate;
  late final DownloadFlowDelegate _downloadFlowDelegate;

  Future<void> preparePreview() => _previewPreparationDelegate.preparePreview();

  Future<void> continueFromMap() => _navigationDelegate.continueFromMap();

  void selectMapDetailLevel(MapDetailLevel detailLevel) =>
      _navigationDelegate.selectMapDetailLevel(detailLevel);

  void continueFromOverview() => _navigationDelegate.continueFromOverview();

  void toggleWikiArticleSelection(String url) =>
      _wikiSelectionDelegate.toggleWikiArticleSelection(url);

  void toggleAllWikiArticleSelections() =>
      _wikiSelectionDelegate.toggleAllWikiArticleSelections();

  Future<void> startDownload() => _downloadFlowDelegate.startDownload();

  void cancelDownload() => _downloadFlowDelegate.cancelDownload();

  Future<bool> handleBackAction() => _navigationDelegate.handleBackAction();

  void _applyPoisForDetail(
    List<RoutePoiSummary> allPois, {
    required MapDetailLevel mapDetail,
  }) {
    final maxPois = PoiSelectionConfig.maxPois(mapDetail);
    final selected = allPois.take(maxPois).toList(growable: false);
    final proMax = PoiSelectionConfig.maxPois(MapDetailLevel.pro);
    final proCount = allPois.length < proMax ? allPois.length : proMax;
    _emitState(
      state.copyWith(
        flightInfo: state.flightInfo.copyWith(poi: selected),
        proPoiCount: proCount,
      ),
    );
  }

  Future<void> refreshPoisForPro() async {
    _applyPoisForDetail(state.allRoutePois, mapDetail: MapDetailLevel.pro);
  }

  void _emitState(FlightPreviewState nextState) {
    // Async delegate callbacks may complete after the cubit is disposed.
    if (isClosed) return;
    emit(nextState);
  }

  static MapDetailLevel _defaultMapDetailLevel(
    SubscriptionRepository subscriptionRepository,
  ) {
    return subscriptionRepository.currentStatus.isPro
        ? MapDetailLevel.pro
        : MapDetailLevel.basic;
  }

  @override
  Future<void> close() {
    _downloadFlowDelegate.dispose();
    return super.close();
  }
}
