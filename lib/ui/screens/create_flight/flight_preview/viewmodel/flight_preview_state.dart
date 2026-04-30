import 'package:equatable/equatable.dart';
import 'package:flymap/entity/flight_info.dart';
import 'package:flymap/entity/flight_route.dart';
import 'package:flymap/entity/map_detail_level.dart';
import 'package:flymap/entity/route_poi_summary.dart';
import 'package:flymap/entity/wiki_article_candidate.dart';

enum CreateFlightStep {
  routeNotSupported,
  mapPreview,
  overview,
  wikipediaArticles,
}

enum DownloadStage {
  idle,
  downloadingPoi,
  downloadingArticles,
  initializing,
  computingTiles,
  startingWorkers,
  downloading,
  finalizing,
  verifying,
  completed,
  failed,
}

enum DownloadSectionStatus {
  pending,
  active,
  completed,
  completedWithIssues,
  failed,
  skipped,
}

class DownloadSectionState extends Equatable {
  const DownloadSectionState({
    required this.status,
    required this.completed,
    required this.total,
    required this.failed,
    required this.progress,
    required this.downloadedBytes,
    required this.message,
  });

  const DownloadSectionState.initial()
    : status = DownloadSectionStatus.pending,
      completed = 0,
      total = 0,
      failed = 0,
      progress = 0,
      downloadedBytes = 0,
      message = null;

  final DownloadSectionStatus status;
  final int completed;
  final int total;
  final int failed;
  final double progress;
  final int downloadedBytes;
  final String? message;

  DownloadSectionState copyWith({
    DownloadSectionStatus? status,
    int? completed,
    int? total,
    int? failed,
    double? progress,
    int? downloadedBytes,
    String? message,
    bool clearMessage = false,
  }) {
    return DownloadSectionState(
      status: status ?? this.status,
      completed: completed ?? this.completed,
      total: total ?? this.total,
      failed: failed ?? this.failed,
      progress: progress ?? this.progress,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    completed,
    total,
    failed,
    progress,
    downloadedBytes,
    message,
  ];
}

class DownloadSectionsState extends Equatable {
  const DownloadSectionsState({
    required this.map,
    required this.poi,
    required this.articles,
  });

  const DownloadSectionsState.initial()
    : map = const DownloadSectionState.initial(),
      poi = const DownloadSectionState.initial(),
      articles = const DownloadSectionState.initial();

  final DownloadSectionState map;
  final DownloadSectionState poi;
  final DownloadSectionState articles;

  DownloadSectionsState copyWith({
    DownloadSectionState? map,
    DownloadSectionState? poi,
    DownloadSectionState? articles,
  }) {
    return DownloadSectionsState(
      map: map ?? this.map,
      poi: poi ?? this.poi,
      articles: articles ?? this.articles,
    );
  }

  @override
  List<Object?> get props => [map, poi, articles];
}

class RoutePreviewState extends Equatable {
  const RoutePreviewState({
    required this.flightRoute,
    required this.allRoutePois,
    required this.flightInfo,
    required this.proPoiCount,
    required this.selectedMapDetailLevel,
    required this.articleCandidates,
    required this.selectedArticleUrls,
  });

  const RoutePreviewState.initial({
    MapDetailLevel initialSelectedMapDetailLevel = MapDetailLevel.basic,
  }) : flightRoute = null,
       allRoutePois = const [],
       flightInfo = FlightInfo.empty,
       proPoiCount = null,
       selectedMapDetailLevel = initialSelectedMapDetailLevel,
       articleCandidates = const [],
       selectedArticleUrls = const [];

  final FlightRoute? flightRoute;
  final List<RoutePoiSummary> allRoutePois;
  final FlightInfo flightInfo;
  final int? proPoiCount;
  final MapDetailLevel selectedMapDetailLevel;
  final List<WikiArticleCandidate> articleCandidates;
  final List<String> selectedArticleUrls;

  RoutePreviewState copyWith({
    FlightRoute? flightRoute,
    bool clearFlightRoute = false,
    List<RoutePoiSummary>? allRoutePois,
    bool clearAllRoutePois = false,
    FlightInfo? flightInfo,
    int? proPoiCount,
    bool clearProPoiCount = false,
    MapDetailLevel? selectedMapDetailLevel,
    List<WikiArticleCandidate>? articleCandidates,
    List<String>? selectedArticleUrls,
    bool clearSelectedArticleUrls = false,
  }) {
    return RoutePreviewState(
      flightRoute: clearFlightRoute ? null : flightRoute ?? this.flightRoute,
      allRoutePois: clearAllRoutePois
          ? const []
          : allRoutePois ?? this.allRoutePois,
      flightInfo: flightInfo ?? this.flightInfo,
      proPoiCount: clearProPoiCount ? null : proPoiCount ?? this.proPoiCount,
      selectedMapDetailLevel:
          selectedMapDetailLevel ?? this.selectedMapDetailLevel,
      articleCandidates: articleCandidates ?? this.articleCandidates,
      selectedArticleUrls: clearSelectedArticleUrls
          ? const []
          : selectedArticleUrls ?? this.selectedArticleUrls,
    );
  }

