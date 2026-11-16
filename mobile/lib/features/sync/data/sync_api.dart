import '../../../core/network/authenticated_api_client.dart';
import '../domain/sync_models.dart';

abstract interface class SyncRemote {
  Future<Map<String, Object?>> push({
    required String deviceId,
    required List<SyncOperationDto> operations,
  });

  Future<Map<String, Object?>> pull({required String cursor, int limit = 200});
}

final class SyncApi implements SyncRemote {
  SyncApi(this._client);
  final AuthenticatedApiClient _client;

  @override
  Future<Map<String, Object?>> push({
    required String deviceId,
    required List<SyncOperationDto> operations,
  }) async {
    final response = await _client.post(
      '/sync/push',
      data: {
        'deviceId': deviceId,
        'operations': operations.map((item) => item.toJson()).toList(),
      },
    );
    return _asObject(response.data);
  }

  @override
  Future<Map<String, Object?>> pull({
    required String cursor,
    int limit = 200,
  }) async {
    final response = await _client.get(
      '/sync/pull',
      queryParameters: {'cursor': cursor, 'limit': limit},
    );
    return _asObject(response.data);
  }

  static Map<String, Object?> _asObject(Object? value) {
    if (value is! Map) throw const FormatException('Resposta JSON inválida.');
    return value.cast<String, Object?>();
  }
}
