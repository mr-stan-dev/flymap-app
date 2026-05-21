import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/utils/country_name_utils.dart';

void main() {
  test('toCode resolves localized country names in current locale', () async {
    await LocaleSettings.setLocale(AppLocale.es);
    addTearDown(() => LocaleSettings.setLocale(AppLocale.en));

    expect(
      CountryNameUtils.toCode(
        'España',
        languageCode: LocaleSettings.currentLocale.languageCode,
      ),
      'ES',
    );
  });
}
