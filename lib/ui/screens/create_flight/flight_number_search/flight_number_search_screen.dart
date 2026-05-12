import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/router/app_router.dart';
import 'package:flymap/ui/theme/app_theme_ext.dart';
import 'package:get_it/get_it.dart';
import 'viewmodel/flight_number_search_cubit.dart';
import 'viewmodel/flight_number_search_state.dart';
import 'widgets/flight_summary_card.dart';
import 'package:flymap/ui/design_system/design_system.dart';

class FlightNumberSearchScreen extends StatefulWidget {
  const FlightNumberSearchScreen({super.key});

  @override
  State<FlightNumberSearchScreen> createState() =>
      _FlightNumberSearchScreenState();
}

class _FlightNumberSearchScreenState extends State<FlightNumberSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FlightNumberSearchCubit(
        lookupFlightByNumberUseCase: GetIt.I.get(),
        flightSearchRepository: GetIt.I.get(),
        analytics: GetIt.I.get(),
        crashlytics: GetIt.I.get(),
      ),
      child: BlocConsumer<FlightNumberSearchCubit, FlightNumberSearchState>(
        listener: (context, state) {
          if (state is FlightNumberSearchSuccess) {
            AppRouter.goToFlightOverview(
              context,
              departure: state.departure,
              arrival: state.arrival,
              flightNumber: state.flightNumber,
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<FlightNumberSearchCubit>();
          final isLoading = state is FlightNumberSearchLoading;
          final errorState = state is FlightNumberSearchError ? state : null;
          final isError = errorState != null;
          final summary = state is FlightNumberSearchSummaryLoaded
              ? state.summary
              : errorState?.summary;

          final flightNumber = _controller.text.trim();
          final canContinue = flightNumber.isNotEmpty && !isLoading;

          final t = context.t.createFlight.flightNumberSearch;

          Widget? feedback;
          if (isLoading) {
            feedback = Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(t.loading, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            );
          } else if (isError) {
            feedback = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  errorState.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                TertiaryButton(
                  label: t.findByAirports,
                  onPressed: () => AppRouter.goToFlightSearch(context),
                  expand: false,
                ),
              ],
            );
          }

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(t.subtitle, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.characters,
                enabled: !isLoading,
                decoration: InputDecoration(
                  hintText: t.hint,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) {
                  if (summary != null || isError) {
                    cubit.clearSummary();
                  } else {
                    setState(() {});
                  }
                },
                onSubmitted: (_) {
                  if (canContinue) {
                    if (summary == null) {
                      cubit.loadFlightSummary(flightNumber);
                    } else {
                      cubit.confirmSummaryAndLoadRoute(
                        flightNumber: flightNumber,
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 32),
              if (feedback != null) feedback,
              if (summary != null) ...[
                Text(
                  t.foundTitle,
                  style: context.textTheme.title24Medium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                FlightSummaryCard(summary: summary),
              ],
            ],
          );

          return Scaffold(
            appBar: AppBar(title: Text(context.t.home.newFlight)),
            body: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Expanded(child: content),
                    if (!isLoading && (!isError || summary != null))
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          label: summary == null
                              ? context.t.common.search
                              : context.t.common.kContinue,
                          onPressed: canContinue
                              ? () {
                                  if (summary == null) {
                                    cubit.loadFlightSummary(flightNumber);
                                  } else {
                                    cubit.confirmSummaryAndLoadRoute(
                                      flightNumber: flightNumber,
                                    );
                                  }
                                }
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
