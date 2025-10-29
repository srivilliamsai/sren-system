class AppConfig {
  const AppConfig._();

  static const baseUrl =
      String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:8080');
  static const enableSentry =
      bool.fromEnvironment('SENTRY', defaultValue: false);
  static const sentryDsn =
      String.fromEnvironment('SENTRY_DSN', defaultValue: '');
  static const mockMode =
      bool.fromEnvironment('MOCK_MODE', defaultValue: false);
}
