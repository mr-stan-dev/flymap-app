import 'package:flymap/domain/entity/offline_map_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapPreferencesRepository {
  static const _kDayNightEnabled = 'map.day_night_enabled.v1';
  static const _kOfflineMapStyle = 'map.offline_style.v1';

  Future<bool> getDayNightEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kDayNightEnabled) ?? false;
  }

  Future<void> setDayNightEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDayNightEnabled, value);
  }

  Future<OfflineMapStyle> getOfflineMapStyle() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_kOfflineMapStyle);
    return switch (value) {
      'fiord' => OfflineMapStyle.fiord,
      _ => OfflineMapStyle.liberty,
    };
  }

  Future<void> setOfflineMapStyle(OfflineMapStyle value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kOfflineMapStyle, value.name);
  }
}
