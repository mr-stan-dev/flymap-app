import 'package:flutter/foundation.dart';

class FlightMapStyleTransitionController extends ChangeNotifier {
  bool _isPreparing = false;
  bool _isApplying = false;

  bool get isLoading => _isPreparing || _isApplying;

  void beginPreparing() {
    _updateState(isPreparing: true, isApplying: false);
  }

  void beginApplying() {
    _updateState(isPreparing: false, isApplying: true);
  }

  void complete() {
    _updateState(isPreparing: false, isApplying: false);
  }

  void fail() {
    _updateState(isPreparing: false, isApplying: false);
  }

  void _updateState({required bool isPreparing, required bool isApplying}) {
    if (_isPreparing == isPreparing && _isApplying == isApplying) {
      return;
    }
    _isPreparing = isPreparing;
    _isApplying = isApplying;
    notifyListeners();
  }
}
