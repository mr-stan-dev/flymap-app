import 'dart:math' as math;

import 'package:flymap/domain/entity/poi_wiki_preview.dart';
import 'package:flymap/domain/entity/route_region.dart';
import 'package:flymap/repository/poi_wiki_preview_repository.dart';

class RegionWikiArticlesDownloadProgress {
  const RegionWikiArticlesDownloadProgress({
    required this.completed,
    required this.total,
    required this.failed,
  });

  final int completed;
  final int total;
  final int failed;
}

class RegionWikiArticlesDownloadResult {
  const RegionWikiArticlesDownloadResult({
    required this.regions,
    required this.articleUrls,
    required this.failedCount,
    required this.cancelled,
  });

  final List<RouteRegion> regions;
  final List<String> articleUrls;
  final int failedCount;
  final bool cancelled;
}

class DownloadRegionWikiArticlesUseCase {
  DownloadRegionWikiArticlesUseCase({
    required PoiWikiPreviewRepository repository,
  }) : _repository = repository;

  // Keep QID preview resolution in larger chunks to avoid repeated
  // resolve/fetch phases for medium routes (e.g. 15-30 regions).
  static const _progressChunkSize = 50;

  final PoiWikiPreviewRepository _repository;
  bool _cancelled = false;

  int downloadTargetCount(List<RouteRegion> regions) =>
      _normalizeRegionQids(regions).length;

  void cancel() {
    _cancelled = true;
  }

  Future<RegionWikiArticlesDownloadResult> call({
    required List<RouteRegion> regions,
    required String preferredLanguageCode,
    required void Function(RegionWikiArticlesDownloadProgress progress)
    onProgress,
  }) async {
    _cancelled = false;

    final qids = _normalizeRegionQids(regions);
    if (qids.isEmpty) {
      return RegionWikiArticlesDownloadResult(
        regions: List<RouteRegion>.from(regions),
        articleUrls: const [],
        failedCount: 0,
        cancelled: false,
      );
    }

    if (_cancelled) {
      return RegionWikiArticlesDownloadResult(
        regions: List<RouteRegion>.from(regions),
        articleUrls: const [],
        failedCount: 0,
        cancelled: true,
      );
    }

    onProgress(
      RegionWikiArticlesDownloadProgress(
        completed: 0,
        total: qids.length,
        failed: 0,
      ),
    );

    final previews = <String, PoiWikiPreview>{};
    var completed = 0;
    var failed = 0;

    for (var offset = 0; offset < qids.length; offset += _progressChunkSize) {
      if (_cancelled) {
        return RegionWikiArticlesDownloadResult(
          regions: List<RouteRegion>.from(regions),
          articleUrls: const [],
          failedCount: failed,
          cancelled: true,
        );
      }

      final end = math.min(offset + _progressChunkSize, qids.length);
      final chunk = qids.sublist(offset, end);
      final chunkPreviews = await _repository.batchGetWikiPreviews(
        qids: chunk,
        preferredLanguageCode: preferredLanguageCode,
      );
      previews.addAll(chunkPreviews);
      for (final qid in chunk) {
        completed++;
        if (!chunkPreviews.containsKey(qid)) {
          failed++;
        }
      }
      onProgress(
        RegionWikiArticlesDownloadProgress(
          completed: completed,
          total: qids.length,
          failed: failed,
        ),
      );
    }

    final updated = regions
        .map((region) {
          final normalizedQid = _normalizeRegionQid(region);
          if (normalizedQid == null) return region;
          final preview = previews[normalizedQid];
          if (preview == null) return region;
          final sourceUrl = preview.sourceUrl.trim();
          return region.copyWith(
            wikipediaUrl: sourceUrl.isNotEmpty
                ? sourceUrl
                : region.wikipediaUrl,
          );
        })
        .toList(growable: false);
    final articleUrls = previews.values
        .map((preview) => preview.sourceUrl.trim())
        .where((url) => url.isNotEmpty)
        .toSet()
        .toList(growable: false);

    return RegionWikiArticlesDownloadResult(
      regions: updated,
      articleUrls: articleUrls,
      failedCount: failed,
      cancelled: false,
    );
  }

  List<String> _normalizeRegionQids(List<RouteRegion> regions) {
    final out = <String>[];
    final seen = <String>{};
    for (final region in regions) {
      final normalized = _normalizeRegionQid(region);
      if (normalized == null) continue;
      if (seen.add(normalized)) {
        out.add(normalized);
      }
    }
    return out;
  }

  String? _normalizeRegionQid(RouteRegion region) {
    final raw = (region.wikidataQid ?? region.qid).trim().toUpperCase();
    if (raw.isEmpty) return null;
    final direct = RegExp(r'^Q\d+$').firstMatch(raw);
    if (direct != null) return direct.group(0);
    final embedded = RegExp(r'Q\d+').firstMatch(raw);
    return embedded?.group(0);
  }
}
