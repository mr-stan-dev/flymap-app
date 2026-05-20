import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/domain/entity/route_region.dart';
import 'package:flymap/ui/screens/flight/viewmodel/flight_screen_cubit.dart';
import 'package:flymap/ui/screens/flight/viewmodel/flight_screen_state.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/widgets/map_bottom_status_card.dart';

class FlightMapBottomStatusOverlay extends StatelessWidget {
  const FlightMapBottomStatusOverlay({
    required this.onSelectedRegionChanged,
    required this.onCheckInPressed,
    super.key,
  });

  final ValueChanged<RouteRegion?> onSelectedRegionChanged;
  final VoidCallback onCheckInPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: BlocBuilder<FlightScreenCubit, FlightScreenState>(
        buildWhen: (previous, current) {
          if (previous is FlightScreenLoaded && current is FlightScreenLoaded) {
            return previous.flight.status != current.flight.status;
          }
          return previous.runtimeType != current.runtimeType;
        },
        builder: (context, state) {
          if (state is! FlightScreenLoaded) {
            return const SizedBox.shrink();
          }
          return MapBottomStatusCard(
            status: state.flight.status,
            onSelectedRegionChanged: onSelectedRegionChanged,
            onCheckInPressed: onCheckInPressed,
          );
        },
      ),
    );
  }
}
