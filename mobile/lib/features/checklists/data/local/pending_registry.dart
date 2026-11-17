import 'app_database.dart';

const registryEntityTypes = {'COMPANY', 'SITE', 'PERSON', 'ASSET'};

Future<Set<String>> pendingRegistryIds(AppDatabase db, String type) async {
  final rows = await (db.select(
    db.syncOutboxOperations,
  )..where((row) => row.entityType.equals(type))).get();
  return rows.map((row) => row.entityId).toSet();
}
