part of '../flight_preview_cubit.dart';

class DownloadFlowDelegate {
  static const _regionArticleLanguageCode = 'en';

  DownloadFlowDelegate(
    this._cubit, {
    required DownloadMapUseCase downloadMapUseCase,
    required DownloadPoiSummariesUseCase downloadPoiSummariesUseCase,
    required DownloadRegionWikiArticlesUseCase
    downloadRegionWikiArticlesUseCase,
    required DownloadWikipediaArticlesUseCase downloadWikipediaArticlesUseCase,
    required FlightRepository flightRepository,
    required SubscriptionRepository subscriptionRepository,
    required DeleteFlightUseCase deleteFlightUseCase,
  }) : _downloadMapUseCase = downloadMapUseCase,
       _downloadPoiSummariesUseCase = downloadPoiSummariesUseCase,
       _downloadRegionWikiArticlesUseCase = downloadRegionWikiArticlesUseCase,
       _downloadWikipediaArticlesUseCase = downloadWikipediaArticlesUseCase,
       _flightRepository = flightRepository,
       _subscriptionRepository = subscriptionRepository,
       _deleteFlightUseCase = deleteFlightUseCase;

  final FlightPreviewCubit _cubit;
  final DownloadMapUseCase _downloadMapUseCase;
  final DownloadPoiSummariesUseCase _downloadPoiSummariesUseCase;
  final DownloadRegionWikiArticlesUseCase _downloadRegionWikiArticlesUseCase;
  final DownloadWikipediaArticlesUseCase _downloadWikipediaArticlesUseCase;
  final FlightRepository _flightRepository;
  final SubscriptionRepository _subscriptionRepository;
  final DeleteFlightUseCase _deleteFlightUseCase;

  StreamSubscription? _downloadSubscription;
  bool _downloadCancelled = false;
  String? _savedFlightIdDuringDownload;
  String? _activeArticleBundleId;

  int get _freeWikiArticlesSelectionLimit =>
      ProLimits.freeWikiArticlesSelectionLimit;

  String _articleBundleId(FlightRoute route) =>
      '${route.routeCode}_${route.departure.displayCode}_${route.arrival.displayCode}';

  int _poiDownloadTargetCount(List<RoutePoiSummary> pois) =>
      pois.where((poi) => poi.qid.trim().isNotEmpty).length;

  String _poiAndRegionsProgressMessage({
    required int poiCompleted,
    required int poiTotal,
    required int poiFailed,
    required int regionsCompleted,
    required int regionsTotal,
    required int regionsFailed,
  }) {
    final placesLabel = t.createFlight.downloading.poiSectionTitle;
    final regionsLabel = t.createFlight.overview.routeSummaryRegionsLabel;
    final placesFailed = poiFailed > 0 ? ' ($poiFailed failed)' : '';
    final regionsFailedLabel = regionsFailed > 0
        ? ' ($regionsFailed failed)'
        : '';
    return '$placesLabel: $poiCompleted/$poiTotal$placesFailed · '
        '$regionsLabel: $regionsCompleted/$regionsTotal$regionsFailedLabel';
  }

