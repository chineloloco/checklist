import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

abstract interface class DeviceIdProvider {
  Future<String> get id;
}

final class DeviceIdentity implements DeviceIdProvider {
  DeviceIdentity(this._storage, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  static const _key = 'device_id_v1';
  final FlutterSecureStorage _storage;
  final Uuid _uuid;

  @override
  Future<String> get id async {
    final existing = await _storage.read(key: _key);
    if (existing != null && existing.isNotEmpty) return existing;
    final created = 'flutter-${_uuid.v7()}';
    await _storage.write(key: _key, value: created);
    return created;
  }
}
