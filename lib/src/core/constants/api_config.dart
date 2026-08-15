class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://jeramy-silty-stasia.ngrok-free.dev',
  );
}
