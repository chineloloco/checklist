import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/app_failure.dart';
import '../domain/auth_session.dart';

final class PasswordAuthRepository implements AuthSessionRepository {
  PasswordAuthRepository({
    required AppConfig config,
    required FlutterSecureStorage secureStorage,
    required Future<String> Function() deviceId,
    Dio? dio,
  })  : _config = config,
        _secureStorage = secureStorage,
        _deviceId = deviceId,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: config.hasApi ? '${config.apiV1Base}/' : '',
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 30),
                sendTimeout: const Duration(seconds: 30),
                headers: const {
                  'accept': 'application/json',
                  'content-type': 'application/json',
                },
              ),
            );

  static const _sessionKey = 'password_session_v1';

  final AppConfig _config;
  final FlutterSecureStorage _secureStorage;
  final Future<String> Function() _deviceId;
  final Dio _dio;
  AuthSession? _memorySession;

  @override
  Future<AuthSession?> restore() async {
    if (_memorySession case final session?) return session;
    final value = await _secureStorage.read(key: _sessionKey);
    if (value == null) return null;
    try {
      final json = (jsonDecode(value) as Map).cast<String, Object?>();
      final session = _sessionFromJson(json);
      _memorySession = session;
      return session;
    } on Object {
      await _clear();
      return null;
    }
  }

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    if (!_config.hasApi) {
      throw const ConfigurationFailure(
        'Configure API_BASE_URL antes de entrar.',
      );
    }
    try {
      final response = await _dio.post<Object?>(
        'auth/login',
        data: {
          'email': email.trim(),
          'password': password,
          'deviceId': await _deviceId(),
        },
      );
      final session = _sessionFromResponse(response.data);
      await _persist(session);
      return session;
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        throw const AuthenticationFailure('E-mail ou senha inválidos.');
      }
      throw AuthenticationFailure(
        _problemDetail(
          error,
          fallback:
              'Não foi possível acessar o servidor. Verifique sua conexão.',
        ),
      );
    } on AppFailure {
      rethrow;
    } on Object {
      throw const AuthenticationFailure(
        'O servidor retornou uma resposta de login inválida.',
      );
    }
  }

  @override
  Future<String> validAccessToken({bool forceRefresh = false}) async {
    final session = await restore();
    if (session == null) throw const SessionExpiredFailure();
    if (!forceRefresh && !session.isExpired) return session.accessToken;
    final refreshToken = session.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      await _clear();
      throw const SessionExpiredFailure();
    }
    try {
      final response = await _dio.post<Object?>(
        'auth/refresh',
        data: {'refreshToken': refreshToken, 'deviceId': await _deviceId()},
      );
      final renewed = _sessionFromResponse(response.data);
      await _persist(renewed);
      return renewed.accessToken;
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        await _clear();
        throw const SessionExpiredFailure();
      }
      throw NetworkFailure(
        _problemDetail(
          error,
          fallback:
              'Sem comunicação com o servidor. Tente sincronizar novamente.',
        ),
      );
    } on AppFailure {
      rethrow;
    } on Object {
      await _clear();
      throw const SessionExpiredFailure();
    }
  }

  @override
  Future<void> signOut() async {
    final session = await restore();
    try {
      if (session?.refreshToken case final refreshToken?) {
        await _dio.post<Object?>(
          'auth/logout',
          data: {'refreshToken': refreshToken},
        );
      }
    } on Object {
      // Local sign-out must still succeed when the device is offline.
    } finally {
      await _clear();
    }
  }

  AuthSession _sessionFromResponse(Object? data) {
    if (data is! Map) throw const FormatException('Resposta inválida.');
    final json = data.cast<String, Object?>();
    final user = (json['user'] as Map?)?.cast<String, Object?>() ?? const {};
    return AuthSession(
      accessToken: json['accessToken']! as String,
      accessTokenExpiresAt: DateTime.parse(
        json['accessTokenExpiresAt']! as String,
      ).toUtc(),
      refreshToken: json['refreshToken'] as String?,
      subject: user['id'] as String?,
      displayName: user['displayName'] as String?,
    );
  }

  AuthSession _sessionFromJson(Map<String, Object?> json) => AuthSession(
        accessToken: json['accessToken']! as String,
        accessTokenExpiresAt: DateTime.parse(
          json['accessTokenExpiresAt']! as String,
        ).toUtc(),
        refreshToken: json['refreshToken'] as String?,
        subject: json['subject'] as String?,
        displayName: json['displayName'] as String?,
      );

  Future<void> _persist(AuthSession session) async {
    _memorySession = session;
    await _secureStorage.write(
      key: _sessionKey,
      value: jsonEncode({
        'accessToken': session.accessToken,
        'accessTokenExpiresAt': session.accessTokenExpiresAt.toIso8601String(),
        'refreshToken': session.refreshToken,
        'subject': session.subject,
        'displayName': session.displayName,
      }),
    );
  }

  Future<void> _clear() async {
    _memorySession = null;
    await _secureStorage.delete(key: _sessionKey);
  }

  String _problemDetail(DioException error, {required String fallback}) {
    final data = error.response?.data;
    if (data is Map && data['detail'] is String) {
      return data['detail'] as String;
    }
    return fallback;
  }
}
