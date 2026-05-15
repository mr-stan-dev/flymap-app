class MapboxEnvConfig {
  const MapboxEnvConfig({this.accessToken = ''});

  factory MapboxEnvConfig.fromEnvironment() {
    return const MapboxEnvConfig(
      accessToken: String.fromEnvironment(
        'MAPBOX_ACCESS_TOKEN',
        defaultValue: '',
      ),
    );
  }

  final String accessToken;

  String get trimmedAccessToken => accessToken.trim();
}
