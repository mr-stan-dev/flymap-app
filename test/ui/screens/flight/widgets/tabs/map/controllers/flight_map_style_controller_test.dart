import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/domain/entity/offline_map_style.dart';
import 'package:flymap/repository/map_preferences_repository.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/controllers/flight_map_style_controller.dart';

void main() {
  test('init loads persisted style', () async {
    final repository = _FakeMapPreferencesRepository(
      storedStyle: OfflineMapStyle.fiord,
    );
    final controller = FlightMapStyleController(
      mapPreferencesRepository: repository,
    );

    await controller.init();

    expect(controller.initialized, isTrue);
    expect(controller.style, OfflineMapStyle.fiord);
    expect(controller.nextStyle, OfflineMapStyle.liberty);
  });

  test('setStyle persists and updates state', () async {
    final repository = _FakeMapPreferencesRepository(
      storedStyle: OfflineMapStyle.liberty,
    );
    final controller = FlightMapStyleController(
      mapPreferencesRepository: repository,
    );

    await controller.setStyle(OfflineMapStyle.fiord);

    expect(controller.style, OfflineMapStyle.fiord);
    expect(repository.storedStyle, OfflineMapStyle.fiord);
  });
}

class _FakeMapPreferencesRepository extends MapPreferencesRepository {
  _FakeMapPreferencesRepository({required this.storedStyle});

  OfflineMapStyle storedStyle;

  @override
  Future<OfflineMapStyle> getOfflineMapStyle() async => storedStyle;

  @override
  Future<void> setOfflineMapStyle(OfflineMapStyle value) async {
    storedStyle = value;
  }
}
