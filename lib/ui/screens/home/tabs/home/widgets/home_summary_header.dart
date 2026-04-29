import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/ui/screens/subscription/viewmodel/subscription_cubit.dart';

import 'home_summary_header_free.dart';
import 'home_summary_header_pro.dart';

class HomeSummaryHeader extends StatelessWidget {
  const HomeSummaryHeader({
    required this.displayName,
    required this.hasInternet,
    super.key,
  });

  final String displayName;
  final bool hasInternet;

  @override
  Widget build(BuildContext context) {
    final isProUser = context.select(
      (SubscriptionCubit cubit) => cubit.state.isPro,
    );
    return isProUser
        ? HomeSummaryHeaderPro(
            displayName: displayName,
            hasInternet: hasInternet,
          )
        : HomeSummaryHeaderFree(
            displayName: displayName,
            hasInternet: hasInternet,
          );
  }
}
