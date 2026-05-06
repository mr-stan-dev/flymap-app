import 'package:flymap/domain/entity/flight.dart';
import 'package:flymap/domain/entity/flight_article.dart';
import 'package:flymap/domain/entity/flight_info.dart';
import 'package:flymap/domain/entity/flight_map.dart';
import 'package:flymap/logger.dart';
import 'package:sembast/sembast_io.dart';

import 'app_database.dart';
import 'mappers/flight_article_db_mapper.dart';
import 'mappers/flight_db_mapper.dart';
import 'mappers/flight_info_db_mapper.dart';

class FlightsDBService {
  static const String _assetTypeWikiArticle = 'wiki_article';
  static const String _assetKeyFlightId = 'flightId';
  static const String _assetKeyType = 'type';
  static const String _assetKeyPayload = 'payload';
  static const String _assetKeyUpdatedAt = 'updatedAt';

  final AppDatabase _database;
  final FlightDbMapper _flightMapper;
  final _logger = Logger('FlightsLocalDBService');

  FlightsDBService({
    required AppDatabase database,
    required FlightDbMapper flightMapper,
  }) : _database = database,
       _flightMapper = flightMapper;

  Future<String> insertFlight(Flight flight) async {
    return saveOrUpdateFlight(flight);
  }

  Future<String> saveOrUpdateFlight(Flight flight) async {
    final key = flight.id;
    _logger.log('Saving flight: ${flight.id}');
    final map = _flightMapper.toDb(flight);
    _writeLightArticlesToFlightMap(map);
    await _database.flightsStore.record(key).put(_database.database, map);
    await _upsertArticleAssets(flightId: key, articles: flight.info.articles);
    return key;
  }

  Future<bool> updateFlightInfo(String flightId, FlightInfo info) async {
    final existing = await getFlightById(flightId);
    if (existing == null) return false;
    final updated = Flight(
      id: existing.id,
      route: existing.route,
      maps: existing.maps,
      info: info,
      createdAt: existing.createdAt,
      completedAt: existing.completedAt,
      status: existing.status,
    );
    await saveOrUpdateFlight(updated);
    return true;
  }

  Future<bool> updateFlightMaps(String flightId, List<FlightMap> maps) async {
    final existing = await getFlightById(flightId);
    if (existing == null) return false;
    final updated = Flight(
      id: existing.id,
      route: existing.route,
      maps: maps,
      info: existing.info,
      createdAt: existing.createdAt,
      completedAt: existing.completedAt,
      status: existing.status,
    );
    await saveOrUpdateFlight(updated);
    return true;
  }

  Future<bool> updateFlightStatus(
    String flightId,
    FlightStatus status, {
    DateTime? completedAt,
  }) async {
    final existing = await getFlightById(flightId);
    if (existing == null) return false;
    final updated = Flight(
      id: existing.id,
      route: existing.route,
      maps: existing.maps,
      info: existing.info,
      createdAt: existing.createdAt,
      completedAt: completedAt ?? existing.completedAt,
      status: status,
    );
    await saveOrUpdateFlight(updated);
    return true;
  }

  Future<Flight?> getFlightById(String flightId) async {
    final map = await _database.flightsStore
        .record(flightId)
        .get(_database.database);
    if (map == null) return null;
    final baseFlight = _flightMapper.fromDb(map);
    return _hydrateFlightArticles(baseFlight);
  }

  Future<List<Flight>> getAllFlights() async {
    final records = await _database.flightsStore.find(_database.database);
    final flights = records
        .map((record) => _flightMapper.fromDb(record.value))
        .toList();
    return Future.wait(flights.map(_hydrateFlightArticles));
  }

  Future<List<Flight>> getRecentFlights({int limit = 10}) async {
    final records = await _database.flightsStore.find(
      _database.database,
      finder: Finder(sortOrders: [SortOrder('createdAt', false)], limit: limit),
    );
    final flights = records
        .map((record) => _flightMapper.fromDb(record.value))
        .toList();
    return Future.wait(flights.map(_hydrateFlightArticles));
  }

  Future<bool> deleteFlightRecord(String flightId) async {
    final exists =
        await _database.flightsStore.record(flightId).get(_database.database) !=
        null;
    if (!exists) return false;
    await _deleteArticleAssets(flightId);
    await _database.flightsStore.record(flightId).delete(_database.database);
    return true;
  }

  void _writeLightArticlesToFlightMap(Map<String, dynamic> map) {
    final infoRaw = map[FlightDBKeys.flightInfo];
    if (infoRaw is! Map<String, dynamic>) return;
    final rawArticles = infoRaw[FlightInfoDBKeys.articles];
    if (rawArticles is! List) return;

    final lightArticles = rawArticles
        .whereType<Map<String, dynamic>>()
        .map((article) {
          final light = Map<String, dynamic>.from(article);
          light.remove(FlightArticleDBKeys.contentPlainText);
          light.remove(FlightArticleDBKeys.contentHtml);
          light.remove(FlightArticleDBKeys.leadImageRelativePath);
          light.remove(FlightArticleDBKeys.inlineImageRelativePaths);
          return light;
        })
        .toList();
    infoRaw[FlightInfoDBKeys.articles] = lightArticles;
  }

