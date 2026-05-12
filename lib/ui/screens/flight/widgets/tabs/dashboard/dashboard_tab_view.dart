import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/domain/entity/flight_status.dart';
import 'package:flymap/domain/entity/gps_data.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/ui/screens/flight/viewmodel/flight_screen_cubit.dart';
import 'package:flymap/ui/screens/flight/viewmodel/flight_screen_state.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/dashboard_panel.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/gps_live_status_card.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/telemetry_searching_overlay.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/shared/upcoming_check_in_card.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/shared/tab_state_placeholder.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/weak_signal_banner.dart';

class FlightDashboardTabView extends StatelessWidget {
  const FlightDashboardTabView({
    required this.state,
    required this.topPadding,
    super.key,
  });

  final FlightScreenState state;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    if (state is FlightScreenLoaded) {
      return _LoadedDashboardTab(
        state: state as FlightScreenLoaded,
        topPadding: topPadding,
      );
    }

    if (state is FlightScreenError) {
      return FlightTabStatePlaceholder(
        icon: Icons.error_outline,
        text: (state as FlightScreenError).message,
      );
    }

    return FlightTabStatePlaceholder(
      icon: Icons.sensors,
      text: context.t.flight.dashboard.preparingDashboard,
    );
  }
}

class _LoadedDashboardTab extends StatelessWidget {
  const _LoadedDashboardTab({required this.state, required this.topPadding});

  final FlightScreenLoaded state;
  final double topPadding;

  bool get _hasLiveTelemetry =>
      state.gpsStatus == GpsStatus.gpsActive ||
      state.gpsStatus == GpsStatus.weakSignal;
  bool get _isSearching => state.gpsStatus == GpsStatus.searching;
  bool get _showTelemetryCards => _hasLiveTelemetry || _isSearching;

  @override
  Widget build(BuildContext context) {
    final dashboardContent = _buildDashboardContent();

    if (state.flight.status == FlightStatus.upcoming) {
      return SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(child: dashboardContent),
            Positioned.fill(
              child: ColoredBox(
                color: Theme.of(
                  context,
                ).colorScheme.scrim.withValues(alpha: 0.4),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: UpcomingCheckInCard(
                onCheckInPressed: () => _checkInFlight(context),
                title: context.t.flight.upcoming.dashboardTitle,
                subtitle: context.t.flight.upcoming.dashboardSubtitle,
              ),
            ),
          ],
        ),
      );
    }

    return dashboardContent;
  }

  Widget _buildDashboardContent() {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, topPadding, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GpsLiveStatusCard(
              gpsStatus: state.gpsStatus,
              gpsData: state.gpsData,
              gpsUpdateTick: state.gpsUpdateTick,
            ),
            const SizedBox(height: 12),
            if (_showTelemetryCards)
              TelemetrySearchingOverlay(
                enabled: _isSearching,
                child: FlightDashboardPanel(state: state),
              )
            else
              FlightDashboardPanel(state: state),
            if (state.gpsStatus == GpsStatus.weakSignal) ...[
              const SizedBox(height: 12),
              const WeakSignalBanner(),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _checkInFlight(BuildContext context) async {
    final ok = await context.read<FlightScreenCubit>().checkInFlight();
    if (ok || !context.mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(content: Text(context.t.flight.upcoming.checkInError)),
    );
  }
}
