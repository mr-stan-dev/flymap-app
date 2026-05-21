import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/repository/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SettingsRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    repository = SettingsRepository();
  });

  test('defaults locale setting to system', () async {
    expect(
      await repository.getLocaleSetting(),
      SettingsRepository.localeSystem,
    );
  });

  test('persists locale setting and clears system override', () async {
    await repository.setLocaleSetting(SettingsRepository.localeSpanish);
    expect(
      await repository.getLocaleSetting(),
      SettingsRepository.localeSpanish,
    );

    await repository.setLocaleSetting(SettingsRepository.localeSystem);
    expect(
      await repository.getLocaleSetting(),
      SettingsRepository.localeSystem,
    );
  });

  test('theme mode persistence still works', () async {
    await repository.setThemeMode(ThemeMode.light);
    expect(await repository.getThemeMode(), ThemeMode.light);
  });
}