  Future<void> _upsertArticleAssets({
    required String flightId,
    required List<FlightArticle> articles,
  }) async {
    final nowIso = DateTime.now().toIso8601String();
    final existingAssets = await _database.flightAssetsStore.find(
      _database.database,
      finder: Finder(
        filter: Filter.and([
          Filter.equals(_assetKeyFlightId, flightId),
          Filter.equals(_assetKeyType, _assetTypeWikiArticle),
        ]),
      ),
    );
    final keepIds = <String>{};

    for (final article in articles) {
      final assetId = _articleAssetId(flightId: flightId, sourceUrl: article.sourceUrl);
      keepIds.add(assetId);
      final payload = <String, dynamic>{
        FlightArticleDBKeys.contentPlainText: article.contentPlainText,
        FlightArticleDBKeys.contentHtml: article.contentHtml,
        FlightArticleDBKeys.leadImageRelativePath: article.leadImageRelativePath,
        FlightArticleDBKeys.inlineImageRelativePaths: article.inlineImageRelativePaths,
      };
      await _database.flightAssetsStore.record(assetId).put(_database.database, {
        'id': assetId,
        _assetKeyFlightId: flightId,
        _assetKeyType: _assetTypeWikiArticle,
        FlightArticleDBKeys.sourceUrl: article.sourceUrl,
        _assetKeyPayload: payload,
        _assetKeyUpdatedAt: nowIso,
      });
    }

    for (final record in existingAssets) {
      if (keepIds.contains(record.key)) continue;
      await _database.flightAssetsStore.record(record.key).delete(_database.database);
    }
  }

  Future<void> _deleteArticleAssets(String flightId) async {
    final assets = await _database.flightAssetsStore.find(
      _database.database,
      finder: Finder(
        filter: Filter.and([
          Filter.equals(_assetKeyFlightId, flightId),
          Filter.equals(_assetKeyType, _assetTypeWikiArticle),
        ]),
      ),
    );
    for (final asset in assets) {
      await _database.flightAssetsStore.record(asset.key).delete(_database.database);
    }
  }

  Future<Flight> _hydrateFlightArticles(Flight baseFlight) async {
    if (baseFlight.info.articles.isEmpty) return baseFlight;

    final assets = await _database.flightAssetsStore.find(
      _database.database,
      finder: Finder(
        filter: Filter.and([
          Filter.equals(_assetKeyFlightId, baseFlight.id),
          Filter.equals(_assetKeyType, _assetTypeWikiArticle),
        ]),
      ),
    );
    final byUrl = <String, Map<String, dynamic>>{};
    for (final asset in assets) {
      final sourceUrl = (asset.value[FlightArticleDBKeys.sourceUrl] ?? '').toString();
      if (sourceUrl.isEmpty) continue;
      byUrl[sourceUrl] = asset.value;
    }

    final hydratedArticles = baseFlight.info.articles.map((lightArticle) {
      final asset = byUrl[lightArticle.sourceUrl];
      if (asset == null) return lightArticle;
      final payload = asset[_assetKeyPayload];
      if (payload is! Map<String, dynamic>) return lightArticle;
      return FlightArticle(
        sourceUrl: lightArticle.sourceUrl,
        title: lightArticle.title,
        summary: lightArticle.summary,
        contentPlainText:
            (payload[FlightArticleDBKeys.contentPlainText] ?? '').toString(),
        contentHtml: (payload[FlightArticleDBKeys.contentHtml] ?? '').toString(),
        languageCode: lightArticle.languageCode,
        leadImageRelativePath:
            (payload[FlightArticleDBKeys.leadImageRelativePath] ?? '').toString(),
        inlineImageRelativePaths:
            (payload[FlightArticleDBKeys.inlineImageRelativePaths] as List<dynamic>? ?? const [])
                .whereType<String>()
                .toList(),
        attributionText: lightArticle.attributionText,
        licenseText: lightArticle.licenseText,
        downloadedAt: lightArticle.downloadedAt,
        sizeBytes: lightArticle.sizeBytes,
      );
    }).toList();

    return Flight(
      id: baseFlight.id,
      route: baseFlight.route,
      maps: baseFlight.maps,
      info: baseFlight.info.copyWith(articles: hydratedArticles),
      createdAt: baseFlight.createdAt,
      completedAt: baseFlight.completedAt,
      status: baseFlight.status,
    );
  }

  String _articleAssetId({required String flightId, required String sourceUrl}) {
    return '$flightId::wiki_article::${Uri.encodeComponent(sourceUrl)}';
  }
}
