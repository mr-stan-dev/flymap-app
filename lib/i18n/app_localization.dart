import 'dart:ui';

import 'package:flymap/i18n/supported_locale.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/repository/settings_repository.dart';

class AppLocalization {
  const AppLocalization._();

  static Future<AppLocale> initLocalization({
    required SettingsRepository settingsRepository,
  }) async {
    final localeSetting = await settingsRepository.getLocaleSetting();
    if (localeSetting == LocaleSetting.system) {
      return LocaleSettings.useDeviceLocale();
    }
    return LocaleSettings.setLocale(localeSetting.supportedLocale!.appLocale);
  }

  static String get currentLanguageCode {
    return currentSupportedLocale.languageCode;
  }

  static SupportedLocale get currentSupportedLocale {
    return SupportedLocale.englishFallback(
      LocaleSettings.currentLocale.languageCode,
    );
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

  static LocaleSetting get deviceSupportedLocaleSetting {
    final languageCode = PlatformDispatcher.instance.locale.languageCode;
    return resolveSupportedLocaleSetting(languageCode);
  }

  static LocaleSetting resolveSupportedLocaleSetting(String languageCode) {
    return SupportedLocale.englishFallback(languageCode).localeSetting;
  }
}
