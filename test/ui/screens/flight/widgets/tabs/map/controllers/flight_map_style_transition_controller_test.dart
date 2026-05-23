import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/controllers/flight_map_style_transition_controller.dart';

void main() {
  test('tracks style preparation and apply lifecycle', () {
    final controller = FlightMapStyleTransitionController();

    expect(controller.isLoading, isFalse);

    controller.beginPreparing();
    expect(controller.isLoading, isTrue);

    controller.beginApplying();
    expect(controller.isLoading, isTrue);

    controller.complete();
    expect(controller.isLoading, isFalse);
  });

  test('clears loading state after failure', () {
    final controller = FlightMapStyleTransitionController();

    controller.beginPreparing();
    expect(controller.isLoading, isTrue);

    controller.fail();
    expect(controller.isLoading, isFalse);
  });
}