  @override
  List<Object?> get props => [
    flightRoute,
    allRoutePois,
    flightInfo,
    proPoiCount,
    selectedMapDetailLevel,
    articleCandidates,
    selectedArticleUrls,
  ];
}

class PreviewLoadState extends Equatable {
  const PreviewLoadState({
    required this.isWikiSuggestionsLoading,
    required this.isPreviewLoading,
    required this.isOverviewLoading,
    required this.hasInternetForMapPreview,
  });

  const PreviewLoadState.initial()
    : isWikiSuggestionsLoading = false,
      isPreviewLoading = true,
      isOverviewLoading = false,
      hasInternetForMapPreview = true;

  final bool isWikiSuggestionsLoading;
  final bool isPreviewLoading;
  final bool isOverviewLoading;
  final bool hasInternetForMapPreview;

  PreviewLoadState copyWith({
    bool? isWikiSuggestionsLoading,
    bool? isPreviewLoading,
    bool? isOverviewLoading,
    bool? hasInternetForMapPreview,
  }) {
    return PreviewLoadState(
      isWikiSuggestionsLoading:
          isWikiSuggestionsLoading ?? this.isWikiSuggestionsLoading,
      isPreviewLoading: isPreviewLoading ?? this.isPreviewLoading,
      isOverviewLoading: isOverviewLoading ?? this.isOverviewLoading,
      hasInternetForMapPreview:
          hasInternetForMapPreview ?? this.hasInternetForMapPreview,
    );
  }

  @override
  List<Object?> get props => [
    isWikiSuggestionsLoading,
    isPreviewLoading,
    isOverviewLoading,
    hasInternetForMapPreview,
  ];
}

class PreviewDownloadState extends Equatable {
  const PreviewDownloadState({
    required this.downloadSections,
    required this.isDownloading,
    required this.downloadProgress,
    required this.downloadedBytes,
    required this.downloadStage,
    required this.poiDownloadCompleted,
    required this.poiDownloadTotal,
    required this.poiDownloadFailed,
    required this.articleDownloadCompleted,
    required this.articleDownloadTotal,
    required this.articleDownloadFailed,
    required this.downloadTileCount,
    required this.downloadWorkerCount,
    required this.downloadDone,
  });

  const PreviewDownloadState.initial()
    : downloadSections = const DownloadSectionsState.initial(),
      isDownloading = false,
      downloadProgress = 0.0,
      downloadedBytes = 0,
      downloadStage = DownloadStage.idle,
      poiDownloadCompleted = 0,
      poiDownloadTotal = 0,
      poiDownloadFailed = 0,
      articleDownloadCompleted = 0,
      articleDownloadTotal = 0,
      articleDownloadFailed = 0,
      downloadTileCount = null,
      downloadWorkerCount = null,
      downloadDone = false;

  final DownloadSectionsState downloadSections;
  final bool isDownloading;
  final double downloadProgress;
  final int downloadedBytes;
  final DownloadStage downloadStage;
  final int poiDownloadCompleted;
  final int poiDownloadTotal;
  final int poiDownloadFailed;
  final int articleDownloadCompleted;
  final int articleDownloadTotal;
  final int articleDownloadFailed;
  final int? downloadTileCount;
  final int? downloadWorkerCount;
  final bool downloadDone;

  PreviewDownloadState copyWith({
    DownloadSectionsState? downloadSections,
    bool? isDownloading,
    double? downloadProgress,
    int? downloadedBytes,
    DownloadStage? downloadStage,
    int? poiDownloadCompleted,
    int? poiDownloadTotal,
    int? poiDownloadFailed,
    int? articleDownloadCompleted,
    int? articleDownloadTotal,
    int? articleDownloadFailed,
    int? downloadTileCount,
    bool clearDownloadTileCount = false,
    int? downloadWorkerCount,
    bool clearDownloadWorkerCount = false,
    bool? downloadDone,
  }) {
    return PreviewDownloadState(
      downloadSections: downloadSections ?? this.downloadSections,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      downloadStage: downloadStage ?? this.downloadStage,
      poiDownloadCompleted: poiDownloadCompleted ?? this.poiDownloadCompleted,
      poiDownloadTotal: poiDownloadTotal ?? this.poiDownloadTotal,
      poiDownloadFailed: poiDownloadFailed ?? this.poiDownloadFailed,
      articleDownloadCompleted:
          articleDownloadCompleted ?? this.articleDownloadCompleted,
      articleDownloadTotal: articleDownloadTotal ?? this.articleDownloadTotal,
      articleDownloadFailed:
          articleDownloadFailed ?? this.articleDownloadFailed,
      downloadTileCount: clearDownloadTileCount
          ? null
          : downloadTileCount ?? this.downloadTileCount,
      downloadWorkerCount: clearDownloadWorkerCount
          ? null
          : downloadWorkerCount ?? this.downloadWorkerCount,
      downloadDone: downloadDone ?? this.downloadDone,
    );
  }

