class FlightNumberValidator {
  static final RegExp _flightNumberPattern = RegExp(r'^[A-Z0-9]{3,8}$');

  static bool isValid(String raw) {
    final normalized = raw.replaceAll(RegExp(r'\s+'), '').trim().toUpperCase();
    if (!_flightNumberPattern.hasMatch(normalized)) {
      return false;
    }
    return RegExp(r'[A-Z]').hasMatch(normalized) &&
        RegExp(r'\d').hasMatch(normalized);
  }
}
