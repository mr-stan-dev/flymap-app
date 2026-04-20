import 'dart:io';

import 'package:sqflite/sqflite.dart';

import '../../logger.dart';

class MbtilesVerifyResult {
  const MbtilesVerifyResult._({
    required this.isValid,
    required this.fileSize,
    this.errorMessage,
  });

  final bool isValid;
  final int fileSize;
  final String? errorMessage;

  factory MbtilesVerifyResult.valid({required int fileSize}) =>
      MbtilesVerifyResult._(isValid: true, fileSize: fileSize);

  factory MbtilesVerifyResult.invalid(String errorMessage) =>
      MbtilesVerifyResult._(
        isValid: false,
        fileSize: 0,
        errorMessage: errorMessage,
      );
}

class MbtilesVerifier {
  static final _logger = Logger('MbtilesVerifier');

  static Future<MbtilesVerifyResult> verifyMbtilesFile(String filePath) async {
    Database? db;
    _logger.log('Verifying MBTiles file: $filePath');

    final file = File(filePath);
    if (!await file.exists()) {
      _logger.error('File does not exist!');
      return MbtilesVerifyResult.invalid(
        'MBTiles file does not exist at path: $filePath',
      );
    }

    final fileSize = await file.length();
    _logger.log('File size: ${(fileSize / 1024).toStringAsFixed(2)}KB');
    if (fileSize <= 0) {
      return MbtilesVerifyResult.invalid(
        'MBTiles file is empty (0 bytes): $filePath',
      );
    }

    try {
      db = await openDatabase(filePath, readOnly: true);

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
      );
      final tableNames = tables
          .map((row) => (row['name'] ?? '').toString())
          .toSet();
      if (!tableNames.contains('tiles')) {
        return MbtilesVerifyResult.invalid(
          'tiles table is missing in MBTiles database.',
        );
      }

      // Count total tiles
      final tileCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM tiles'),
      );
      _logger.log('Total tiles: $tileCount');
      if (tileCount == null || tileCount <= 0) {
        return MbtilesVerifyResult.invalid(
          'tiles table is empty in MBTiles database.',
        );
      }

      // Show zoom level distribution
      final zoomStats = await db.rawQuery('''
        SELECT zoom_level, COUNT(*) as count 
        FROM tiles 
        GROUP BY zoom_level 
        ORDER BY zoom_level
      ''');

      _logger.log('Tiles by zoom level:');
      for (final stat in zoomStats) {
        _logger.log('  - Zoom ${stat['zoom_level']}: ${stat['count']} tiles');
      }

      // Check metadata table
      if (tableNames.contains('metadata')) {
        final metadata = await db.query('metadata');
        if (metadata.isNotEmpty) {
          _logger.log('Metadata:');
          for (final meta in metadata) {
            _logger.log('  - ${meta['name']}: ${meta['value']}');
          }
        }
      }

      _logger.log('Verification completed successfully!');
      return MbtilesVerifyResult.valid(fileSize: fileSize);
    } catch (e) {
      _logger.error('Verification failed: $e');
      return MbtilesVerifyResult.invalid(
        'MBTiles verification failed: ${e.toString()}',
      );
    } finally {
      try {
        await db?.close();
      } catch (_) {}
    }
  }
}
