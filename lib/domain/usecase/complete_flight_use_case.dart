import 'dart:io';

import 'package:flymap/data/local/flights_db_service.dart';
import 'package:flymap/domain/entity/flight.dart';
import 'package:flymap/domain/entity/flight_map.dart';
import 'package:flymap/logger.dart';
import 'package:flymap/map_download_config.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CompleteFlightUseCase {
  CompleteFlightUseCase({required FlightsDBService service})
    : _service = service;

  final FlightsDBService _service;
  final _logger = Logger('CompleteFlightUseCase');

  Future<bool> call({
    required String flightId,
    required bool deleteOfflineData,
  }) async {
    final flight = await _service.getFlightById(flightId);
    if (flight == null) return false;
    if (!deleteOfflineData) {
      return _service.updateFlightStatus(
        flightId,
        FlightStatus.completed,
        completedAt: DateTime.now(),
      );
    }

    await _deleteMbtilesFiles(flight.maps);
    await _deleteArticleFiles(flight);

    final updated = Flight(
      id: flight.id,
      route: flight.route,
      maps: const [],
      info: flight.info.copyWith(articles: const []),
      createdAt: flight.createdAt,
      completedAt: DateTime.now(),
      status: FlightStatus.completed,
      flightAccessTier: flight.flightAccessTier,
    );
    await _service.saveOrUpdateFlight(updated);
    return true;
  }

  Future<void> _deleteMbtilesFiles(List<FlightMap> maps) async {
    if (maps.isEmpty) return;
    final cacheDir = await getApplicationCacheDirectory();
    for (final map in maps) {
      if (map.filePath.isEmpty) continue;
      final filePath = p.join(
        cacheDir.path,
        MapDownloadConfig.mbtilesDirectoryName,
        map.filePath,
      );
      final f = File(filePath);
      if (f.existsSync()) {
        try {
          f.deleteSync();
        } catch (e) {
          _logger.error('Failed to delete MBTiles $filePath: $e');
        }
      }
      _deleteSidecars(filePath);
    }
  }

  Future<void> _deleteArticleFiles(Flight flight) async {
    final articles = flight.info.articles;
    if (articles.isEmpty) return;
    final docsDir = await getApplicationDocumentsDirectory();
    final articleRootPath = p.join(docsDir.path, 'article_media');
    for (final article in articles) {
      final relativePaths = [
        if (article.leadImageRelativePath.isNotEmpty)
          article.leadImageRelativePath,
        ...article.inlineImageRelativePaths,
      ];
      for (final relativePath in relativePaths) {
        final imagePath = p.join(docsDir.path, relativePath);
        final imageFile = File(imagePath);
        if (!imageFile.existsSync()) continue;
        try {
          imageFile.deleteSync();
          _deleteEmptyArticleDirs(
            startDir: imageFile.parent,
            articleRootPath: articleRootPath,
          );
        } catch (e) {
          _logger.error('Failed to delete article image $imagePath: $e');
        }
      }
    }
  }

  void _deleteSidecars(String mainPath) {
    for (final suffix in const ['-wal', '-shm', '-journal']) {
      final sidecar = File('$mainPath$suffix');
      if (!sidecar.existsSync()) continue;
      try {
        sidecar.deleteSync();
      } catch (_) {}
    }
  }

  void _deleteEmptyArticleDirs({
    required Directory startDir,
    required String articleRootPath,
  }) {
    var current = startDir;
    while (true) {
      final currentPath = current.path;
      if (currentPath == articleRootPath ||
          !p.isWithin(articleRootPath, currentPath)) {
        break;
      }
      if (current.listSync().isNotEmpty) break;
      try {
        current.deleteSync();
      } catch (_) {
        break;
      }
      current = current.parent;
    }
  }
}
