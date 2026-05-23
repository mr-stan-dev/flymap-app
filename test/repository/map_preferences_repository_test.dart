import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/domain/entity/offline_map_style.dart';
import 'package:flymap/repository/map_preferences_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('offline map style defaults to liberty and persists', () async {
    final repository = MapPreferencesRepository();

    expect(await repository.getOfflineMapStyle(), OfflineMapStyle.liberty);

    await repository.setOfflineMapStyle(OfflineMapStyle.fiord);

    expect(await repository.getOfflineMapStyle(), OfflineMapStyle.fiord);
  });
}
