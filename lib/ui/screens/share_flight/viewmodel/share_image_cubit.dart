import 'dart:async';
import 'dart:ui';

import 'package:flymap/analytics/app_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/domain/usecase/generate_share_image_use_case.dart';
import 'package:flymap/i18n/strings.g.dart';
import 'package:flymap/logger.dart';
import 'package:flymap/rating/rate_prompt_policy_service.dart';
import 'package:flymap/rating/rate_prompt_trigger.dart';
import 'package:flymap/repository/flight_repository.dart';
import 'package:flymap/utils/route_utils.dart';
import 'package:get_it/get_it.dart';
import 'package:share_plus/share_plus.dart';

import 'share_image_state.dart';

/// Cubit that manages the share image generation and sharing lifecycle.
///
/// State flow: initial → generating → ready(imagePath) → sharing → ready
///                                  ↘ error(message)
class ShareImageCubit extends Cubit<ShareImageState> {
  ShareImageCubit({required String flightId})
    : _generateUseCase = GetIt.I.get<GenerateShareImageUseCase>(),
      _flightRepository = GetIt.I.get<FlightRepository>(),
      _ratePromptPolicyService = GetIt.I.get<RatePromptPolicyService>(),
      _analytics = GetIt.I.get<AppAnalytics>(),
      super(ShareImageState.initial(flightId: flightId)) {
    _generate();
  }

  final GenerateShareImageUseCase _generateUseCase;
  final FlightRepository _flightRepository;
  final RatePromptPolicyService _ratePromptPolicyService;
  final AppAnalytics _analytics;
  final Logger _logger = const Logger('ShareImageCubit');

  /// Generates the share image. Called automatically on construction.
  Future<void> _generate() async {
    emit(state.copyWith(status: ShareImageStatus.generating, clearError: true));

    final flight = await _flightRepository.getFlightById(state.flightId);
    if (isClosed) return;
    if (flight == null) {
      _analytics.log(
        const ShareCardGeneratedEvent(
          success: false,
          error: 'flight_not_found',
        ),
      );
      emit(
        state.copyWith(
          status: ShareImageStatus.error,
          errorMessage: 'Could not generate flight card',
        ),
      );
      return;
    }

    final path = await _generateUseCase.call(flight);
    if (isClosed) return;

    if (path != null) {
      _analytics.log(const ShareCardGeneratedEvent(success: true, error: ''));
      emit(
        state.copyWith(
          flight: flight,
          status: ShareImageStatus.ready,
          imagePath: path,
          clearError: true,
        ),
      );
    } else {
      _analytics.log(
        const ShareCardGeneratedEvent(
          success: false,
          error: 'could_not_generate_flight_card',
        ),
      );
      emit(
        state.copyWith(
          status: ShareImageStatus.error,
          errorMessage: 'Could not generate flight card',
        ),
      );
    }
  }

  /// Retry generating the image after an error.
  Future<void> retry() async {
    await _generate();
  }

  void onShareCardCtaTapped() {
    _analytics.log(const ShareCardSharedEvent());
    unawaited(
      _ratePromptPolicyService.registerTrigger(
        RatePromptTrigger.shareCardShared,
      ),
    );
  }

  /// Share the generated image via the native share sheet.
  Future<void> shareImage({
    required Rect sharePositionOrigin,
    String? imagePathOverride,
  }) async {
    final path = imagePathOverride ?? state.imagePath;
    final flight = state.flight;
    if (path == null || state.isSharing || flight == null) return;

    emit(state.copyWith(status: ShareImageStatus.sharing, clearError: true));

    try {
      final route = flight.route;
      final depCity = RouteUtils.cityLabel(route.departure.city);
      final arrCity = RouteUtils.cityLabel(route.arrival.city);
      await Share.shareXFiles(
        [XFile(path)],
        text: t.shareImage.shareText(
          fromCity: depCity,
          fromCode: route.departure.displayCode,
          toCity: arrCity,
          toCode: route.arrival.displayCode,
        ),
        sharePositionOrigin: sharePositionOrigin,
      );
      if (isClosed) return;
      emit(state.copyWith(status: ShareImageStatus.ready, clearError: true));
    } catch (e) {
      _logger.error('Failed to share flight image: $e');
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ShareImageStatus.ready,
          errorMessage: 'Failed to share flight card',
        ),
      );
    }
  }
}
