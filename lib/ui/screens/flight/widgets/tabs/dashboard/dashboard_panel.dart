import 'package:flutter/material.dart';
import 'package:flymap/domain/entity/gps_data.dart';
import 'package:flymap/ui/design_system/design_system.dart';
import 'package:flymap/ui/screens/flight/viewmodel/flight_screen_state.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/flight_instrument_cluster.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/gps_not_granted_state.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/gps_off_state.dart';

class FlightDashboardPanel extends StatelessWidget {
  const FlightDashboardPanel({required this.state, super.key});

  final FlightScreenLoaded state;

  @override
  Widget build(BuildContext context) {
    switch (state.gps.status) {
      case GpsStatus.off:
        return const SectionCard(child: GpsOffState());
      case GpsStatus.permissionsNotGranted:
        return const SectionCard(child: GpsNotGrantedState());
      case GpsStatus.searching:
      case GpsStatus.gpsActive:
      case GpsStatus.weakSignal:
        return FlightInstrumentCluster(gpsData: state.gps.data);
    }
  }
}
