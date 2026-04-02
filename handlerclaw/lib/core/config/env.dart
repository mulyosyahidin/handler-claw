class Env {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com/api',
  );

  static const String appBaseUrl = String.fromEnvironment(
    'APP_BASE_URL',
    defaultValue: 'https://api.example.com',
  );

  static const bool showDebugPage = bool.fromEnvironment(
    'SHOW_DEBUG_PAGE',
    defaultValue: false,
  );
}
