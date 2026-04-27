import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'tile_utils.dart';

class WorkerInit {
  final List<MapTile> tiles;
  final String primaryTemplate;
  final String fallbackTemplate;
  final SendPort sendPort;

  WorkerInit(
    this.tiles, {
    required this.primaryTemplate,
    required this.fallbackTemplate,
    required this.sendPort,
  });
}

class TileData {
  final int z;
  final int x;
  final int y;
  final Uint8List bytes;

  TileData(this.z, this.x, this.y, this.bytes);
}

const _requestTimeout = Duration(seconds: 12);
/// Up to this many **cycles** of primary → fallback (one HTTP try each per cycle).
const _maxPrimaryFallbackCycles = 3;
const _retryDelayBaseMs = 300;

/// Worker entrypoint executed in a background isolate.
/// Downloads assigned tiles and sends successful payloads back to main isolate.
void downloadWorker(WorkerInit init) async {
  _isolateLog('Worker started with ${init.tiles.length} tiles');
  final client = http.Client();
  int fromPrimaryCount = 0;
  int fromFallbackCount = 0;
  int failed = 0;

  for (final tile in init.tiles) {
    if (fromPrimaryCount + fromFallbackCount < 1) {
      _isolateLog(
        'First tile: primary base ${init.primaryTemplate}, fallback ${init.fallbackTemplate}',
      );
    }

    final result = await _downloadTilePrimaryThenFallback(
      client,
      init.primaryTemplate,
      init.fallbackTemplate,
      z: tile.z,
      x: tile.x,
      y: tile.y,
    );
    if (result.bytes != null) {
      init.sendPort.send(TileData(tile.z, tile.x, tile.y, result.bytes!));
      if (result.usedFallback) {
        fromFallbackCount++;
      } else {
        fromPrimaryCount++;
      }
    } else {
      failed++;
    }
  }
  client.close();

  _isolateLog(
    'Worker completed: $fromPrimaryCount from primary, $fromFallbackCount from fallback downloaded'
    '${failed > 0 ? ', $failed failed' : ''}',
  );

  init.sendPort.send('done');
}

Uri _tileUri(String template, int z, int x, int y) {
  final s = template
      .replaceAll('{z}', z.toString())
      .replaceAll('{x}', x.toString())
      .replaceAll('{y}', y.toString());
  return Uri.parse(s);
}

/// At most [_maxPrimaryFallbackCycles] times: try primary once, then fallback once
/// (single HTTP per URL; next cycle only if both fail).
Future<({Uint8List? bytes, bool usedFallback})> _downloadTilePrimaryThenFallback(
  http.Client client,
  String primaryTemplate,
  String fallbackTemplate, {
  required int z,
  required int x,
  required int y,
}) async {
  final primaryUri = _tileUri(primaryTemplate, z, x, y);
  final sameUrl = primaryTemplate == fallbackTemplate;

  if (sameUrl) {
    for (int attempt = 1; attempt <= _maxPrimaryFallbackCycles; attempt++) {
      final attemptResult = await _downloadTileOnce(
        client,
        primaryUri,
        z: z,
        x: x,
        y: y,
        label: 'single-source',
        attempt: attempt,
        of: _maxPrimaryFallbackCycles,
      );
      if (attemptResult.bytes != null) {
        return (bytes: attemptResult.bytes, usedFallback: false);
      }
      if (!attemptResult.retryable) {
        return (bytes: null, usedFallback: false);
      }
      if (attempt < _maxPrimaryFallbackCycles) {
        await Future.delayed(
          Duration(milliseconds: _retryDelayBaseMs * attempt),
        );
      }
    }
    return (bytes: null, usedFallback: false);
  }

  for (int cycle = 1; cycle <= _maxPrimaryFallbackCycles; cycle++) {
    final primaryResult = await _downloadTileOnce(
      client,
      primaryUri,
      z: z,
      x: x,
      y: y,
      label: 'primary',
      attempt: cycle,
      of: _maxPrimaryFallbackCycles,
    );
    if (primaryResult.bytes != null) {
      return (bytes: primaryResult.bytes, usedFallback: false);
    }

    final fallbackUri = _tileUri(fallbackTemplate, z, x, y);
    if (cycle == 1) {
      _isolateLog('Primary failed for $z/$x/$y, trying fallback: $fallbackUri');
    }
    final fallbackResult = await _downloadTileOnce(
      client,
      fallbackUri,
      z: z,
      x: x,
      y: y,
      label: 'fallback',
      attempt: cycle,
      of: _maxPrimaryFallbackCycles,
    );
    if (fallbackResult.bytes != null) {
      return (bytes: fallbackResult.bytes, usedFallback: true);
    }
    if (!primaryResult.retryable && !fallbackResult.retryable) {
      return (bytes: null, usedFallback: false);
    }

    if (cycle < _maxPrimaryFallbackCycles) {
      await Future.delayed(
        Duration(milliseconds: _retryDelayBaseMs * cycle),
      );
    }
  }

  return (bytes: null, usedFallback: false);
}

/// One GET with timeout; returns body bytes on 200 with non-empty body.
Future<({Uint8List? bytes, bool retryable})> _downloadTileOnce(
  http.Client client,
  Uri uri, {
  required int z,
  required int x,
  required int y,
  required String label,
  required int attempt,
  required int of,
}) async {
  try {
    final resp = await client.get(uri).timeout(_requestTimeout);
    if (resp.statusCode == 200) {
      final bytes = resp.bodyBytes;
      if (bytes.isNotEmpty) {
        return (bytes: bytes, retryable: false);
      }
      _isolateLog(
        'Empty response for tile $z/$x/$y ($label $attempt/$of)',
      );
      return (bytes: null, retryable: true);
    } else {
      _isolateLog(
        'HTTP ${resp.statusCode} for tile $z/$x/$y ($label $attempt/$of)',
      );
      return (bytes: null, retryable: _isRetryableStatus(resp.statusCode));
    }
  } on TimeoutException {
    _isolateLog('Timeout for tile $z/$x/$y ($label $attempt/$of)');
    return (bytes: null, retryable: true);
  } catch (e) {
    _isolateLog(
      'Error for tile $z/$x/$y ($label $attempt/$of): $e',
    );
    return (bytes: null, retryable: true);
  }
}

/// Returns true for HTTP codes where retrying is usually useful.
bool _isRetryableStatus(int statusCode) {
  return statusCode == 408 ||
      statusCode == 429 ||
      (statusCode >= 500 && statusCode <= 599);
}

/// Helper method for isolate logging that only prints in debug mode
void _isolateLog(String message) {
  if (kDebugMode) {
    // Keep print in isolate for simplicity and to avoid extra dependencies
    // Isolate logs are debug-only
    print('[VectorTilesDownloader] $message');
  }
}
