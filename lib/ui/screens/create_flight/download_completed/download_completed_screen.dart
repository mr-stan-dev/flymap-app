import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/router/app_router.dart';
import 'package:flymap/ui/screens/create_flight/download_completed/download_completed_args.dart';
import 'package:flymap/ui/screens/create_flight/flight_preview/widgets/flight_download_completion.dart';
import 'package:flymap/ui/screens/home/tabs/home/home_tab.dart';

class DownloadCompletedRouteScreen extends StatefulWidget {
  const DownloadCompletedRouteScreen({required this.args, super.key});

  final DownloadCompletedArgs args;

  @override
  State<DownloadCompletedRouteScreen> createState() =>
      _DownloadCompletedRouteScreenState();
}

class _DownloadCompletedRouteScreenState
    extends State<DownloadCompletedRouteScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _onHomePressed();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.t.preview.downloadCompletedTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => unawaited(_onHomePressed()),
          ),
        ),
        body: DownloadCompletedScreen(
          onHomePressed: () => unawaited(_onHomePressed()),
          onSharePressed: () => _onSharePressed(widget.args.flightId),
        ),
      ),
    );
  }

  void _onSharePressed(String flightId) {
    unawaited(_openShareFromHomeStack(flightId));
  }

  Future<void> _openShareFromHomeStack(String flightId) async {
    if (!mounted) return;
    homeRefreshNotifier.value = true;
    AppRouter.goHome(context);
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    AppRouter.goToShareImage(context, flightId: flightId);
  }

  Future<void> _onHomePressed() async {
    homeRefreshNotifier.value = true;
    AppRouter.goHome(context);
  }
}

class DownloadCompletedScreen extends StatelessWidget {
  const DownloadCompletedScreen({
    required this.onHomePressed,
    required this.onSharePressed,
    super.key,
  });

  final VoidCallback onHomePressed;
  final VoidCallback onSharePressed;

  @override
  Widget build(BuildContext context) {
    return FlightDownloadCompletion(
      onHomePressed: onHomePressed,
      onSharePressed: onSharePressed,
    );
  }
}
