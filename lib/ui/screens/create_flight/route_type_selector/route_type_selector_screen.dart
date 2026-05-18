import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/router/app_router.dart';
import 'package:flymap/subscription/paywall_source.dart';
import 'package:flymap/ui/design_system/design_system.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/flight_unlock_gate_sheet.dart';
import 'package:flymap/ui/screens/subscription/viewmodel/subscription_cubit.dart';
import 'package:flymap/ui/screens/subscription/viewmodel/subscription_state.dart';
import 'widgets/route_type_card.dart';

enum RouteType { basic, pro }

class FlightRouteTypeSelector extends StatefulWidget {
  const FlightRouteTypeSelector({super.key});

  @override
  State<FlightRouteTypeSelector> createState() =>
      _FlightRouteTypeSelectorState();
}

class _FlightRouteTypeSelectorState extends State<FlightRouteTypeSelector> {
  RouteType _selectedType = RouteType.basic;
  bool _hasPendingFlightUnlock = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, subState) {
        final navigator = Navigator.of(context);
        final canPop = navigator.canPop();
        final isPro = subState.isPro;
        final hasUnlockedProRoute = isPro || _hasPendingFlightUnlock;
        final t = context.t.createFlight.routeTypeSelector;

        return PopScope(
          canPop: canPop,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            _handleBackNavigation(context, canPop: canPop);
          },
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _handleBackNavigation(context, canPop: canPop),
              ),
              title: Text(t.title),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(DsSpacing.xl),
                child: Column(
                  children: [
                    RouteTypeCard(
                      type: RouteType.basic,
                      title: t.basicTitle,
                      subtitle: t.basicSubtitle,
                      description: t.basicDescription,
                      isSelected: _selectedType == RouteType.basic,
                      onTap: () =>
                          setState(() => _selectedType = RouteType.basic),
                    ),
                    const SizedBox(height: DsSpacing.md),
                    RouteTypeCard(
                      type: RouteType.pro,
                      title: t.proTitle,
                      subtitle: t.proSubtitle,
                      description: t.proDescription,
                      isSelected: _selectedType == RouteType.pro,
                      isProOnly: true,
                      onTap: () => setState(() => _selectedType = RouteType.pro),
                    ),
                    const Spacer(),
                    if (_selectedType == RouteType.pro && !hasUnlockedProRoute)
                      PremiumButton(
                        label: context.t.common.upgrade,
                        onPressed: () => _handleUnlockRealRoute(
                          context,
                          subscriptionCubit: context.read<SubscriptionCubit>(),
                        ),
                      )
                    else
                      PrimaryButton(
                        label: context.t.common.kContinue,
                        onPressed: () {
                          if (_selectedType == RouteType.basic) {
                            AppRouter.goToFlightSearch(context);
                          } else {
                            AppRouter.goToFlightNumberSelector(
                              context,
                              hasPendingFlightUnlock: _hasPendingFlightUnlock,
                            );
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleBackNavigation(BuildContext context, {required bool canPop}) {
    if (canPop) {
      Navigator.of(context).pop();
      return;
    }
    AppRouter.goHome(context);
  }

  Future<void> _handleUnlockRealRoute(
    BuildContext context, {
    required SubscriptionCubit subscriptionCubit,
  }) async {
    await showFlightUnlockGateSheet(
      context: context,
      subscriptionCubit: subscriptionCubit,
      source: PaywallSource.realRouteGate,
      presentProPaywall: subscriptionCubit.presentPaywallFromRealRouteGate,
      onUnlockActivated: () async {
        if (!mounted) return;
        setState(() {
          _hasPendingFlightUnlock = true;
        });
      },
    );
  }
}