  @override
  List<Object?> get props => [
    downloadSections,
    isDownloading,
    downloadProgress,
    downloadedBytes,
    downloadStage,
    poiDownloadCompleted,
    poiDownloadTotal,
    poiDownloadFailed,
    articleDownloadCompleted,
    articleDownloadTotal,
    articleDownloadFailed,
    downloadTileCount,
    downloadWorkerCount,
    downloadDone,
  ];
}

class PreviewMessageState extends Equatable {
  const PreviewMessageState({
    required this.errorMessage,
    required this.downloadErrorMessage,
  });

  const PreviewMessageState.initial()
    : errorMessage = null,
      downloadErrorMessage = null;

  final String? errorMessage;
  final String? downloadErrorMessage;

  PreviewMessageState copyWith({
    String? errorMessage,
    bool clearErrorMessage = false,
    String? downloadErrorMessage,
    bool clearDownloadErrorMessage = false,
  }) {
    return PreviewMessageState(
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      downloadErrorMessage: clearDownloadErrorMessage
          ? null
          : downloadErrorMessage ?? this.downloadErrorMessage,
    );
  }

  @override
  List<Object?> get props => [errorMessage, downloadErrorMessage];
}

class FlightPreviewState extends Equatable {
  const FlightPreviewState({
    required this.step,
    required this.routeState,
    required this.loadState,
    required this.downloadState,
    required this.messageState,
  });

  factory FlightPreviewState.initial({
    MapDetailLevel selectedMapDetailLevel = MapDetailLevel.basic,
  }) {
    return FlightPreviewState(
      step: CreateFlightStep.mapPreview,
      routeState: RoutePreviewState.initial(
        initialSelectedMapDetailLevel: selectedMapDetailLevel,
      ),
      loadState: const PreviewLoadState.initial(),
      downloadState: const PreviewDownloadState.initial(),
      messageState: const PreviewMessageState.initial(),
    );
  }

  final CreateFlightStep step;
  final RoutePreviewState routeState;
  final PreviewLoadState loadState;
  final PreviewDownloadState downloadState;
  final PreviewMessageState messageState;

  FlightRoute? get flightRoute => routeState.flightRoute;
  List<RoutePoiSummary> get allRoutePois => routeState.allRoutePois;
  FlightInfo get flightInfo => routeState.flightInfo;
  int? get proPoiCount => routeState.proPoiCount;
  MapDetailLevel get selectedMapDetailLevel =>
      routeState.selectedMapDetailLevel;
  List<WikiArticleCandidate> get articleCandidates =>
      routeState.articleCandidates;
  List<String> get selectedArticleUrls => routeState.selectedArticleUrls;

  bool get isWikiSuggestionsLoading => loadState.isWikiSuggestionsLoading;
  bool get isPreviewLoading => loadState.isPreviewLoading;
  bool get isOverviewLoading => loadState.isOverviewLoading;
  bool get hasInternetForMapPreview => loadState.hasInternetForMapPreview;

  DownloadSectionsState get downloadSections => downloadState.downloadSections;
  bool get isDownloading => downloadState.isDownloading;
  double get downloadProgress => downloadState.downloadProgress;
  int get downloadedBytes => downloadState.downloadedBytes;
  DownloadStage get downloadStage => downloadState.downloadStage;
  int get poiDownloadCompleted => downloadState.poiDownloadCompleted;
  int get poiDownloadTotal => downloadState.poiDownloadTotal;
  int get poiDownloadFailed => downloadState.poiDownloadFailed;
  int get articleDownloadCompleted => downloadState.articleDownloadCompleted;
  int get articleDownloadTotal => downloadState.articleDownloadTotal;
  int get articleDownloadFailed => downloadState.articleDownloadFailed;
  int? get downloadTileCount => downloadState.downloadTileCount;
  int? get downloadWorkerCount => downloadState.downloadWorkerCount;
  bool get downloadDone => downloadState.downloadDone;

