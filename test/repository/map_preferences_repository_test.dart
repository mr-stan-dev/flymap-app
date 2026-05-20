import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/repository/map_preferences_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('day-night preference defaults to disabled and persists', () async {
    final repository = MapPreferencesRepository();

    expect(await repository.getDayNightEnabled(), isFalse);

    await repository.setDayNightEnabled(true);

    expect(await repository.getDayNightEnabled(), isTrue);
  });
}
