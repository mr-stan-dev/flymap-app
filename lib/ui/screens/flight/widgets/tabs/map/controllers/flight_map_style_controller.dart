import 'package:flutter/foundation.dart';
import 'package:flymap/domain/entity/offline_map_style.dart';
import 'package:flymap/repository/map_preferences_repository.dart';

class FlightMapStyleController extends ChangeNotifier {
  FlightMapStyleController({
    required MapPreferencesRepository mapPreferencesRepository,
  }) : _mapPreferencesRepository = mapPreferencesRepository;

  final MapPreferencesRepository _mapPreferencesRepository;

  OfflineMapStyle _style = OfflineMapStyle.liberty;
  bool _initialized = false;

  OfflineMapStyle get style => _style;

  bool get initialized => _initialized;

  OfflineMapStyle get nextStyle => _style == OfflineMapStyle.liberty
      ? OfflineMapStyle.fiord
      : OfflineMapStyle.liberty;

  Future<void> init() async {
    _style = await _mapPreferencesRepository.getOfflineMapStyle();
    _initialized = true;
    notifyListeners();
  }

  Future<void> setStyle(OfflineMapStyle style) async {
    if (_initialized && _style == style) return;
    _style = style;
    _initialized = true;
    notifyListeners();
    await _mapPreferencesRepository.setOfflineMapStyle(style);
  }
}
