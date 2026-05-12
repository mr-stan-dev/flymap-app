enum FlightStatus {
  upcoming('upcoming'),
  inProgress('in_progress'),
  completed('completed');

  const FlightStatus(this.rawValue);

  final String rawValue;

  static FlightStatus fromRaw(String raw) {
    for (final value in FlightStatus.values) {
      if (value.rawValue == raw) return value;
    }
    return FlightStatus.upcoming;
  }
}
