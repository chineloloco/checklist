import 'dart:convert';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/app_failure.dart';
import '../domain/auth_session.dart';

final class OidcAuthRepository implements AuthSessionRepository {
  OidcAuthRepository({
    required AppConfig config,
    required FlutterSecureStorage secureStorage,
    FlutterAppAuth? appAuth,
  })  : _config = config,
        _secureStorage = secureStorage,
        _appAuth = appAuth ?? const FlutterAppAuth();

  static const _sessionKey = 'oidc_session_v1';
  static const _scopes = [
    'openid',
    'profile',
    'offline_access',
    'checklists:read',
    'inspections:write',
    'sync',
  ];

  final AppConfig _config;
  final FlutterSecureStorage _secureStorage;
  final FlutterAppAuth _appAuth;
  AuthSession? _memorySession;

  @override
  Future<AuthSession?> restore() async {
    if (_memorySession case final session?) return session;
    final value = await _secureStorage.read(key: _sessionKey);
    if (value == null) return null;
    try {
      final json = (jsonDecode(value) as Map).cast<String, Object?>();
      final session = AuthSession(
        accessToken: json['accessToken']! as String,
        accessTokenExpiresAt:
            DateTime.parse(json['accessTokenExpiresAt']! as String).toUtc(),
        refreshToken: json['refreshToken'] as String?,
        idToken: json['idToken'] as String?,
        subject: json['subject'] as String?,
        displayName: json['displayName'] as String?,
      );
      _memorySession = session;
      return session;
    } on Object {
      await _secureStorage.delete(key: _sessionKey);
      return null;
    }
  }

  @override
  Future<AuthSession> signIn() async {
    if (!_config.hasOidc) {
      throw ConfigurationFailure(
        'Configure ${_config.missingSettings.join(', ')} antes de autenticar.',
      );
    }
    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _config.oidcClientId,
          _config.oidcRedirectUrl,
          issuer: _config.oidcIssuer,
          scopes: _scopes,
          promptValues: const ['login'],
        ),
      );
      if (result?.accessToken == null) {
        throw const AuthenticationFailure(
          'O provedor não retornou um token de acesso.',
        );
      }
      final session = _sessionFromTokenResult(
        accessToken: result!.accessToken!,
        accessTokenExpirationDateTime: result.accessTokenExpirationDateTime,
        refreshToken: result.refreshToken,
        idToken: result.idToken,
      );
      await _persist(session);
      return session;
    } on FlutterAppAuthUserCancelledException {
      throw const AuthenticationFailure('Entrada cancelada.');
    } on AppFailure {
      rethrow;
    } on Object catch (error) {
      throw AuthenticationFailure('Não foi possível entrar: $error');
    }
  }

  @override
  Future<String> validAccessToken({bool forceRefresh = false}) async {
    final session = await restore();
    if (session == null) throw const SessionExpiredFailure();
    if (!forceRefresh && !session.isExpired) return session.accessToken;
    final refreshToken = session.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      throw const SessionExpiredFailure();
    }
    try {
      final result = await _appAuth.token(
        TokenRequest(
          _config.oidcClientId,
          _config.oidcRedirectUrl,
          issuer: _config.oidcIssuer,
          refreshToken: refreshToken,
          scopes: _scopes,
        ),
      );
      if (result?.accessToken == null) throw const SessionExpiredFailure();
      final renewed = _sessionFromTokenResult(
        accessToken: result!.accessToken!,
        accessTokenExpirationDateTime: result.accessTokenExpirationDateTime,
        refreshToken: result.refreshToken ?? refreshToken,
        idToken: result.idToken ?? session.idToken,
      );
      await _persist(renewed);
      return renewed.accessToken;
    } on SessionExpiredFailure {
      rethrow;
    } on Object {
      throw const SessionExpiredFailure();
    }
  }

  @override
  Future<void> signOut() async {
    _memorySession = null;
    await _secureStorage.delete(key: _sessionKey);
  }

  AuthSession _sessionFromTokenResult({
    required String accessToken,
    required DateTime? accessTokenExpirationDateTime,
    required String? refreshToken,
    required String? idToken,
  }) {
    final claims = _decodeJwt(idToken);
    return AuthSession(
      accessToken: accessToken,
      accessTokenExpiresAt:
          accessTokenExpirationDateTime?.toUtc() ?? DateTime.now().toUtc(),
      refreshToken: refreshToken,
      idToken: idToken,
      subject: claims['sub'] as String?,
      displayName: (claims['name'] ?? claims['preferred_username']) as String?,
    );
  }

  Future<void> _persist(AuthSession session) async {
    _memorySession = session;
    await _secureStorage.write(
      key: _sessionKey,
      value: jsonEncode({
        'accessToken': session.accessToken,
        'accessTokenExpiresAt': session.accessTokenExpiresAt.toIso8601String(),
        'refreshToken': session.refreshToken,
        'idToken': session.idToken,
        'subject': session.subject,
        'displayName': session.displayName,
      }),
    );
  }

  static Map<String, Object?> _decodeJwt(String? token) {
    if (token == null) return const {};
    final parts = token.split('.');
    if (parts.length != 3) return const {};
    try {
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      return (jsonDecode(payload) as Map).cast<String, Object?>();
    } on Object {
      return const {};
    }
  }
}
