import 'package:flymap/data/local/app_database.dart';
import 'package:flymap/data/local/migrations/flights_db_migration.dart';
import 'package:flymap/logger.dart';
import 'package:sembast/sembast.dart';

/// V1 -> V2:
/// Backfill `flight_assets` from legacy embedded `flights.maps`.
class FlightsDbMigrationV1ToV2 implements FlightsDbMigration {
  FlightsDbMigrationV1ToV2({required AppDatabase database}) : _database = database;

  final AppDatabase _database;
  final Logger _logger = const Logger('FlightsDbMigrationV1ToV2');

  @override
  int get targetVersion => 2;

  @override
  Future<void> run(Database db) async {
    final flightsStore = _database.flightsStore;
    final assetsStore = _database.flightAssetsStore;

    final flights = await flightsStore.find(db);
    if (flights.isEmpty) {
      _logger.log('No flights found, skipping V1->V2 backfill');
      return;
    }

    int upserts = 0;
    for (final flightRecord in flights) {
      final flightId = flightRecord.key;
      final mapList = flightRecord.value['maps'];
      if (mapList is! List) continue;

      for (final raw in mapList) {
        if (raw is! Map) continue;
        final m = raw.cast<String, dynamic>();

        final filePath = (m['filePath'] ?? '').toString();
        if (filePath.isEmpty) continue;

        final layer = (m['layer'] ?? '').toString();
        final sizeBytesRaw = m['sizeBytes'];
        final sizeBytes = switch (sizeBytesRaw) {
          int v => v,
          num v => v.toInt(),
          _ => 0,
        };
        final downloadedAt = (m['downloadedAt'] ?? '').toString();

        final assetId = _assetId(flightId: flightId, filePath: filePath);
        final payload = <String, dynamic>{
          'id': assetId,
          'flightId': flightId,
          'type': 'map',
          'filePath': filePath,
          'sizeBytes': sizeBytes,
          'state': 'ready',
          if (layer.isNotEmpty) 'layer': layer,
          if (downloadedAt.isNotEmpty) 'downloadedAt': downloadedAt,
          'updatedAt': DateTime.now().toIso8601String(),
        };

        await assetsStore.record(assetId).put(db, payload);
        upserts++;
      }
    }

    _logger.log('V1->V2 backfill completed, upserted $upserts assets');
  }

  String _assetId({required String flightId, required String filePath}) {
    return '$flightId::map::$filePath';
  }
}

