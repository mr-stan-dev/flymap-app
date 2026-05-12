enum FlightRouteSource {
  greatCircle('great_circle'),
  fr24Historical('fr24_historical');

  const FlightRouteSource(this.rawValue);

  final String rawValue;

  static FlightRouteSource fromRaw(dynamic raw) {
    final value = (raw ?? '').toString().trim().toLowerCase();
    return switch (value) {
      'fr24_historical' => FlightRouteSource.fr24Historical,
      _ => FlightRouteSource.greatCircle,
    };
  }
}
