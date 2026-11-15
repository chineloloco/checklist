import 'dart:convert';
import 'dart:math';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app_database.dart';

abstract final class DatabaseFactory {
  static const _databaseKeyName = 'checklist_database_key_v1';

  static Future<AppDatabase> open(FlutterSecureStorage secureStorage) async {
    var key = await secureStorage.read(key: _databaseKeyName);
    if (key == null || key.isEmpty) {
      final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
      key = base64UrlEncode(bytes);
      await secureStorage.write(key: _databaseKeyName, value: key);
    }

    final escapedKey = key.replaceAll("'", "''");
    final executor = driftDatabase(
      name: 'checklists_mobile_v1',
      native: DriftNativeOptions(
        shareAcrossIsolates: true,
        setup: (database) {
          database.execute("PRAGMA key = '$escapedKey';");
          database.execute('PRAGMA foreign_keys = ON;');
          database.execute('PRAGMA journal_mode = WAL;');
        },
      ),
    );
    return AppDatabase(executor);
  }
}
