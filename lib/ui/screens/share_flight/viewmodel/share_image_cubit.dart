import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flymap/domain/entity/flight.dart';
import 'package:flymap/domain/usecase/generate_share_image_use_case.dart';
import 'package:flymap/logger.dart';
import 'package:get_it/get_it.dart';
import 'package:share_plus/share_plus.dart';

import 'share_image_state.dart';

/// Cubit that manages the share image generation and sharing lifecycle.
///
/// State flow: initial → generating → ready(imagePath) → sharing → ready
///                                  ↘ error(message)
class ShareImageCubit extends Cubit<ShareImageState> {
  ShareImageCubit({
    required Flight flight,
    GenerateShareImageUseCase? generateUseCase,
  }) : _generateUseCase =
           generateUseCase ?? GetIt.I.get<GenerateShareImageUseCase>(),
       super(ShareImageState.initial(flight: flight)) {
    _generate();
  }

  final GenerateShareImageUseCase _generateUseCase;
  final Logger _logger = const Logger('ShareImageCubit');

  /// Generates the share image. Called automatically on construction.
  Future<void> _generate() async {
    emit(state.copyWith(status: ShareImageStatus.generating, clearError: true));

    final path = await _generateUseCase.call(state.flight);
    if (isClosed) return;

    if (path != null) {
      emit(
        state.copyWith(
          status: ShareImageStatus.ready,
          imagePath: path,
          clearError: true,
        ),
      );
    } else {
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

  /// Share the generated image via the native share sheet.
  Future<void> shareImage({
    required Rect sharePositionOrigin,
    String? imagePathOverride,
  }) async {
    final path = imagePathOverride ?? state.imagePath;
    if (path == null || state.isSharing) return;

    emit(state.copyWith(status: ShareImageStatus.sharing, clearError: true));

    try {
      final route = state.flight.route;
      await Share.shareXFiles(
        [XFile(path)],
        text:
            'Flight route '
            '${route.departure.displayCode} → ${route.arrival.displayCode}',
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
