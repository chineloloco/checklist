final class AppConfig {
  const AppConfig({required this.apiBaseUrl});

  factory AppConfig.fromEnvironment() =>
      const AppConfig(apiBaseUrl: String.fromEnvironment('API_BASE_URL'));

  final String apiBaseUrl;

  bool get hasApi => apiBaseUrl.trim().isNotEmpty;

  Uri get apiV1Base {
    final normalized = apiBaseUrl.endsWith('/')
        ? apiBaseUrl.substring(0, apiBaseUrl.length - 1)
        : apiBaseUrl;
    return Uri.parse('$normalized/api/v1');
  }

  List<String> get missingSettings => [if (!hasApi) 'API_BASE_URL'];
}
