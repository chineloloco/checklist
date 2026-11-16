import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/authenticated_api_client.dart';
import '../local/app_database.dart';
import '../../domain/checklist_models.dart';

final class RegistryApi {
  RegistryApi(this._client, this._db, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final AuthenticatedApiClient _client;
  final AppDatabase _db;
  final Uuid _uuid;
  bool lastReadUsedCache = false;

  Future<List<RegistryCompany>> companies() async {
    try {
      await _cacheCompanies(_dataList((await _client.get('/companies')).data));
      lastReadUsedCache = false;
    } on NetworkFailure {
      lastReadUsedCache = true;
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

  Future<List<RegistrySite>> sites() async {
    try {
      await _cacheSites(_dataList((await _client.get('/sites')).data));
      lastReadUsedCache = false;
    } on NetworkFailure {
      lastReadUsedCache = true;
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

  Future<List<RegistryPerson>> people() async {
    try {
      await _cachePeople(_dataList((await _client.get('/people')).data));
      lastReadUsedCache = false;
    } on NetworkFailure {
      lastReadUsedCache = true;
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

  Future<RegistryCompany> createCompany({
    required String name,
    String? document,
  }) async {
    final json = _object(
      (await _client.post(
        '/companies',
        data: {'name': name, 'document': _nullIfBlank(document)},
        headers: _idempotencyHeaders(),
      )).data,
    );
    final company = RegistryCompany(
      id: json['id']!.toString(),
      name: json['name']!.toString(),
    );
    await _db
        .into(_db.localCompanies)
        .insertOnConflictUpdate(
          LocalCompaniesCompanion.insert(id: company.id, name: company.name),
        );
    return company;
  }

  Future<RegistrySite> createSite({
    required String companyId,
    required String name,
  }) async {
    final json = _object(
      (await _client.post(
        '/sites',
        data: {'companyId': companyId, 'name': name},
        headers: _idempotencyHeaders(),
      )).data,
    );
    final site = RegistrySite(
      id: json['id']!.toString(),
      companyId: json['companyId']!.toString(),
      name: json['name']!.toString(),
    );
    await _db
        .into(_db.localSites)
        .insertOnConflictUpdate(
          LocalSitesCompanion.insert(
            id: site.id,
            companyId: site.companyId,
            name: site.name,
          ),
        );
    return site;
  }

  Future<RegistryPerson> createPerson({
    required String name,
    required String kind,
    String? driverLicenseNumber,
    String? driverLicenseExpiryDate,
  }) async {
    final json = _object(
      (await _client.post(
        '/people',
        data: {
          'name': name,
          'kind': kind,
          'driverLicenseNumber': _nullIfBlank(driverLicenseNumber),
          'driverLicenseExpiryDate': _nullIfBlank(driverLicenseExpiryDate),
        },
        headers: _idempotencyHeaders(),
      )).data,
    );
    final person = _personFromJson(json);
    await _db
        .into(_db.localPeople)
        .insertOnConflictUpdate(
          LocalPeopleCompanion.insert(
            id: person.id,
            name: person.name,
            kind: person.kind,
            driverLicenseNumber: Value(person.driverLicenseNumber),
            driverLicenseExpiryDate: Value(person.driverLicenseExpiryDate),
          ),
        );
    return person;
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
    final json = _object(
      (await _client.post(
        '/assets',
        data: {
          'companyId': companyId,
          'siteId': siteId,
          'kind': kind,
          'code': code,
          'licensePlate': _nullIfBlank(licensePlate),
          'makeModel': kind == 'VEHICLE' ? description : null,
          'manufacturer': kind == 'EQUIPMENT' ? description : null,
          'manufactureYear': null,
          'predominantColor': null,
          'ownershipType': ownershipType,
        },
        headers: _idempotencyHeaders(),
      )).data,
    );
    final id = json['id']!.toString();
    await _client.post(
      '/assets/$id/templates',
      data: {
        'templateId': template.templateId,
        'operationConfigId': template.operationConfigId,
      },
      headers: _idempotencyHeaders(),
    );
    return AssetSummary(
      id: id,
      kind: json['kind']!.toString(),
      code: json['code']!.toString(),
      active: json['active'] as bool? ?? true,
      siteId: json['siteId']?.toString(),
      licensePlate: json['licensePlate']?.toString(),
      makeModel: json['makeModel']?.toString(),
      manufacturer: json['manufacturer']?.toString(),
      ownershipType: json['ownershipType']?.toString() ?? 'OWN',
    );
  }

  Future<void> assignTemplate({
    required String assetId,
    required TemplateChoice template,
  }) async {
    await _client.post(
      '/assets/$assetId/templates',
      data: {
        'templateId': template.templateId,
        'operationConfigId': template.operationConfigId,
      },
      headers: _idempotencyHeaders(),
    );
  }

  Map<String, Object?> _idempotencyHeaders() => {'Idempotency-Key': _uuid.v4()};

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
      await _db
          .update(_db.localCompanies)
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
      await _db
          .update(_db.localSites)
          .write(const LocalSitesCompanion(active: Value(false)));
      for (final item in data.where((item) => item['active'] != false)) {
        await _db
            .into(_db.localSites)
            .insertOnConflictUpdate(
              LocalSitesCompanion.insert(
                id: item['id']!.toString(),
                companyId: item['companyId']!.toString(),
                name: item['name']!.toString(),
                active: const Value(true),
              ),
            );
      }
    });
  }

  Future<void> _cachePeople(List<Map<String, Object?>> data) async {
    await _db.transaction(() async {
      await _db
          .update(_db.localPeople)
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
