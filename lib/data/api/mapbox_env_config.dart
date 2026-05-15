class MapboxEnvConfig {
  const MapboxEnvConfig({this.accessToken = ''});

  factory MapboxEnvConfig.fromEnvironment() {
    const rawToken = String.fromEnvironment(
      'MAPBOX_ACCESS_TOKEN',
      defaultValue: '',
    );
    final trimmedToken = rawToken.trim();
    assert(() {
      if (trimmedToken.isEmpty) {
        throw StateError(
          'MAPBOX_ACCESS_TOKEN is missing. Pass --dart-define=MAPBOX_ACCESS_TOKEN=<token>.',
        );
      }
      return true;
    }());

    return const MapboxEnvConfig(accessToken: rawToken);
  }

  final String accessToken;

  String get trimmedAccessToken => accessToken.trim();
}
