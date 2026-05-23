import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/data/local/mappers/flight_map_mapper.dart';

void main() {
  const mbtilesPath = '/tmp/flymap-test/map.mbtiles';
  const cacheDir = '/tmp/flymap-test/cache';
  final mapper = FlightMapStyleMapper();

  test('rewrites bundled liberty style for offline use', () {
    final styleJson = File(
      'assets/styles/openfreemap_offline_style.json',
    ).readAsStringSync();

    final mapped =
        jsonDecode(
              mapper.mapStyleWithMbtiles(
                styleJson,
                mbtilesPath,
                cacheDir: cacheDir,
              ),
            )
            as Map<String, dynamic>;

    final sources = mapped['sources'] as Map<String, dynamic>;
    expect(
      (sources['openmaptiles'] as Map<String, dynamic>)['url'],
      'mbtiles://$mbtilesPath',
    );
    expect(mapped['sprite'], 'file://$cacheDir/assets/sprites/sprite');
    expect(
      mapped['glyphs'],
      'file://$cacheDir/assets/glyphs/{fontstack}/{range}.pbf',
    );
  });

  test('rewrites fiord style and strips unsupported remote raster sources', () {
    final styleJson = File(
      'assets/styles/openfreemap_offline_fiord_style.json',
    ).readAsStringSync();

    final mapped =
        jsonDecode(
              mapper.mapStyleWithMbtiles(
                styleJson,
                mbtilesPath,
                cacheDir: cacheDir,
              ),
            )
            as Map<String, dynamic>;

    final sources = mapped['sources'] as Map<String, dynamic>;
    expect(
      (sources['openmaptiles'] as Map<String, dynamic>)['url'],
      'mbtiles://$mbtilesPath',
    );
    expect(sources.containsKey('ne2_shaded'), isFalse);

    final layers = (mapped['layers'] as List).cast<Map<String, dynamic>>();
    expect(layers.where((layer) => layer['source'] == 'ne2_shaded'), isEmpty);
  });

  test('rewrites vector basemap sources without relying on the source key', () {
    const styleJson =
        '{"version":8,"sources":{"basemap":{"type":"vector","url":"https://tiles.flymap.app/planet"},"shade":{"type":"raster","tiles":["https://tiles.openfreemap.org/natural_earth/test/{z}/{x}/{y}.png"]}},"layers":[{"id":"shade","type":"raster","source":"shade"},{"id":"route","type":"line","source":"basemap"}]}';

    final mapped =
        jsonDecode(
              mapper.mapStyleWithMbtiles(
                styleJson,
                mbtilesPath,
                cacheDir: cacheDir,
              ),
            )
            as Map<String, dynamic>;

    final sources = mapped['sources'] as Map<String, dynamic>;
    expect(
      (sources['basemap'] as Map<String, dynamic>)['url'],
      'mbtiles://$mbtilesPath',
    );
    expect(sources.containsKey('shade'), isFalse);

    final layers = (mapped['layers'] as List).cast<Map<String, dynamic>>();
    expect(layers, hasLength(1));
    expect(layers.single['source'], 'basemap');
  });

  test('does not rewrite unrelated vector tile sources', () {
    const styleJson =
        '{"version":8,"sources":{"basemap":{"type":"vector","url":"https://tiles.openfreemap.org/planet"},"contours":{"type":"vector","tiles":["https://example.com/contours/{z}/{x}/{y}.pbf"]}},"layers":[{"id":"route","type":"line","source":"basemap"},{"id":"contour-line","type":"line","source":"contours"}]}';

    final mapped =
        jsonDecode(
              mapper.mapStyleWithMbtiles(
                styleJson,
                mbtilesPath,
                cacheDir: cacheDir,
              ),
            )
            as Map<String, dynamic>;

    final sources = mapped['sources'] as Map<String, dynamic>;
    expect(
      (sources['basemap'] as Map<String, dynamic>)['url'],
      'mbtiles://$mbtilesPath',
    );
    expect((sources['contours'] as Map<String, dynamic>)['tiles'], [
      'https://example.com/contours/{z}/{x}/{y}.pbf',
    ]);

    final layers = (mapped['layers'] as List).cast<Map<String, dynamic>>();
    expect(layers, hasLength(2));
    expect(layers.last['source'], 'contours');
  });
}
