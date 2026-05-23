import 'dart:convert';

import 'package:flymap/domain/entity/flight_map.dart';

class FlightMapDBKeys {
  static const layer = 'layer';
  static const sizeBytes = 'sizeBytes';
  static const downloadedAt = 'downloadedAt';
  static const filePath = 'filePath';
}

class FlightMapDbMapper {
  Map<String, dynamic> toDb(FlightMap fm) => <String, dynamic>{
    FlightMapDBKeys.layer: fm.layer,
    FlightMapDBKeys.sizeBytes: fm.sizeBytes,
    FlightMapDBKeys.downloadedAt: fm.downloadedAt.toIso8601String(),
    FlightMapDBKeys.filePath: fm.filePath,
  };

  FlightMap fromDb(Map<String, dynamic> map) {
    return FlightMap(
      layer: (map[FlightMapDBKeys.layer] ?? '').toString(),
      sizeBytes: (map[FlightMapDBKeys.sizeBytes] as num).toInt(),
      downloadedAt: DateTime.parse(
        (map[FlightMapDBKeys.downloadedAt] ?? '').toString(),
      ),
      filePath: (map[FlightMapDBKeys.filePath] ?? '').toString(),
    );
  }
}

class FlightMapStyleMapper {
  static const _localSpritePath = 'assets/sprites/sprite';
  static const _localGlyphsPath = 'assets/glyphs/{fontstack}/{range}.pbf';
  static const _knownBasemapHosts = <String>{
    '__TILEJSON_DOMAIN__',
    'tiles.openfreemap.org',
    'tiles.flymap.app',
  };
  static const _basemapTileJsonPath = '/planet';

  /// Injects an mbtiles URL into the style JSON for known OpenFreeMap/Flymap
  /// basemap sources.
  /// Also updates sprite and glyph paths to point to the current cache
  /// directory, and strips unsupported remote raster sources for offline use.
  /// Returns the updated JSON string; if not applicable, returns the original.
  String mapStyleWithMbtiles(
    String styleJson,
    String absoluteMbtilesPath, {
    required String cacheDir,
  }) {
    try {
      final style = jsonDecode(styleJson) as Map<String, dynamic>;
      final removedSourceIds = _rewriteSources(
        style['sources'],
        absoluteMbtilesPath,
      );
      _removeLayersForRemovedSources(style['layers'], removedSourceIds);

      // Fix sprite/glyph paths to point to the current platform cache directory
      style['sprite'] = 'file://$cacheDir/$_localSpritePath';
      style['glyphs'] = 'file://$cacheDir/$_localGlyphsPath';
      return jsonEncode(style);
    } catch (_) {
      return styleJson;
    }
  }

  Set<String> _rewriteSources(dynamic rawSources, String absoluteMbtilesPath) {
    if (rawSources is! Map) return const <String>{};

    final removedSourceIds = <String>{};
    for (final entry in rawSources.entries.toList()) {
      final sourceId = entry.key.toString();
      final source = entry.value;
      if (source is! Map) continue;

      if (_isOfflineVectorBasemapSource(source)) {
        source
          ..remove('tiles')
          ..['url'] = 'mbtiles://$absoluteMbtilesPath';
        continue;
      }

      if (_isUnsupportedOfflineRemoteSource(source)) {
        removedSourceIds.add(sourceId);
      }
    }

    for (final sourceId in removedSourceIds) {
      rawSources.remove(sourceId);
    }

    return removedSourceIds;
  }

  bool _isOfflineVectorBasemapSource(Map source) {
    if (source['type']?.toString() != 'vector') return false;

    final url = source['url']?.toString() ?? '';
    if (_isKnownBasemapUrl(url)) {
      return true;
    }

    final tiles = source['tiles'];
    if (tiles is! List) return false;
    return tiles.any((tile) => _isKnownBasemapTileUrl(tile.toString()));
  }

  bool _isKnownBasemapUrl(String value) {
    if (value.isEmpty) return false;
    if (value.contains('__TILEJSON_DOMAIN__/planet')) {
      return true;
    }

    final uri = Uri.tryParse(value);
    if (uri == null) return false;

    return _knownBasemapHosts.contains(uri.host) &&
        uri.path == _basemapTileJsonPath;
  }

  bool _isKnownBasemapTileUrl(String value) {
    if (value.isEmpty) return false;
    if (value.contains('__TILEJSON_DOMAIN__/planet/')) {
      return true;
    }

    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    if (!_knownBasemapHosts.contains(uri.host)) {
      return false;
    }

    final segments = uri.pathSegments;
    return segments.isNotEmpty && segments.first == 'planet';
  }

  bool _isUnsupportedOfflineRemoteSource(Map source) {
    final type = source['type']?.toString() ?? '';
    if (type != 'raster' && type != 'raster-dem') {
      return false;
    }

    final url = source['url']?.toString() ?? '';
    if (_isRemoteReference(url)) {
      return true;
    }

    final tiles = source['tiles'];
    if (tiles is List) {
      return tiles.any((tile) => _isRemoteReference(tile.toString()));
    }
    return false;
  }

  bool _isRemoteReference(String value) {
    return value.startsWith('http://') ||
        value.startsWith('https://') ||
        value.contains('__TILEJSON_DOMAIN__');
  }

  void _removeLayersForRemovedSources(
    dynamic rawLayers,
    Set<String> removedSourceIds,
  ) {
    if (rawLayers is! List || removedSourceIds.isEmpty) return;

    rawLayers.removeWhere((layer) {
      if (layer is! Map) return false;
      final sourceId = layer['source']?.toString();
      return sourceId != null && removedSourceIds.contains(sourceId);
    });
  }
}
