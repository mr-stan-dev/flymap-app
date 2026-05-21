import 'dart:ui';

import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/repository/settings_repository.dart';

class AppLocalization {
  const AppLocalization._();

  static Future<AppLocale> initLocalization({
    required SettingsRepository settingsRepository,
  }) async {
    final localeSetting = await settingsRepository.getLocaleSetting();
    if (localeSetting == SettingsRepository.localeSystem) {
      return LocaleSettings.useDeviceLocale();
    }
    return LocaleSettings.setLocaleRaw(localeSetting);
  }

  static String get currentLanguageCode {
    final languageCode = LocaleSettings.currentLocale.languageCode.trim();
    if (languageCode.isEmpty) return AppLocale.en.languageCode;
    return languageCode.toLowerCase();
  }

  static String get currentLocaleTag {
    final localeTag = LocaleSettings.currentLocale.flutterLocale
        .toLanguageTag()
        .trim();
    if (localeTag.isEmpty) {
      return AppLocale.en.flutterLocale.toLanguageTag();
    }
    return localeTag;
  }

  static String get deviceSupportedLanguageCode {
    final languageCode = PlatformDispatcher.instance.locale.languageCode.trim();
    return resolveSupportedLanguageCode(languageCode);
  }

  static String resolveSupportedLanguageCode(String languageCode) {
    final normalizedLanguageCode = languageCode.trim().toLowerCase();
    return switch (normalizedLanguageCode) {
      'es' => AppLocale.es.languageCode,
      _ => AppLocale.en.languageCode,
    };
  }
}
