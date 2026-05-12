import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/ui/screens/home/tabs/home/viewmodel/home_tab_state.dart';
import 'package:flymap/ui/screens/subscription/viewmodel/subscription_cubit.dart';

import 'home_summary_header_free.dart';
import 'home_summary_header_pro.dart';

class HomeSummaryHeader extends StatelessWidget {
  const HomeSummaryHeader({
    required this.statistics,
    required this.displayName,
    required this.hasInternet,
    required this.hasInProgressFlights,
    super.key,
  });

  final FlightStatistics statistics;
  final String displayName;
  final bool hasInternet;
  final bool hasInProgressFlights;

  @override
  Widget build(BuildContext context) {
    final isProUser = context.select(
      (SubscriptionCubit cubit) => cubit.state.isPro,
    );
    return isProUser
        ? HomeSummaryHeaderPro(
            statistics: statistics,
            displayName: displayName,
            hasInternet: hasInternet,
            hasInProgressFlights: hasInProgressFlights,
          )
        : HomeSummaryHeaderFree(
            statistics: statistics,
            displayName: displayName,
            hasInternet: hasInternet,
            hasInProgressFlights: hasInProgressFlights,
          );
  }
}