  Future<void> startDownload() async {
    if (_cubit.state.isDownloading) return;
    final route = _cubit.state.flightRoute;
    if (route == null) return;
    final isPro = _subscriptionRepository.currentStatus.isPro;

    // Defensive sync: ensure Pro downloads always use Pro POI set,
    // even if upgrade happened moments before tapping Download.
    if (isPro) {
      await _cubit.refreshPoisForPro();
    }

    _downloadCancelled = false;
    _savedFlightIdDuringDownload = null;
    _activeArticleBundleId = null;
    await _downloadSubscription?.cancel();

    final selectedUrls =
        (isPro
                ? _cubit.state.selectedArticleUrls
                : _cubit.state.selectedArticleUrls.take(
                    _freeWikiArticlesSelectionLimit,
                  ))
            .toList();
    if (!isPro &&
        selectedUrls.length != _cubit.state.selectedArticleUrls.length) {
      _cubit._emitState(
        _cubit.state.copyWith(selectedArticleUrls: selectedUrls),
      );
    }
    final poiToDownloadCount = _poiDownloadTargetCount(
      _cubit.state.flightInfo.poi,
    );
    final regionsToDownloadCount = _downloadRegionWikiArticlesUseCase
        .downloadTargetCount(_cubit.state.flightInfo.routeRegions);
    final poiAndRegionsToDownloadCount =
        poiToDownloadCount + regionsToDownloadCount;
    final flightId = DownloadMapUseCase.newFlightId();
    final articleBundleId = _articleBundleId(route);
    _activeArticleBundleId = articleBundleId;
    final initialHasArticlePhase = selectedUrls.isNotEmpty;
    final initialSections = DownloadSectionsState(
      map: DownloadSectionState.initial().copyWith(
        status: DownloadSectionStatus.active,
        message: t.createFlight.downloading.preparingMap,
      ),
      poi: poiAndRegionsToDownloadCount <= 0
          ? DownloadSectionState.initial().copyWith(
              status: DownloadSectionStatus.skipped,
            )
          : DownloadSectionState.initial().copyWith(
              status: DownloadSectionStatus.pending,
              total: poiAndRegionsToDownloadCount,
              message: _poiAndRegionsProgressMessage(
                poiCompleted: 0,
                poiTotal: poiToDownloadCount,
                poiFailed: 0,
                regionsCompleted: 0,
                regionsTotal: regionsToDownloadCount,
                regionsFailed: 0,
              ),
            ),
      articles: !initialHasArticlePhase
          ? DownloadSectionState.initial().copyWith(
              status: DownloadSectionStatus.skipped,
            )
          : DownloadSectionState.initial().copyWith(
              status: DownloadSectionStatus.pending,
              total: selectedUrls.length,
            ),
    );
    final hasArticlePhase = initialHasArticlePhase;
    var enrichedInfo = _cubit.state.flightInfo.copyWith(articles: const []);
    final effectiveMaxZoom = MapDownloadConfig.resolveMaxZoom(
      distanceKm: route.distanceInKm,
      detailLevel: _cubit.state.selectedMapDetailLevel,
    );
    final routeLengthKm = route.distanceInKm;

    _cubit._emitState(
      _cubit.state.copyWith(
        step: CreateFlightStep.wikipediaArticles,
        downloadSections: initialSections,
        isDownloading: true,
        downloadProgress: 0.0,
        downloadedBytes: 0,
        downloadStage: DownloadStage.initializing,
        poiDownloadCompleted: 0,
        poiDownloadTotal: poiAndRegionsToDownloadCount,
        poiDownloadFailed: 0,
        articleDownloadCompleted: 0,
        articleDownloadTotal: selectedUrls.length,
        articleDownloadFailed: 0,
        clearDownloadTileCount: true,
        clearDownloadWorkerCount: true,
        downloadDone: false,
        clearDownloadErrorMessage: true,
        clearErrorMessage: true,
      ),
    );
    unawaited(
      _cubit._analytics.log(
        DownloadStartedEvent(
          routeLengthKm: routeLengthKm,
          mapDetail: _cubit.state.selectedMapDetailLevel,
          articlesSelectedCount: selectedUrls.length,
          isProUser: isPro,
        ),
      ),
    );
    unawaited(
      _cubit._crashlytics.setContext(
        screen: 'create_flight_download',
        routeLengthKm: routeLengthKm.round(),
        mapDetail: _cubit.state.selectedMapDetailLevel.name,
        articlesSelectedCount: selectedUrls.length,
        downloadStage: 'initializing',
      ),
    );

    final mapPhase = await _runMapDownloadPhase(
      flightId: flightId,
      route: route,
      infoForSave: enrichedInfo,
      effectiveMaxZoom: effectiveMaxZoom,
      routeLengthKm: routeLengthKm,
    );
    if (!mapPhase.success || _downloadCancelled || _cubit.isClosed) {
      return;
    }

    _savedFlightIdDuringDownload = flightId;
    var poiHadIssues = false;
    var articleHadIssues = false;
    var regionDownloadedArticles = <FlightArticle>[];

    if (poiAndRegionsToDownloadCount > 0) {
      _cubit._emitState(
        _cubit.state.copyWith(
          isDownloading: true,
          downloadStage: DownloadStage.downloadingPoi,
          downloadSections: _cubit.state.downloadSections.copyWith(
            poi: _cubit.state.downloadSections.poi.copyWith(
              status: DownloadSectionStatus.active,
              message: _poiAndRegionsProgressMessage(
                poiCompleted: 0,
                poiTotal: poiToDownloadCount,
                poiFailed: 0,
                regionsCompleted: 0,
                regionsTotal: regionsToDownloadCount,
                regionsFailed: 0,
              ),
            ),
          ),
        ),
      );
      var poiCompleted = 0;
      var poiFailed = 0;
      var regionCompleted = 0;
      var regionFailed = 0;
      try {
        if (poiToDownloadCount > 0) {
          final poiResult = await _downloadPoiSummariesUseCase.call(
            pois: enrichedInfo.poi,
            preferredLanguageCode: LocaleSettings.currentLocale.languageCode,
            onProgress: (progress) {
              if (_downloadCancelled || _cubit.isClosed) return;
              poiCompleted = progress.completed;
              poiFailed = progress.failed;
              final combinedCompleted = poiCompleted + regionCompleted;
              final combinedFailed = poiFailed + regionFailed;
              _cubit._emitState(
                _cubit.state.copyWith(
                  isDownloading: true,
                  downloadStage: DownloadStage.downloadingPoi,
                  poiDownloadCompleted: combinedCompleted,
                  poiDownloadTotal: poiAndRegionsToDownloadCount,
                  poiDownloadFailed: combinedFailed,
                  downloadProgress: 0.0,
                  downloadDone: false,
                  downloadSections: _cubit.state.downloadSections.copyWith(
                    poi: _cubit.state.downloadSections.poi.copyWith(
                      status: DownloadSectionStatus.active,
                      completed: combinedCompleted,
                      total: poiAndRegionsToDownloadCount,
                      failed: combinedFailed,
                      message: _poiAndRegionsProgressMessage(
                        poiCompleted: poiCompleted,
                        poiTotal: poiToDownloadCount,
                        poiFailed: poiFailed,
                        regionsCompleted: regionCompleted,
                        regionsTotal: regionsToDownloadCount,
                        regionsFailed: regionFailed,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
          if (_downloadCancelled || _cubit.isClosed || poiResult.cancelled) {
            return;
          }
          poiCompleted = poiToDownloadCount;
          poiFailed = poiResult.failedCount;
          enrichedInfo = enrichedInfo.copyWith(poi: poiResult.pois);
        }

        if (regionsToDownloadCount > 0) {
          final regionResult = await _downloadRegionWikiArticlesUseCase.call(
            regions: enrichedInfo.routeRegions,
            preferredLanguageCode: _regionArticleLanguageCode,
            onProgress: (progress) {
              if (_downloadCancelled || _cubit.isClosed) return;
              regionCompleted = progress.completed;
              regionFailed = progress.failed;
              final combinedCompleted = poiCompleted + regionCompleted;
              final combinedFailed = poiFailed + regionFailed;
              _cubit._emitState(
                _cubit.state.copyWith(
                  isDownloading: true,
                  downloadStage: DownloadStage.downloadingPoi,
                  poiDownloadCompleted: combinedCompleted,
                  poiDownloadTotal: poiAndRegionsToDownloadCount,
                  poiDownloadFailed: combinedFailed,
                  downloadProgress: 0.0,
                  downloadDone: false,
                  downloadSections: _cubit.state.downloadSections.copyWith(
                    poi: _cubit.state.downloadSections.poi.copyWith(
                      status: DownloadSectionStatus.active,
                      completed: combinedCompleted,
                      total: poiAndRegionsToDownloadCount,
                      failed: combinedFailed,
                      message: _poiAndRegionsProgressMessage(
                        poiCompleted: poiCompleted,
                        poiTotal: poiToDownloadCount,
                        poiFailed: poiFailed,
                        regionsCompleted: regionCompleted,
                        regionsTotal: regionsToDownloadCount,
                        regionsFailed: regionFailed,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
          if (_downloadCancelled || _cubit.isClosed || regionResult.cancelled) {
            return;
          }
          final regionArticleUrls = regionResult.articleUrls;
          final regionArticlesTotal = regionArticleUrls.length;
          final regionsTotalWithArticles =
              regionsToDownloadCount + regionArticlesTotal;
          final combinedTotalWithArticles =
              poiToDownloadCount + regionsTotalWithArticles;
          regionCompleted = regionsToDownloadCount;
          regionFailed = regionResult.failedCount;
          enrichedInfo = enrichedInfo.copyWith(
            routeRegions: regionResult.regions,
          );
          _cubit._emitState(
            _cubit.state.copyWith(
              isDownloading: true,
              downloadStage: DownloadStage.downloadingPoi,
              poiDownloadCompleted: poiCompleted + regionCompleted,
              poiDownloadTotal: combinedTotalWithArticles,
              poiDownloadFailed: poiFailed + regionFailed,
              downloadSections: _cubit.state.downloadSections.copyWith(
                poi: _cubit.state.downloadSections.poi.copyWith(
                  total: combinedTotalWithArticles,
                  completed: poiCompleted + regionCompleted,
                  failed: poiFailed + regionFailed,
                  message: _poiAndRegionsProgressMessage(
                    poiCompleted: poiCompleted,
                    poiTotal: poiToDownloadCount,
                    poiFailed: poiFailed,
                    regionsCompleted: regionCompleted,
                    regionsTotal: regionsTotalWithArticles,
                    regionsFailed: regionFailed,
                  ),
                ),
              ),
            ),
          );

          if (regionArticleUrls.isNotEmpty) {
            final regionArticlesResult = await _downloadWikipediaArticlesUseCase
                .call(
                  bundleId: articleBundleId,
                  articleUrls: regionArticleUrls,
                  onProgress: (progress) {
                    if (_downloadCancelled || _cubit.isClosed) return;
                    regionCompleted =
                        regionsToDownloadCount + progress.completed;
                    regionFailed = regionResult.failedCount + progress.failed;
                    final combinedCompleted = poiCompleted + regionCompleted;
                    final combinedFailed = poiFailed + regionFailed;
                    _cubit._emitState(
                      _cubit.state.copyWith(
                        isDownloading: true,
                        downloadStage: DownloadStage.downloadingPoi,
                        poiDownloadCompleted: combinedCompleted,
                        poiDownloadTotal: combinedTotalWithArticles,
                        poiDownloadFailed: combinedFailed,
                        downloadProgress: 0.0,
                        downloadDone: false,
                        downloadSections: _cubit.state.downloadSections
                            .copyWith(
                              poi: _cubit.state.downloadSections.poi.copyWith(
                                status: DownloadSectionStatus.active,
                                completed: combinedCompleted,
                                total: combinedTotalWithArticles,
                                failed: combinedFailed,
                                message: _poiAndRegionsProgressMessage(
                                  poiCompleted: poiCompleted,
                                  poiTotal: poiToDownloadCount,
                                  poiFailed: poiFailed,
                                  regionsCompleted: regionCompleted,
                                  regionsTotal: regionsTotalWithArticles,
                                  regionsFailed: regionFailed,
                                ),
                              ),
                            ),
                      ),
                    );
                  },
                );
            if (_downloadCancelled ||
                _cubit.isClosed ||
                regionArticlesResult.cancelled) {
              return;
            }
            regionDownloadedArticles = regionArticlesResult.articles;
            regionCompleted = regionsTotalWithArticles;
            regionFailed =
                regionResult.failedCount + regionArticlesResult.failedCount;
            enrichedInfo = enrichedInfo.copyWith(
              articles: regionDownloadedArticles,
            );
          }
        }

        final persisted = await _flightRepository.updateFlightInfo(
          flightId: flightId,
          info: enrichedInfo,
        );
        final effectivePoiAndRegionsTotal =
            poiCompleted + regionCompleted > poiAndRegionsToDownloadCount
            ? poiCompleted + regionCompleted
            : poiAndRegionsToDownloadCount;
        final combinedFailedCount =
            (poiFailed + regionFailed + (!persisted ? 1 : 0))
                .clamp(0, effectivePoiAndRegionsTotal)
                .toInt();
        final combinedSucceededCount =
            effectivePoiAndRegionsTotal - combinedFailedCount;
        unawaited(
          _cubit._analytics.log(
            PoiDownloadCompletedEvent(
              routeLengthKm: routeLengthKm,
              totalCount: effectivePoiAndRegionsTotal,
              succeededCount: combinedSucceededCount,
              failedCount: combinedFailedCount,
              isProUser: isPro,
            ),
          ),
        );
        poiHadIssues = combinedFailedCount > 0 || !persisted;
        _cubit._emitState(
          _cubit.state.copyWith(
            isDownloading: true,
            downloadStage: hasArticlePhase
                ? DownloadStage.downloadingArticles
                : DownloadStage.completed,
            poiDownloadCompleted: effectivePoiAndRegionsTotal,
            poiDownloadTotal: effectivePoiAndRegionsTotal,
            poiDownloadFailed: combinedFailedCount,
            downloadProgress: 0.0,
            downloadSections: _cubit.state.downloadSections.copyWith(
              poi: _cubit.state.downloadSections.poi.copyWith(
                status: poiHadIssues
                    ? DownloadSectionStatus.completedWithIssues
                    : DownloadSectionStatus.completed,
                completed: effectivePoiAndRegionsTotal,
                total: effectivePoiAndRegionsTotal,
                failed: combinedFailedCount,
                message: poiHadIssues
                    ? t.createFlight.downloading.completedWithIssues
                    : t.createFlight.downloading.completed,
              ),
            ),
          ),
        );
      } catch (e, stackTrace) {
        _cubit._logger.error(
          'POI summary download failed; continuing with map/article download: $e',
        );
        unawaited(
          _cubit._crashlytics.recordError(
            e,
            stackTrace,
            reason: 'poi_summary_download_failed',
          ),
        );
        if (_downloadCancelled || _cubit.isClosed) return;
        poiHadIssues = true;
        unawaited(
          _cubit._analytics.log(
            PoiDownloadCompletedEvent(
              routeLengthKm: routeLengthKm,
              totalCount: poiAndRegionsToDownloadCount,
              succeededCount: 0,
              failedCount: poiAndRegionsToDownloadCount,
              isProUser: isPro,
            ),
          ),
        );
        _cubit._emitState(
          _cubit.state.copyWith(
            isDownloading: true,
            downloadStage: hasArticlePhase
                ? DownloadStage.downloadingArticles
                : DownloadStage.completed,
            poiDownloadCompleted: poiAndRegionsToDownloadCount,
            poiDownloadTotal: poiAndRegionsToDownloadCount,
            poiDownloadFailed: poiAndRegionsToDownloadCount,
            downloadProgress: 0.0,
            downloadSections: _cubit.state.downloadSections.copyWith(
              poi: _cubit.state.downloadSections.poi.copyWith(
                status: DownloadSectionStatus.failed,
                completed: poiAndRegionsToDownloadCount,
                total: poiAndRegionsToDownloadCount,
                failed: poiAndRegionsToDownloadCount,
                message: t.createFlight.downloading.failed,
              ),
            ),
          ),
        );
      }
    }

    if (_downloadCancelled || _cubit.isClosed) return;

    final effectiveArticleUrls = selectedUrls;
    var downloadedArticles = <FlightArticle>[...regionDownloadedArticles];
    if (hasArticlePhase) {
      _cubit._emitState(
        _cubit.state.copyWith(
          isDownloading: true,
          downloadStage: DownloadStage.downloadingArticles,
          articleDownloadTotal: effectiveArticleUrls.length,
          downloadSections: _cubit.state.downloadSections.copyWith(
            articles: _cubit.state.downloadSections.articles.copyWith(
              status: DownloadSectionStatus.active,
              total: effectiveArticleUrls.length,
              message: t.createFlight.downloading.preparingArticles,
            ),
          ),
        ),
      );
      try {
        final result = await _downloadWikipediaArticlesUseCase.call(
          bundleId: articleBundleId,
          articleUrls: effectiveArticleUrls,
          onProgress: (progress) {
            if (_downloadCancelled || _cubit.isClosed) return;
            _cubit._emitState(
              _cubit.state.copyWith(
                isDownloading: true,
                downloadStage: DownloadStage.downloadingArticles,
                articleDownloadCompleted: progress.completed,
                articleDownloadTotal: progress.total,
                articleDownloadFailed: progress.failed,
                downloadProgress: 0.0,
                downloadDone: false,
                downloadSections: _cubit.state.downloadSections.copyWith(
                  articles: _cubit.state.downloadSections.articles.copyWith(
                    status: DownloadSectionStatus.active,
                    completed: progress.completed,
                    total: progress.total,
                    failed: progress.failed,
                    message: progress.failed > 0
                        ? t.createFlight.downloading.articlesProgressWithFailed(
                            completed: progress.completed,
                            total: progress.total,
                            failed: progress.failed,
                          )
                        : t.createFlight.downloading.articlesProgress(
                            completed: progress.completed,
                            total: progress.total,
                          ),
                  ),
                ),
              ),
            );
          },
        );

        if (_downloadCancelled || _cubit.isClosed || result.cancelled) {
          return;
        }

        downloadedArticles = [...regionDownloadedArticles, ...result.articles];
        enrichedInfo = enrichedInfo.copyWith(articles: downloadedArticles);
        final persisted = await _flightRepository.updateFlightInfo(
          flightId: flightId,
          info: enrichedInfo,
        );
        articleHadIssues = result.failedCount > 0 || !persisted;
        _cubit._emitState(
          _cubit.state.copyWith(
            isDownloading: true,
            downloadStage: DownloadStage.completed,
            poiDownloadCompleted: _cubit.state.poiDownloadCompleted,
            poiDownloadTotal: _cubit.state.poiDownloadTotal,
            poiDownloadFailed: _cubit.state.poiDownloadFailed,
            articleDownloadCompleted: effectiveArticleUrls.length,
            articleDownloadTotal: effectiveArticleUrls.length,
            articleDownloadFailed: result.failedCount,
            downloadProgress: 0.0,
            downloadSections: _cubit.state.downloadSections.copyWith(
              articles: _cubit.state.downloadSections.articles.copyWith(
                status: articleHadIssues
                    ? DownloadSectionStatus.completedWithIssues
                    : DownloadSectionStatus.completed,
                completed: effectiveArticleUrls.length,
                total: effectiveArticleUrls.length,
                failed: result.failedCount + (!persisted ? 1 : 0),
                message: articleHadIssues
                    ? t.createFlight.downloading.completedWithIssues
                    : t.createFlight.downloading.completed,
              ),
            ),
          ),
        );
      } catch (e) {
        _cubit._logger.error(
          'Article download failed; continuing with map-only download: $e',
        );
        unawaited(
          _cubit._crashlytics.recordError(
            e,
            StackTrace.current,
            reason: 'article_download_failed',
          ),
        );
        if (_downloadCancelled || _cubit.isClosed) return;
        articleHadIssues = true;
        _cubit._emitState(
          _cubit.state.copyWith(
            isDownloading: true,
            downloadStage: DownloadStage.completed,
            poiDownloadCompleted: _cubit.state.poiDownloadCompleted,
            poiDownloadTotal: _cubit.state.poiDownloadTotal,
            poiDownloadFailed: _cubit.state.poiDownloadFailed,
            articleDownloadCompleted: effectiveArticleUrls.length,
            articleDownloadTotal: effectiveArticleUrls.length,
            articleDownloadFailed: effectiveArticleUrls.length,
            downloadProgress: 0.0,
            errorMessage: t.createFlight.errors.someArticlesFailed,
            downloadSections: _cubit.state.downloadSections.copyWith(
              articles: _cubit.state.downloadSections.articles.copyWith(
                status: DownloadSectionStatus.failed,
                completed: effectiveArticleUrls.length,
                total: effectiveArticleUrls.length,
                failed: effectiveArticleUrls.length,
                message: t.createFlight.downloading.failed,
              ),
            ),
          ),
        );
      }
    }

    if (_downloadCancelled || _cubit.isClosed) return;
    unawaited(
      _cubit._analytics.log(
        DownloadCompletedEvent(
          routeLengthKm: routeLengthKm,
          articlesDownloadedCount: downloadedArticles.length,
          mapSizeBytes: mapPhase.fileSize,
        ),
      ),
    );
    unawaited(_cubit._crashlytics.setContext(downloadStage: 'completed'));
    _cubit._emitState(
      _cubit.state.copyWith(
        isDownloading: false,
        downloadProgress: 1.0,
        downloadedBytes: mapPhase.fileSize,
        downloadStage: DownloadStage.completed,
        downloadDone: true,
        clearDownloadErrorMessage: true,
      ),
    );
  }

  void cancelDownload() {
    if (!_cubit.state.isDownloading) return;
    _downloadCancelled = true;
    final rollbackFlightId = _savedFlightIdDuringDownload;
    final bundleId = _activeArticleBundleId;
    _downloadPoiSummariesUseCase.cancel();
    _downloadRegionWikiArticlesUseCase.cancel();
    _downloadWikipediaArticlesUseCase.cancel();
    _downloadMapUseCase.cancel();
    unawaited(_downloadSubscription?.cancel());
    _cubit._emitState(
      _cubit.state.copyWith(
        downloadSections: const DownloadSectionsState.initial(),
        isDownloading: false,
        downloadProgress: 0.0,
        downloadStage: DownloadStage.idle,
        poiDownloadCompleted: 0,
        poiDownloadTotal: 0,
        poiDownloadFailed: 0,
        articleDownloadCompleted: 0,
        articleDownloadTotal: 0,
        articleDownloadFailed: 0,
        clearDownloadTileCount: true,
        clearDownloadWorkerCount: true,
        clearErrorMessage: true,
        clearDownloadErrorMessage: true,
      ),
    );
    _savedFlightIdDuringDownload = null;
    _activeArticleBundleId = null;
    if (rollbackFlightId != null) {
      unawaited(
        _rollbackSavedFlightAfterCancel(
          flightId: rollbackFlightId,
          bundleId: bundleId,
        ),
      );
    } else if (bundleId != null) {
      unawaited(_downloadWikipediaArticlesUseCase.cleanupBundleMedia(bundleId));
    }
  }

  void dispose() {
    _downloadCancelled = true;
    _savedFlightIdDuringDownload = null;
    _activeArticleBundleId = null;
    _downloadPoiSummariesUseCase.cancel();
    _downloadRegionWikiArticlesUseCase.cancel();
    _downloadWikipediaArticlesUseCase.cancel();
    _downloadMapUseCase.cancel();
    unawaited(_downloadSubscription?.cancel());
  }

  Future<_MapDownloadPhaseResult> _runMapDownloadPhase({
    required String flightId,
    required FlightRoute route,
    required FlightInfo infoForSave,
    required int effectiveMaxZoom,
    required double routeLengthKm,
  }) async {
    final completer = Completer<_MapDownloadPhaseResult>();
    try {
      _downloadSubscription = _downloadMapUseCase
          .call(
            flightId: flightId,
            flightRoute: route,
            flightInfo: infoForSave,
            maxZoom: effectiveMaxZoom,
          )
          .listen(
            (event) {
              if (_downloadCancelled || _cubit.isClosed) {
                if (!completer.isCompleted) {
                  completer.complete(
                    _MapDownloadPhaseResult(
                      success: false,
                      fileSize: _cubit.state.downloadedBytes,
                    ),
                  );
                }
                return;
              }
              switch (event) {
                case DownloadMapProgress():
                  _cubit._emitState(
                    _cubit.state.copyWith(
                      isDownloading: true,
                      downloadProgress: event.progress.clamp(0.0, 1.0),
                      downloadedBytes: event.downloadedBytes,
                      downloadStage: DownloadStage.downloading,
                      downloadDone: false,
                      downloadSections: _cubit.state.downloadSections.copyWith(
                        map: _cubit.state.downloadSections.map.copyWith(
                          status: DownloadSectionStatus.active,
                          progress: event.progress.clamp(0.0, 1.0),
                          downloadedBytes: event.downloadedBytes,
                          message: t.createFlight.downloading.downloaded(
                            size: _formatDownloadedMb(event.downloadedBytes),
                          ),
                        ),
                      ),
                    ),
                  );
                  break;
                case DownloadMapDone():
                  _cubit._emitState(
                    _cubit.state.copyWith(
                      isDownloading: true,
                      downloadProgress: 1.0,
                      downloadedBytes: event.fileSize,
                      downloadStage: DownloadStage.completed,
                      downloadDone: false,
                      downloadSections: _cubit.state.downloadSections.copyWith(
                        map: _cubit.state.downloadSections.map.copyWith(
                          status: DownloadSectionStatus.completed,
                          progress: 1.0,
                          downloadedBytes: event.fileSize,
                          message: t.createFlight.downloading.completed,
                        ),
                      ),
                    ),
                  );
                  if (!completer.isCompleted) {
                    completer.complete(
                      _MapDownloadPhaseResult(
                        success: true,
                        fileSize: event.fileSize,
                      ),
                    );
                  }
                  break;
                case DownloadMapError():
                  final failureReason = _mapDownloadFailureReason(
                    event.errorMsg,
                  );
                  final failureStage = _mapDownloadFailureStage(event.errorMsg);
                  unawaited(
                    _cubit._analytics.log(
                      DownloadFailedEvent(
                        stage: 'map_download',
                        errorType: failureReason,
                        errorMessage: event.errorMsg,
                        routeLengthKm: routeLengthKm,
                      ),
                    ),
                  );
                  unawaited(
                    _cubit._crashlytics.setContext(
                      downloadStage:
                          '$failureStage:${_contextErrorSnippet(event.errorMsg)}',
                    ),
                  );
                  unawaited(
                    _cubit._crashlytics.recordError(
                      Exception(
                        '[map-download:$failureReason] ${event.errorMsg}',
                      ),
                      StackTrace.current,
                      reason: failureReason,
                    ),
                  );
                  _cubit._emitState(
                    _cubit.state.copyWith(
                      isDownloading: false,
                      downloadStage: DownloadStage.failed,
                      downloadErrorMessage: event.errorMsg,
                      downloadSections: _cubit.state.downloadSections.copyWith(
                        map: _cubit.state.downloadSections.map.copyWith(
                          status: DownloadSectionStatus.failed,
                          message: event.errorMsg,
                        ),
                      ),
                    ),
                  );
                  if (!completer.isCompleted) {
                    completer.complete(
                      _MapDownloadPhaseResult(
                        success: false,
                        fileSize: _cubit.state.downloadedBytes,
                      ),
                    );
                  }
                  break;
                case DownloadMapInitializing():
                  unawaited(
                    _cubit._crashlytics.setContext(
                      downloadStage: 'initializing',
                    ),
                  );
                  _cubit._emitState(
                    _cubit.state.copyWith(
                      isDownloading: true,
                      downloadedBytes: 0,
                      downloadStage: DownloadStage.initializing,
                      downloadProgress: 0.0,
                      downloadDone: false,
                      clearDownloadTileCount: true,
                      clearDownloadWorkerCount: true,
                      clearDownloadErrorMessage: true,
                      downloadSections: _cubit.state.downloadSections.copyWith(
                        map: _cubit.state.downloadSections.map.copyWith(
                          status: DownloadSectionStatus.active,
                          message: t.createFlight.downloading.preparingMap,
                        ),
                      ),
                    ),
                  );
                  break;
                case DownloadMapComputingTiles():
                  unawaited(
                    _cubit._crashlytics.setContext(
                      downloadStage: 'computing_tiles',
                    ),
                  );
                  _cubit._emitState(
                    _cubit.state.copyWith(
                      isDownloading: true,
                      downloadStage: DownloadStage.computingTiles,
                      downloadTileCount: event.totalTiles,
                      downloadSections: _cubit.state.downloadSections.copyWith(
                        map: _cubit.state.downloadSections.map.copyWith(
                          status: DownloadSectionStatus.active,
                          message: t.createFlight.downloading
                              .computingTilesWithCount(count: event.totalTiles),
                        ),
                      ),
                    ),
                  );
                  break;
                case DownloadMapStartingWorkers():
                  unawaited(
                    _cubit._crashlytics.setContext(
                      downloadStage: 'starting_workers',
                    ),
                  );
                  _cubit._emitState(
                    _cubit.state.copyWith(
                      isDownloading: true,
                      downloadStage: DownloadStage.startingWorkers,
                      downloadWorkerCount: event.workerCount,
                      downloadSections: _cubit.state.downloadSections.copyWith(
                        map: _cubit.state.downloadSections.map.copyWith(
                          status: DownloadSectionStatus.active,
                          message:
                              t.createFlight.downloading.preparingForDownload,
                        ),
                      ),
                    ),
                  );
                  break;
                case DownloadMapFinalizing():
                  unawaited(
                    _cubit._crashlytics.setContext(downloadStage: 'finalizing'),
                  );
                  _cubit._emitState(
                    _cubit.state.copyWith(
                      isDownloading: true,
                      downloadStage: DownloadStage.finalizing,
                      downloadSections: _cubit.state.downloadSections.copyWith(
                        map: _cubit.state.downloadSections.map.copyWith(
                          status: DownloadSectionStatus.active,
                          message: t.createFlight.downloading.finalizing,
                        ),
                      ),
                    ),
                  );
                  break;
                case DownloadMapVerifying():
                  unawaited(
                    _cubit._crashlytics.setContext(downloadStage: 'verifying'),
                  );
                  _cubit._emitState(
                    _cubit.state.copyWith(
                      isDownloading: true,
                      downloadStage: DownloadStage.verifying,
                      downloadSections: _cubit.state.downloadSections.copyWith(
                        map: _cubit.state.downloadSections.map.copyWith(
                          status: DownloadSectionStatus.active,
                          message: t.createFlight.downloading.verifying,
                        ),
                      ),
                    ),
                  );
                  break;
              }
            },
            onDone: () {
              if (!completer.isCompleted) {
                completer.complete(
                  _MapDownloadPhaseResult(
                    success: false,
                    fileSize: _cubit.state.downloadedBytes,
                  ),
                );
              }
            },
          );
      final result = await completer.future;
      await _downloadSubscription?.cancel();
      _downloadSubscription = null;
      return result;
    } catch (e, stackTrace) {
      unawaited(
        _cubit._analytics.log(
          DownloadFailedEvent(
            stage: 'start',
            errorType: e.runtimeType.toString(),
            errorMessage: e.toString(),
            routeLengthKm: routeLengthKm,
          ),
        ),
      );
      unawaited(
        _cubit._crashlytics.recordError(
          e,
          stackTrace,
          reason: 'map_download_stream_setup_failed',
        ),
      );
      _cubit._emitState(
        _cubit.state.copyWith(
          isDownloading: false,
          downloadStage: DownloadStage.failed,
          downloadErrorMessage: t.createFlight.errors.failedStartDownload(
            error: e.toString(),
          ),
          downloadSections: _cubit.state.downloadSections.copyWith(
            map: _cubit.state.downloadSections.map.copyWith(
              status: DownloadSectionStatus.failed,
              message: e.toString(),
            ),
          ),
        ),
      );
      return _MapDownloadPhaseResult(
        success: false,
        fileSize: _cubit.state.downloadedBytes,
      );
    }
  }

  Future<void> _rollbackSavedFlightAfterCancel({
    required String flightId,
    String? bundleId,
  }) async {
    try {
      final deleted = await _deleteFlightUseCase(flightId);
      if (!deleted && !_cubit.isClosed) {
        _cubit._emitState(
          _cubit.state.copyWith(
            downloadErrorMessage: t.createFlight.errors.failedStartDownload(
              error: 'Failed to rollback cancelled download',
            ),
          ),
        );
      }
    } catch (e) {
      if (!_cubit.isClosed) {
        _cubit._emitState(
          _cubit.state.copyWith(
            downloadErrorMessage: t.createFlight.errors.failedStartDownload(
              error: e.toString(),
            ),
          ),
        );
      }
    } finally {
      if (bundleId != null) {
        await _downloadWikipediaArticlesUseCase.cleanupBundleMedia(bundleId);
      }
    }
  }

  String _formatDownloadedMb(int bytes) {
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  String _mapDownloadFailureReason(String errorMessage) {
    final normalized = errorMessage.toLowerCase();
    if (normalized.contains('failed to verify mbtiles file') ||
        normalized.contains('mbtiles verification failed')) {
      return 'map_download_failed_mbtiles_verification';
    }
    if (normalized.contains('no internet')) {
      return 'map_download_failed_no_internet';
    }
    if (normalized.contains('tiles downloaded')) {
      return 'map_download_failed_low_tile_coverage';
    }
    if (normalized.contains('canceled')) {
      return 'map_download_failed_canceled';
    }
    return 'map_download_failed';
  }

  String _mapDownloadFailureStage(String errorMessage) {
    final normalized = errorMessage.toLowerCase();
    if (normalized.contains('failed to verify mbtiles file') ||
        normalized.contains('mbtiles verification failed')) {
      return 'failed_verifying_mbtiles';
    }
    if (normalized.contains('tiles downloaded')) {
      return 'failed_tile_coverage';
    }
    if (normalized.contains('no internet')) {
      return 'failed_no_internet';
    }
    if (normalized.contains('canceled')) {
      return 'failed_canceled';
    }
    return 'failed';
  }

  String _contextErrorSnippet(String errorMessage) {
    final compact = errorMessage.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.length <= 160) return compact;
    return '${compact.substring(0, 160)}...';
  }
}

class _MapDownloadPhaseResult {
  const _MapDownloadPhaseResult({
    required this.success,
    required this.fileSize,
  });

  final bool success;
  final int fileSize;
}
