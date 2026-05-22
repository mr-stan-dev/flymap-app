import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LocaleSetting { system, english, spanish, french, german }

extension LocaleSettingX on LocaleSetting {
  String? get localeCode => switch (this) {
    LocaleSetting.system => null,
    LocaleSetting.english => 'en',
    LocaleSetting.spanish => 'es',
    LocaleSetting.french => 'fr',
    LocaleSetting.german => 'de',
  };
}

class SettingsRepository {
  static const _kTheme = 'settings.theme';
  static const _kLocale = 'settings.locale';
  static const _systemValue = 'System';
  static const _darkValue = 'Dark';
  static const _lightValue = 'Light';

  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_kTheme) ?? _darkValue;
    return switch (value) {
      _darkValue => ThemeMode.dark,
      _lightValue => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.dark => _darkValue,
      ThemeMode.light => _lightValue,
      ThemeMode.system => _systemValue,
    };
    await prefs.setString(_kTheme, value);
  }

  Future<LocaleSetting> getLocaleSetting() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_kLocale);
    return switch (value) {
      'en' => LocaleSetting.english,
      'es' => LocaleSetting.spanish,
      'fr' => LocaleSetting.french,
      'de' => LocaleSetting.german,
      _ => LocaleSetting.system,
    };
  }

  Future<void> setLocaleSetting(LocaleSetting value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == LocaleSetting.system) {
      await prefs.remove(_kLocale);
      return;
    }
    await prefs.setString(_kLocale, value.localeCode!);
  }
}
