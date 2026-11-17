import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/authenticated_api_client.dart';
import '../../domain/checklist_models.dart';
import '../local/app_database.dart';
import '../local/pending_registry.dart';

final class RegistryApi {
  RegistryApi(this._client, this._db, {Uuid? uuid, this.onQueued})
    : _uuid = uuid ?? const Uuid();

  final AuthenticatedApiClient _client;
  final AppDatabase _db;
  final Uuid _uuid;
  final void Function()? onQueued;
  bool lastReadUsedCache = false;

  Future<List<RegistryCompany>> companies({bool localOnly = false}) async {
    if (localOnly) {
      lastReadUsedCache = true;
    } else {
      try {
        await _cacheCompanies(
          _dataList((await _client.get('/companies')).data),
        );
        lastReadUsedCache = false;
      } on NetworkFailure {
        lastReadUsedCache = true;
      }
    }
    final rows =
        await (_db.select(_db.localCompanies)
              ..where((table) => table.active.equals(true))
              ..orderBy([(table) => OrderingTerm.asc(table.name)]))
            .get();
    return rows
        .map((row) => RegistryCompany(id: row.id, name: row.name))
        .toList(growable: false);
  }

  Future<List<RegistrySite>> sites({bool localOnly = false}) async {
    if (localOnly) {
      lastReadUsedCache = true;
    } else {
      try {
        await _cacheSites(_dataList((await _client.get('/sites')).data));
        lastReadUsedCache = false;
      } on NetworkFailure {
        lastReadUsedCache = true;
      }
    }
    final rows =
        await (_db.select(_db.localSites)
              ..where((table) => table.active.equals(true))
              ..orderBy([(table) => OrderingTerm.asc(table.name)]))
            .get();
    return rows
        .map(
          (row) => RegistrySite(
            id: row.id,
            companyId: row.companyId,
            name: row.name,
          ),
        )
        .toList(growable: false);
  }

  Future<List<RegistryPerson>> people({bool localOnly = false}) async {
    if (localOnly) {
      lastReadUsedCache = true;
    } else {
      try {
        await _cachePeople(_dataList((await _client.get('/people')).data));
        lastReadUsedCache = false;
      } on NetworkFailure {
        lastReadUsedCache = true;
      }
    }
    final rows =
        await (_db.select(_db.localPeople)
              ..where((table) => table.active.equals(true))
              ..orderBy([(table) => OrderingTerm.asc(table.name)]))
            .get();
    return rows
        .map(
          (row) => RegistryPerson(
            id: row.id,
            name: row.name,
            kind: row.kind,
            driverLicenseNumber: row.driverLicenseNumber,
            driverLicenseExpiryDate: row.driverLicenseExpiryDate,
          ),
        )
        .toList(growable: false);
  }

  Future<Map<String, Object?>> _saveLocal(
    String type,
    Map<String, Object?> payload,
    Future<void> Function(Map<String, Object?>) save,
  ) async {
    final id = _uuid.v7();
    final row = <String, Object?>{
      ...payload,
      'id': id,
      'active': true,
      'revision': 1,
    };
    await _db.transaction(() async {
      await save(row);
      await _db
          .into(_db.syncOutboxOperations)
          .insert(
            SyncOutboxOperationsCompanion.insert(
              operationId: _uuid.v7(),
              entityType: type,
              mutation: 'UPSERT',
              entityId: id,
              clientOccurredAt: DateTime.now().toUtc(),
              payloadJson: jsonEncode(payload),
            ),
          );
    });
    onQueued?.call();
    return row;
  }

