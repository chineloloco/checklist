import '../../../../core/network/authenticated_api_client.dart';

abstract interface class ChecklistRemote {
  Future<Map<String, Object?>> me();
  Future<Map<String, Object?>> bootstrap({String? sinceCursor});
}

final class ChecklistApi implements ChecklistRemote {
  ChecklistApi(this._client);
  final AuthenticatedApiClient _client;

  @override
  Future<Map<String, Object?>> me() async {
    final response = await _client.get('/me');
    return _asObject(response.data);
  }

  @override
  Future<Map<String, Object?>> bootstrap({String? sinceCursor}) async {
    final response = await _client.get(
      '/mobile/bootstrap',
      queryParameters: {
        if (sinceCursor != null) 'sinceCursor': sinceCursor,
      },
    );
    return _asObject(response.data);
  }

  static Map<String, Object?> _asObject(Object? value) {
    if (value is! Map) throw const FormatException('Resposta JSON inválida.');
    return value.cast<String, Object?>();
  }
}
