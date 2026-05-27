import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/logger.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/controllers/flight_map_camera_controller.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

void main() {
  test('resetNorth keeps follow enabled but turns heading-up off', () async {
    final controller = FlightMapCameraController(
      logger: const Logger('FlightMapCameraControllerTest'),
    );

    controller.start(initialZoom: 5);

    await controller.toggleUserFollow(
      controller: null,
      userLocation: const LatLng(51.47, -0.45),
      userHeading: 123,
    );

    expect(controller.followUser, isTrue);
    expect(controller.followHeadingUp, isTrue);

    await controller.resetNorth(null);

    expect(controller.followUser, isTrue);
    expect(controller.followHeadingUp, isFalse);
    expect(controller.mapBearingDegrees, 0);
    expect(controller.showResetNorth, isFalse);
  });
}
