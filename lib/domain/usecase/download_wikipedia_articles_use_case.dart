import 'dart:math';

import 'package:flymap/data/wiki/wikipedia_article_client.dart';
import 'package:flymap/domain/entity/flight_article.dart';
import 'package:flymap/logger.dart';

class WikipediaArticlesDownloadProgress {
  const WikipediaArticlesDownloadProgress({
    required this.completed,
    required this.total,
    required this.failed,
  });

  final int completed;
  final int total;
  final int failed;
}

class WikipediaArticlesDownloadResult {
  const WikipediaArticlesDownloadResult({
    required this.articles,
    required this.failedCount,
    required this.cancelled,
  });

  final List<FlightArticle> articles;
  final int failedCount;
  final bool cancelled;
}

class DownloadWikipediaArticlesUseCase {
  DownloadWikipediaArticlesUseCase({
    required WikipediaArticleClient articleClient,
  }) : _articleClient = articleClient;

  static const _downloadConcurrency = 3;

  final WikipediaArticleClient _articleClient;
  final _logger = const Logger('DownloadWikipediaArticlesUseCase');
  bool _cancelled = false;

  void cancel() {
    _cancelled = true;
  }

  Future<void> cleanupBundleMedia(String bundleId) async {
    await _articleClient.cleanupBundleMedia(bundleId);
  }

  Future<WikipediaArticlesDownloadResult> call({
    required String bundleId,
    required List<String> articleUrls,
    required void Function(WikipediaArticlesDownloadProgress progress)
    onProgress,
  }) async {
    _cancelled = false;
    final urls = articleUrls.toSet().toList();

    if (urls.isEmpty) {
      return const WikipediaArticlesDownloadResult(
        articles: <FlightArticle>[],
        failedCount: 0,
        cancelled: false,
      );
    }

    final downloadedArticles = <FlightArticle>[];
    var completed = 0;
    var failed = 0;
    var nextIndex = 0;
    final workerCount = min(_downloadConcurrency, urls.length);

    Future<void> worker() async {
      while (true) {
        if (_cancelled || nextIndex >= urls.length) return;
        final currentIndex = nextIndex;
        nextIndex++;
        final url = urls[currentIndex];

        try {
          final article = await _articleClient.downloadArticle(
            sourceUrl: url,
            bundleId: bundleId,
          );
          if (article != null) {
            downloadedArticles.add(article);
          } else {
            failed++;
            _logger.error(
              'Article download returned null for url="$url" bundle="$bundleId"',
            );
          }
        } catch (e) {
          failed++;
          _logger.error(
            'Article download threw for url="$url" bundle="$bundleId": $e',
          );
        }

        completed++;
        onProgress(
          WikipediaArticlesDownloadProgress(
            completed: completed,
            total: urls.length,
            failed: failed,
          ),
        );
      }
    }

    await Future.wait(
      List<Future<void>>.generate(workerCount, (_) => worker()),
    );

    return WikipediaArticlesDownloadResult(
      articles: downloadedArticles,
      failedCount: failed,
      cancelled: _cancelled,
    );
  }
}
