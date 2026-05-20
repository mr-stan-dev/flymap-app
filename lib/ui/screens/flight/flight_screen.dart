import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/domain/entity/flight.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/router/app_router.dart';
import 'package:flymap/ui/screens/flight/viewmodel/flight_screen_cubit.dart';
import 'package:flymap/ui/screens/flight/viewmodel/flight_screen_state.dart';
import 'package:flymap/ui/screens/flight/widgets/flight_app_bar.dart';
import 'package:flymap/ui/screens/flight/widgets/gps_signal_help_sheet.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/dashboard/dashboard_tab_view.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/debug/debug_tab_view.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/map/map_tab.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/read/read_tab_view.dart';
import 'package:flymap/ui/screens/flight/widgets/tabs/route/flight_route_tab_view.dart';
import 'package:flymap/ui/screens/home/tabs/home/home_tab.dart';

class FlightScreen extends StatelessWidget {
  final Flight flight;
  final FlightScreenCubit? cubit;

  const FlightScreen({super.key, required this.flight, this.cubit});

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider.value(value: cubit!, child: const _FlightScreenView());
    }
    return BlocProvider(
      create: (context) => FlightScreenCubit(flight: flight),
      child: const _FlightScreenView(),
    );
  }
}

class _FlightScreenView extends StatefulWidget {
  const _FlightScreenView();

  @override
  State<_FlightScreenView> createState() => _FlightScreenViewState();
}

class _FlightScreenViewState extends State<_FlightScreenView> {
  int _tabIndex = 0;
  bool _isGpsHelpSheetOpen = false;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.72),
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        selectedIconTheme: const IconThemeData(size: 26),
        unselectedIconTheme: const IconThemeData(size: 24),
        currentIndex: _tabIndex,
        onTap: (index) => setState(() => _tabIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_outlined),
            activeIcon: const Icon(Icons.map),
            label: t.flight.tabMap,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.speed_outlined),
            activeIcon: const Icon(Icons.speed),
            label: t.flight.tabDashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.timeline_outlined),
            activeIcon: const Icon(Icons.timeline),
            label: t.flight.tabRoute,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.article_outlined),
            activeIcon: const Icon(Icons.article),
            label: 'Read',
          ),
          if (kDebugMode)
            const BottomNavigationBarItem(
              icon: Icon(Icons.bug_report_outlined),
              activeIcon: Icon(Icons.bug_report),
              label: 'Debug',
            ),
        ],
      ),
      body: BlocConsumer<FlightScreenCubit, FlightScreenState>(
        listener: (context, state) {
          if (state is FlightScreenError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          if (state is FlightScreenDeleted) {
            homeRefreshNotifier.value = true;
            AppRouter.goHome(context);
          }
        },
        builder: (context, state) {
          final flight = _extractFlight(state);

          return Stack(
            children: [
              Positioned.fill(
                child: IndexedStack(
                  index: _tabIndex,
                  children: [
                    FlightMapTabView(onGpsHelpTap: _openGpsSignalHelpSheet),
                    FlightDashboardTabView(
                      state: state,
                      topPadding: _tabTopPadding(context),
                      onGpsHelpTap: _openGpsSignalHelpSheet,
                    ),
                    FlightRouteTabView(
                      state: state,
                      topPadding: _tabTopPadding(context),
                    ),
                    ReadTabView(
                      state: state,
                      topPadding: _tabTopPadding(context),
                    ),
                    if (kDebugMode)
                      FlightDebugTabView(
                        state: state,
                        topPadding: _tabTopPadding(context),
                      ),
                  ],
                ),
              ),
              if (flight != null)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: FlightAppBar(flight: flight),
                ),
            ],
          );
        },
      ),
    );
  }

  Flight? _extractFlight(FlightScreenState state) {
    if (state is FlightScreenLoaded) {
      return state.flight;
    }
    if (state is FlightScreenError) {
      return state.flight;
    }
    return null;
  }

  double _tabTopPadding(BuildContext context) {
    return FlightAppBar.totalOverlayHeight(context) + 8;
  }

  Future<void> _openGpsSignalHelpSheet() async {
    if (!mounted || _isGpsHelpSheetOpen) {
      return;
    }
    _isGpsHelpSheetOpen = true;
    try {
      await showGpsSignalHelpSheet(context);
    } finally {
      _isGpsHelpSheetOpen = false;
    }
  }
}
