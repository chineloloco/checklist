final class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.oidcIssuer,
    required this.oidcClientId,
    required this.oidcRedirectUrl,
  });

  factory AppConfig.fromEnvironment() => const AppConfig(
        apiBaseUrl: String.fromEnvironment('API_BASE_URL'),
        oidcIssuer: String.fromEnvironment('OIDC_ISSUER'),
        oidcClientId: String.fromEnvironment('OIDC_CLIENT_ID'),
        oidcRedirectUrl: String.fromEnvironment('OIDC_REDIRECT_URL'),
      );

  final String apiBaseUrl;
  final String oidcIssuer;
  final String oidcClientId;
  final String oidcRedirectUrl;

  bool get hasApi => apiBaseUrl.trim().isNotEmpty;
  bool get hasOidc =>
      oidcIssuer.trim().isNotEmpty &&
      oidcClientId.trim().isNotEmpty &&
      oidcRedirectUrl.trim().isNotEmpty;

  Uri get apiV1Base {
    final normalized = apiBaseUrl.endsWith('/')
        ? apiBaseUrl.substring(0, apiBaseUrl.length - 1)
        : apiBaseUrl;
    return Uri.parse('$normalized/api/v1');
  }

  List<String> get missingSettings => [
        if (!hasApi) 'API_BASE_URL',
        if (oidcIssuer.trim().isEmpty) 'OIDC_ISSUER',
        if (oidcClientId.trim().isEmpty) 'OIDC_CLIENT_ID',
        if (oidcRedirectUrl.trim().isEmpty) 'OIDC_REDIRECT_URL',
      ];
}
