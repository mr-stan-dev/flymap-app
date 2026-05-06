part of '../flight_preview_cubit.dart';

class MapAndStepNavigationDelegate {
  MapAndStepNavigationDelegate(this._cubit);

  final FlightPreviewCubit _cubit;

  void selectMapDetailLevel(MapDetailLevel detailLevel) {
    if (_cubit.state.step != CreateFlightStep.overview) return;
    if (_cubit.state.selectedMapDetailLevel == detailLevel) return;
    _cubit._emitState(
      _cubit.state.copyWith(
        selectedMapDetailLevel: detailLevel,
        clearErrorMessage: true,
      ),
    );
    _cubit._syncPoisForCurrentTier();
  }

  void continueFromOverview() {
    if (_cubit.state.flightRoute == null) return;
    _cubit._emitState(
      _cubit.state.copyWith(
        step: CreateFlightStep.wikipediaArticles,
        clearErrorMessage: true,
        clearDownloadErrorMessage: true,
      ),
    );
  }

  Future<bool> handleBackAction() async {
    if (_cubit.state.isDownloading) return false;

    switch (_cubit.state.step) {
      case CreateFlightStep.routeNotSupported:
      case CreateFlightStep.overview:
        return true;
      case CreateFlightStep.wikipediaArticles:
        _cubit._emitState(
          _cubit.state.copyWith(
            step: CreateFlightStep.overview,
            clearErrorMessage: true,
            clearDownloadErrorMessage: true,
          ),
        );
        return false;
    }
  }
}
