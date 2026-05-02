class ApiConfig {
  ApiConfig._();

  static const String geoFunctionsBaseUrl =
      'https://us-central1-flymap-app.cloudfunctions.net';
  static const Duration geoRequestTimeout = Duration(seconds: 12);
  static const Duration routeRegionsRequestTimeout = Duration(seconds: 25);
}