  String? get errorMessage => messageState.errorMessage;
  String? get downloadErrorMessage => messageState.downloadErrorMessage;

  bool get canContinueFromMap =>
      flightRoute != null && !isPreviewLoading && !isDownloading;

  FlightPreviewState copyWith({
    CreateFlightStep? step,
    FlightRoute? flightRoute,
    bool clearFlightRoute = false,
    List<RoutePoiSummary>? allRoutePois,
    bool clearAllRoutePois = false,
    FlightInfo? flightInfo,
    int? proPoiCount,
    bool clearProPoiCount = false,
    MapDetailLevel? selectedMapDetailLevel,
    List<WikiArticleCandidate>? articleCandidates,
    List<String>? selectedArticleUrls,
    bool clearSelectedArticleUrls = false,
    bool? isWikiSuggestionsLoading,
    bool? isPreviewLoading,
    bool? isOverviewLoading,
    bool? hasInternetForMapPreview,
    DownloadSectionsState? downloadSections,
    bool? isDownloading,
    double? downloadProgress,
    int? downloadedBytes,
    DownloadStage? downloadStage,
    int? poiDownloadCompleted,
    int? poiDownloadTotal,
    int? poiDownloadFailed,
    int? articleDownloadCompleted,
    int? articleDownloadTotal,
    int? articleDownloadFailed,
    int? downloadTileCount,
    bool clearDownloadTileCount = false,
    int? downloadWorkerCount,
    bool clearDownloadWorkerCount = false,
    bool? downloadDone,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? downloadErrorMessage,
    bool clearDownloadErrorMessage = false,
  }) {
    return FlightPreviewState(
      step: step ?? this.step,
      routeState: routeState.copyWith(
        flightRoute: flightRoute,
        clearFlightRoute: clearFlightRoute,
        allRoutePois: allRoutePois,
        clearAllRoutePois: clearAllRoutePois,
        flightInfo: flightInfo,
        proPoiCount: proPoiCount,
        clearProPoiCount: clearProPoiCount,
        selectedMapDetailLevel: selectedMapDetailLevel,
        articleCandidates: articleCandidates,
        selectedArticleUrls: selectedArticleUrls,
        clearSelectedArticleUrls: clearSelectedArticleUrls,
      ),
      loadState: loadState.copyWith(
        isWikiSuggestionsLoading: isWikiSuggestionsLoading,
        isPreviewLoading: isPreviewLoading,
        isOverviewLoading: isOverviewLoading,
        hasInternetForMapPreview: hasInternetForMapPreview,
      ),
      downloadState: downloadState.copyWith(
        downloadSections: downloadSections,
        isDownloading: isDownloading,
        downloadProgress: downloadProgress,
        downloadedBytes: downloadedBytes,
        downloadStage: downloadStage,
        poiDownloadCompleted: poiDownloadCompleted,
        poiDownloadTotal: poiDownloadTotal,
        poiDownloadFailed: poiDownloadFailed,
        articleDownloadCompleted: articleDownloadCompleted,
        articleDownloadTotal: articleDownloadTotal,
        articleDownloadFailed: articleDownloadFailed,
        downloadTileCount: downloadTileCount,
        clearDownloadTileCount: clearDownloadTileCount,
        downloadWorkerCount: downloadWorkerCount,
        clearDownloadWorkerCount: clearDownloadWorkerCount,
        downloadDone: downloadDone,
      ),
      messageState: messageState.copyWith(
        errorMessage: errorMessage,
        clearErrorMessage: clearErrorMessage,
        downloadErrorMessage: downloadErrorMessage,
        clearDownloadErrorMessage: clearDownloadErrorMessage,
      ),
    );
  }

  @override
  List<Object?> get props => [
    step,
    routeState,
    loadState,
    downloadState,
    messageState,
  ];

  @override
  String toString() {
    return 'FlightPreviewState('
        'step:${step.name}, '
        'route:${flightRoute?.routeCode ?? 'none'}, '
        'detail:${selectedMapDetailLevel.name}, '
        'poi:${flightInfo.poi.length}/${allRoutePois.length}, '
        'articlesSel:${selectedArticleUrls.length}, '
        'loading(p:${isPreviewLoading ? 1 : 0},o:${isOverviewLoading ? 1 : 0},w:${isWikiSuggestionsLoading ? 1 : 0}), '
        'downloading:${isDownloading ? 1 : 0}/${downloadStage.name}, '
        'errors:${errorMessage != null ? 1 : 0}/${downloadErrorMessage != null ? 1 : 0}'
        ')';
  }
}
