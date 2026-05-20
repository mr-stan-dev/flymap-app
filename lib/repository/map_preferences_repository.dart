import 'package:shared_preferences/shared_preferences.dart';

class MapPreferencesRepository {
  static const _kDayNightEnabled = 'map.day_night_enabled.v1';

  Future<bool> getDayNightEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kDayNightEnabled) ?? false;
  }

  Future<void> setDayNightEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDayNightEnabled, value);
  }
}