  static String _required(String value, String field, {int max = 200}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > max) {
      throw ValidationFailure('Informe um valor válido para $field.');
    }
    return trimmed;
  }

  Future<RegistryCompany> createCompany({
    required String name,
    String? document,
  }) async {
    final row = await _saveLocal(
      'COMPANY',
      {'name': _required(name, 'nome'), 'document': _nullIfBlank(document)},
      (row) async {
        await _db
            .into(_db.localCompanies)
            .insert(
              LocalCompaniesCompanion.insert(
                id: row['id']! as String,
                name: row['name']! as String,
              ),
            );
      },
    );
    return RegistryCompany(
      id: row['id']! as String,
      name: row['name']! as String,
    );
  }

  Future<RegistrySite> createSite({
    String? companyId,
    required String name,
  }) async {
    final row = await _saveLocal(
      'SITE',
      {'companyId': _nullIfBlank(companyId), 'name': _required(name, 'nome')},
      (row) async {
        await _db
            .into(_db.localSites)
            .insert(
              LocalSitesCompanion.insert(
                id: row['id']! as String,
                companyId: row['companyId'] as String? ?? '',
                name: row['name']! as String,
              ),
            );
      },
    );
    return RegistrySite(
      id: row['id']! as String,
      companyId: row['companyId'] as String? ?? '',
      name: row['name']! as String,
    );
  }

  Future<RegistryPerson> createPerson({
    required String name,
    required String kind,
    String? driverLicenseNumber,
    String? driverLicenseExpiryDate,
  }) async {
    if (!{'DRIVER', 'OPERATOR', 'SUPERVISOR'}.contains(kind)) {
      throw const ValidationFailure('Selecione uma função válida.');
    }
    final row = await _saveLocal(
      'PERSON',
      {
        'name': _required(name, 'nome'),
        'kind': kind,
        'driverLicenseNumber': _nullIfBlank(driverLicenseNumber),
        'driverLicenseExpiryDate': _nullIfBlank(driverLicenseExpiryDate),
      },
      (row) async {
        final person = _personFromJson(row);
        await _db
            .into(_db.localPeople)
            .insert(
              LocalPeopleCompanion.insert(
                id: person.id,
                name: person.name,
                kind: person.kind,
                driverLicenseNumber: Value(person.driverLicenseNumber),
                driverLicenseExpiryDate: Value(person.driverLicenseExpiryDate),
              ),
            );
      },
    );
    return _personFromJson(row);
  }

  Future<AssetSummary> createAsset({
    required String companyId,
    required String? siteId,
    required String kind,
    required String code,
    required String description,
    required String ownershipType,
    required TemplateChoice template,
    String? licensePlate,
  }) async {
    if (kind != template.assetKind ||
        !{'OWN', 'THIRD_PARTY'}.contains(ownershipType)) {
      throw const ValidationFailure('Tipo de ativo ou propriedade inválido.');
    }
    final row = await _saveLocal(
      'ASSET',
      {
        'companyId': _required(companyId, 'empresa'),
        'siteId': siteId,
        'kind': kind,
        'code': _required(code, 'código', max: 100),
        'licensePlate': _nullIfBlank(licensePlate),
        'makeModel': kind == 'VEHICLE'
            ? _required(description, 'descrição')
            : null,
        'manufacturer': kind == 'EQUIPMENT'
            ? _required(description, 'description')
            : null,
        'ownershipType': ownershipType,
      },
      (row) async {
        await _db
            .into(_db.localAssets)
            .insert(
              LocalAssetsCompanion.insert(
                id: row['id']! as String,
                kind: kind,
                code: row['code']! as String,
                active: true,
                revision: 1,
                siteId: Value(siteId),
                licensePlate: Value(row['licensePlate'] as String?),
                makeModel: Value(row['makeModel'] as String?),
                manufacturer: Value(row['manufacturer'] as String?),
                ownershipType: Value(ownershipType),
                rawJson: jsonEncode(row),
              ),
            );
      },
    );
    return AssetSummary(
      id: row['id']! as String,
      kind: kind,
      code: row['code']! as String,
      active: true,
      siteId: siteId,
      licensePlate: row['licensePlate'] as String?,
      makeModel: row['makeModel'] as String?,
      manufacturer: row['manufacturer'] as String?,
      ownershipType: ownershipType,
    );
  }

  static String? _nullIfBlank(String? value) =>
      value == null || value.trim().isEmpty ? null : value.trim();

  static RegistryPerson _personFromJson(Map<String, Object?> json) =>
      RegistryPerson(
        id: json['id']!.toString(),
        name: json['name']!.toString(),
        kind: json['kind']!.toString(),
        driverLicenseNumber: json['driverLicenseNumber']?.toString(),
        driverLicenseExpiryDate: json['driverLicenseExpiryDate']?.toString(),
      );

  Future<void> _cacheCompanies(List<Map<String, Object?>> data) async {
    await _db.transaction(() async {
      final pending = await pendingRegistryIds(_db, 'COMPANY');
      await (_db.update(_db.localCompanies)
            ..where((row) => row.id.isNotIn(pending)))
          .write(const LocalCompaniesCompanion(active: Value(false)));
      for (final item in data.where((item) => item['active'] != false)) {
        await _db
            .into(_db.localCompanies)
            .insertOnConflictUpdate(
              LocalCompaniesCompanion.insert(
                id: item['id']!.toString(),
                name: item['name']!.toString(),
                active: const Value(true),
              ),
            );
      }
    });
  }

  Future<void> _cacheSites(List<Map<String, Object?>> data) async {
    await _db.transaction(() async {
      final pending = await pendingRegistryIds(_db, 'SITE');
      await (_db.update(_db.localSites)
            ..where((row) => row.id.isNotIn(pending)))
          .write(const LocalSitesCompanion(active: Value(false)));
      for (final item in data.where((item) => item['active'] != false)) {
        await _db
            .into(_db.localSites)
            .insertOnConflictUpdate(
              LocalSitesCompanion.insert(
                id: item['id']!.toString(),
                companyId: item['companyId']?.toString() ?? '',
                name: item['name']!.toString(),
                active: const Value(true),
              ),
            );
      }
    });
  }

  Future<void> _cachePeople(List<Map<String, Object?>> data) async {
    await _db.transaction(() async {
      final pending = await pendingRegistryIds(_db, 'PERSON');
      await (_db.update(_db.localPeople)
            ..where((row) => row.id.isNotIn(pending)))
          .write(const LocalPeopleCompanion(active: Value(false)));
      for (final item in data.where(
        (item) =>
            item['active'] != false &&
            item['name']?.toString() != 'Responsável pelo preenchimento',
      )) {
        final person = _personFromJson(item);
        await _db
            .into(_db.localPeople)
            .insertOnConflictUpdate(
              LocalPeopleCompanion.insert(
                id: person.id,
                name: person.name,
                kind: person.kind,
                driverLicenseNumber: Value(person.driverLicenseNumber),
                driverLicenseExpiryDate: Value(person.driverLicenseExpiryDate),
                active: const Value(true),
              ),
            );
      }
    });
  }

  static Map<String, Object?> _object(Object? value) {
    if (value is! Map) throw const FormatException('Resposta JSON inválida.');
    return value.cast<String, Object?>();
  }

  static List<Map<String, Object?>> _dataList(Object? value) {
    final envelope = _object(value);
    final data = envelope['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) => item.cast<String, Object?>())
        .toList(growable: false);
  }
}
