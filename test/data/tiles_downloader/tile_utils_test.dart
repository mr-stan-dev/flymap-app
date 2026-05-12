import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/data/tiles_downloader/tile_utils.dart';
import 'package:latlong2/latlong.dart';

void main() {
  test('xyzFromLatLon clamps polar coordinates into valid tile range', () {
    final tile = TileUtils.xyzFromLatLon(const LatLng(89.9, 20.0), 7);

    expect(TileUtils.isValidTile(tile), isTrue);
    expect(tile.y, greaterThanOrEqualTo(0));
    expect(tile.y, lessThan(1 << 7));
  });

  test('xyzFromLatLon clamps longitude edge into valid tile range', () {
    final tile = TileUtils.xyzFromLatLon(const LatLng(0.0, 180.0), 5);

    expect(TileUtils.isValidTile(tile), isTrue);
    expect(tile.x, equals((1 << 5) - 1));
  });

  test('tilesForPolygon never yields invalid tiles for near-polar polygon', () {
    final tiles = TileUtils.tilesForPolygon(const [
      LatLng(89.5, -30.0),
      LatLng(89.7, 30.0),
      LatLng(89.2, 45.0),
      LatLng(89.0, -45.0),
    ], 6).toList(growable: false);

    expect(tiles.every(TileUtils.isValidTile), isTrue);
  });
}
