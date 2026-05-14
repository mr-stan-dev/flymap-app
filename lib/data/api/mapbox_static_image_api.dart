import 'dart:typed_data';

import 'package:flymap/logger.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Fetches static map images from the Mapbox Static Images API.
///
/// Builds a URL with a GeoJSON flight path overlay and returns the raw
/// image bytes (PNG).
class MapboxStaticImageApi {
  MapboxStaticImageApi({
    required http.Client httpClient,
    required String accessToken,
  })  : _httpClient = httpClient,
        _accessToken = accessToken;

  final http.Client _httpClient;
  final String _accessToken;
  final Logger _logger = const Logger('MapboxStaticImageApi');

  static const String _baseUrl = 'https://api.mapbox.com/styles/v1';
  static const String _defaultStyle = 'mapbox/satellite-streets-v12';
  static const Duration _timeout = Duration(seconds: 30);

  /// Fetches a clean static map image centered at [center] with [zoom].
  ///
  /// [width], [height] — pixel dimensions of the output image (before @2x).
  /// [retina] — whether to request a @2x high-DPI image.
  Future<Uint8List?> fetchStaticMapImage({
    required LatLng center,
    required double zoom,
    int width = 540,
    int height = 960,
    bool retina = true,
  }) async {
    final retinaStr = retina ? '@2x' : '';
    
    // Format coordinates to 6 decimal places to keep URL clean
    final lonStr = center.longitude.toStringAsFixed(6);
    final latStr = center.latitude.toStringAsFixed(6);
    final zoomStr = zoom.toStringAsFixed(2);
    
    final url = '$_baseUrl/$_defaultStyle/static/'
        '$lonStr,$latStr,$zoomStr,0,0/'
        '${width}x$height$retinaStr'
        '?access_token=$_accessToken';

    _logger.log('Fetching static map image (${url.length} chars)');

    try {
      final response = await _httpClient
          .get(Uri.parse(url))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        _logger.log('Static map image fetched (${response.bodyBytes.length} bytes)');
        return response.bodyBytes;
      } else {
        _logger.error(
          'Mapbox Static Images API error: '
          '${response.statusCode} ${response.reasonPhrase}',
        );
        return null;
      }
    } catch (e) {
      _logger.error('Failed to fetch static map image: $e');
      return null;
    }
  }
}
