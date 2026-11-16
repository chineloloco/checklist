import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../errors/app_failure.dart';
import '../../features/auth/domain/auth_session.dart';

final class AuthenticatedApiClient {
  AuthenticatedApiClient({
    required AppConfig config,
    required AuthSessionRepository auth,
    Dio? dio,
  }) : _auth = auth,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: config.hasApi ? config.apiV1Base.toString() : '',
               connectTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(seconds: 30),
               sendTimeout: const Duration(seconds: 30),
               headers: const {'accept': 'application/json'},
             ),
           );

  final AuthSessionRepository _auth;
  final Dio _dio;

  Future<Response<Object?>> get(
    String path, {
    Map<String, Object?>? queryParameters,
  }) => _request(path, method: 'GET', queryParameters: queryParameters);

  Future<Response<Object?>> post(
    String path, {
    Object? data,
    Map<String, Object?>? headers,
  }) => _request(path, method: 'POST', data: data, headers: headers);

  Future<Response<Object?>> _request(
    String path, {
    required String method,
    Object? data,
    Map<String, Object?>? queryParameters,
    Map<String, Object?>? headers,
  }) async {
    Future<Response<Object?>> send({required bool forceRefresh}) async {
      final token = await _auth.validAccessToken(forceRefresh: forceRefresh);
      return _dio.request<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          method: method,
          headers: {
            'authorization': 'Bearer $token',
            'content-type': 'application/json',
            ...?headers,
          },
        ),
      );
    }

    try {
      return await send(forceRefresh: false);
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        try {
          return await send(forceRefresh: true);
        } on Object {
          throw const SessionExpiredFailure();
        }
      }
      throw _mapDioFailure(error);
    }
  }

  AppFailure _mapDioFailure(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;
    final problem = data is Map
        ? data.cast<String, Object?>()
        : const <String, Object?>{};
    final detail = problem['detail']?.toString();
    if (status == 409) {
      return ConflictFailure(
        detail ?? 'O servidor identificou um conflito.',
        conflictId: problem['conflictId']?.toString(),
      );
    }
    if (status == 401) return const SessionExpiredFailure();
    if (status == 410) return const CursorExpiredFailure();
    if (status == 422) {
      final errors = problem['errors'];
      final firstError =
          errors is List && errors.isNotEmpty && errors.first is Map
          ? (errors.first as Map).cast<String, Object?>()
          : null;
      final pointer = firstError?['pointer']?.toString();
      final message = firstError?['message']?.toString();
      return ValidationFailure(
        message == null
            ? detail ?? 'O servidor recusou os dados enviados.'
            : '${pointer == null ? '' : '$pointer: '}$message',
      );
    }
    if (status != null) {
      return NetworkFailure(detail ?? 'A API respondeu com erro $status.');
    }
    return NetworkFailure(
      error.type == DioExceptionType.connectionTimeout
          ? 'A conexão demorou demais. Os dados continuam salvos no aparelho.'
          : 'Sem comunicação com o servidor. Os dados continuam salvos no aparelho.',
    );
  }
}
