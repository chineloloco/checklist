import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/time/week.dart';
import '../domain/checklist_models.dart';
import '../domain/checklist_repository.dart';
import 'local/app_database.dart';

final class DriftChecklistRepository implements ChecklistRepository {
  DriftChecklistRepository(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  @override
  Future<void> applyBootstrap(Map<String, Object?> payload) async {
    final versions = _objectList(payload['templateVersions']);
    final assets = _objectList(payload['assets']);
    final configs = _objectList(payload['operationConfigs']);
    final tombstones = _objectList(payload['tombstones']);
    final cursor = payload['cursor']?.toString() ?? '0';

    await _db.transaction(() async {
      for (final version in versions) {
        final versionId = version['id']!.toString();
        await _db.into(_db.localTemplateVersions).insertOnConflictUpdate(
              LocalTemplateVersionsCompanion.insert(
                id: versionId,
                templateId: version['templateId']!.toString(),
                versionNumber: _asInt(version['versionNumber'], fallback: 1),
                status: version['status']?.toString() ?? 'PUBLISHED',
                revision: _asInt(version['revision'], fallback: 1),
                checksum: Value(version['checksum']?.toString()),
                publishedAt: Value(_asDateTime(version['publishedAt'])),
                rawJson: jsonEncode(version),
              ),
            );

        for (final section in _objectList(version['sections'])) {
          final sectionId = section['id']!.toString();
          await _db.into(_db.localTemplateSections).insertOnConflictUpdate(
                LocalTemplateSectionsCompanion.insert(
                  id: sectionId,
                  templateVersionId: versionId,
                  title: section['title']?.toString() ?? 'Itens gerais',
                  sortOrder: _asInt(section['order']),
                ),
              );
          for (final item in _objectList(section['items'])) {
            await _db.into(_db.localTemplateItems).insertOnConflictUpdate(
                  LocalTemplateItemsCompanion.insert(
                    id: item['id']!.toString(),
                    templateVersionId: versionId,
                    sectionId: sectionId,
                    sourcePrintedNumber:
                        Value(item['sourcePrintedNumber']?.toString()),
                    textValue: item['text']?.toString() ?? '',
                    sortOrder: _asInt(item['order']),
                    requiredOnComplete:
                        Value(item['requiredOnComplete'] as bool? ?? true),
                    requireObservationWhenNc: Value(
                      item['requireObservationWhenNc'] as bool? ?? false,
                    ),
                    requirePhotoWhenNc:
                        Value(item['requirePhotoWhenNc'] as bool? ?? false),
                  ),
                );
          }
        }
      }

      for (final asset in assets) {
        await _db.into(_db.localAssets).insertOnConflictUpdate(
              LocalAssetsCompanion.insert(
                id: asset['id']!.toString(),
                kind: asset['kind']?.toString() ?? 'VEHICLE',
                code: asset['code']?.toString() ?? '',
                active: asset['active'] as bool? ?? true,
                revision: _asInt(asset['revision'], fallback: 1),
                siteId: Value(asset['siteId']?.toString()),
                licensePlate: Value(asset['licensePlate']?.toString()),
                makeModel: Value(asset['makeModel']?.toString()),
                manufacturer: Value(asset['manufacturer']?.toString()),
                manufactureYear: Value(_asNullableInt(asset['manufactureYear'])),
                predominantColor:
                    Value(asset['predominantColor']?.toString()),
                ownershipType:
                    Value(asset['ownershipType']?.toString() ?? 'OWN'),
                rawJson: jsonEncode(asset),
              ),
            );
      }

      for (final config in configs) {
        await _db.into(_db.localOperationConfigs).insertOnConflictUpdate(
              LocalOperationConfigsCompanion.insert(
                id: config['id']!.toString(),
                templateId: config['templateId']!.toString(),
                timezone: config['timezone']?.toString() ?? 'America/Fortaleza',
                weekStartsOn: config['weekStartsOn']?.toString() ?? 'MONDAY',
                requiredWeekdaysJson:
                    jsonEncode(config['requiredWeekdays'] as Object? ?? const []),
                maxOccurrencesPerDate:
                    _asInt(config['maxOccurrencesPerDate'], fallback: 1),
                rawJson: jsonEncode(config),
              ),
            );
      }

      for (final tombstone in tombstones) {
        if (tombstone['entityType'] == 'ASSET') {
          await (_db.update(_db.localAssets)
                ..where((table) =>
                    table.id.equals(tombstone['entityId']!.toString())))
              .write(const LocalAssetsCompanion(active: Value(false)));
        }
      }

      await _db.into(_db.localSyncMetadata).insertOnConflictUpdate(
            LocalSyncMetadataCompanion.insert(
              key: 'pull_cursor',
              value: cursor,
              updatedAt: DateTime.now().toUtc(),
            ),
          );
      await _db.into(_db.localSyncMetadata).insertOnConflictUpdate(
            LocalSyncMetadataCompanion.insert(
              key: 'last_bootstrap_at',
              value: DateTime.now().toUtc().toIso8601String(),
              updatedAt: DateTime.now().toUtc(),
            ),
          );
    });
  }

  @override
  Future<List<AssetSummary>> listAssets() async {
    final rows = await (_db.select(_db.localAssets)
          ..where((table) => table.active.equals(true))
          ..orderBy([(table) => OrderingTerm.asc(table.code)]))
        .get();
    return rows.map(_assetFromRow).toList(growable: false);
  }

  @override
  Future<List<TemplateChoice>> listTemplateChoices(String assetId) async {
    final configs = await _db.select(_db.localOperationConfigs).get();
    final versions = await (_db.select(_db.localTemplateVersions)
          ..where((table) => table.status.equals('PUBLISHED'))
          ..orderBy([(table) => OrderingTerm.desc(table.versionNumber)]))
        .get();

    final choices = <TemplateChoice>[];
    for (final config in configs) {
      LocalTemplateVersion? selected;
      for (final version in versions) {
        if (version.templateId == config.templateId) {
          selected = version;
          break;
        }
      }
      if (selected != null) {
        choices.add(
          TemplateChoice(
            templateId: selected.templateId,
            templateVersionId: selected.id,
            operationConfigId: config.id,
            versionNumber: selected.versionNumber,
            timezone: config.timezone,
            maxOccurrencesPerDate: config.maxOccurrencesPerDate,
          ),
        );
      }
    }
    return choices;
  }

  @override
  Stream<List<WeeklyChecklistCard>> watchWeeklyChecklists() => _db
      .customSelect(
        'SELECT 1 AS changed',
        readsFrom: {
          _db.localWeeklyChecklists,
          _db.localInspections,
          _db.localInspectionResponses,
          _db.localAssets,
        },
      )
      .watch()
      .asyncMap((_) => _loadWeeklyCards());

  Future<List<WeeklyChecklistCard>> _loadWeeklyCards() async {
    final weeks = await (_db.select(_db.localWeeklyChecklists)
          ..orderBy([(table) => OrderingTerm.desc(table.weekStartDate)]))
        .get();
    final result = <WeeklyChecklistCard>[];
    for (final week in weeks) {
      final asset = await (_db.select(_db.localAssets)
            ..where((table) => table.id.equals(week.assetId)))
          .getSingle();
      final version = await (_db.select(_db.localTemplateVersions)
            ..where((table) => table.id.equals(week.templateVersionId)))
          .getSingle();
      result.add(
        WeeklyChecklistCard(
          id: week.id,
          asset: _assetFromRow(asset),
          weekStartDate: parseIsoDate(week.weekStartDate),
          templateVersionNumber: version.versionNumber,
          syncState: LocalSyncStateX.fromCode(week.syncState),
          inspections: await _inspectionSummaries(week.id),
        ),
      );
    }
    return result;
  }

  @override
  Future<WeeklyChecklistDetail> getWeeklyChecklist(String id) async {
    final week = await (_db.select(_db.localWeeklyChecklists)
          ..where((table) => table.id.equals(id)))
        .getSingle();
    final asset = await (_db.select(_db.localAssets)
          ..where((table) => table.id.equals(week.assetId)))
        .getSingle();
    final version = await (_db.select(_db.localTemplateVersions)
          ..where((table) => table.id.equals(week.templateVersionId)))
        .getSingle();
    return WeeklyChecklistDetail(
      id: id,
      asset: _assetFromRow(asset),
      weekStartDate: parseIsoDate(week.weekStartDate),
      timezone: week.timezone,
      templateVersionNumber: version.versionNumber,
      inspections: await _inspectionSummaries(id),
    );
  }

  @override
  Future<String> openWeeklyChecklist({
    required String assetId,
    required TemplateChoice template,
    required DateTime localDate,
  }) async {
    final weekStart = isoDate(startOfMondayWeek(localDate));
    final existing = await (_db.select(_db.localWeeklyChecklists)
          ..where((table) =>
              table.assetId.equals(assetId) &
              table.templateId.equals(template.templateId) &
              table.weekStartDate.equals(weekStart)))
        .getSingleOrNull();
    if (existing != null) return existing.id;

    final id = _uuid.v7();
    final operationId = _uuid.v7();
    final now = DateTime.now().toUtc();
    final payload = <String, Object?>{
      'clientWeeklyChecklistId': id,
      'assetId': assetId,
      'templateId': template.templateId,
      'localDate': isoDate(localDate),
    };
    await _db.transaction(() async {
      await _db.into(_db.localWeeklyChecklists).insert(
            LocalWeeklyChecklistsCompanion.insert(
              id: id,
              assetId: assetId,
              templateId: template.templateId,
              templateVersionId: template.templateVersionId,
              operationConfigId: template.operationConfigId,
              weekStartDate: weekStart,
              timezone: template.timezone,
              syncState: const Value('QUEUED'),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _db.into(_db.syncOutboxOperations).insert(
            SyncOutboxOperationsCompanion.insert(
              operationId: operationId,
              entityType: 'WEEKLY_CHECKLIST',
              mutation: 'UPSERT',
              entityId: id,
              clientOccurredAt: now,
              payloadJson: jsonEncode(payload),
            ),
          );
    });
    return id;
  }

  @override
  Future<String> openInspection({
    required String weeklyChecklistId,
    required DateTime localDate,
    required IdentificationSnapshot identification,
    int occurrenceNo = 1,
  }) async {
    final week = await (_db.select(_db.localWeeklyChecklists)
          ..where((table) => table.id.equals(weeklyChecklistId)))
        .getSingle();
    if (!belongsToWeek(localDate, parseIsoDate(week.weekStartDate))) {
      throw const ValidationFailure(
        'A data da inspeção precisa pertencer à semana aberta.',
      );
    }
    final date = isoDate(localDate);
    final existing = await (_db.select(_db.localInspections)
          ..where((table) =>
              table.weeklyChecklistId.equals(weeklyChecklistId) &
              table.localDate.equals(date) &
              table.occurrenceNo.equals(occurrenceNo)))
        .getSingleOrNull();
    if (existing != null) return existing.id;

    _validateIdentification(identification);
    final items = await (_db.select(_db.localTemplateItems)
          ..where((table) =>
              table.templateVersionId.equals(week.templateVersionId)))
        .get();
    if (items.isEmpty) {
      throw const ValidationFailure(
        'A versão fixada não possui itens baixados. Sincronize novamente.',
      );
    }

    final id = _uuid.v7();
    final now = DateTime.now().toUtc();
    await _db.transaction(() async {
      await _db.into(_db.localInspections).insert(
            LocalInspectionsCompanion.insert(
              id: id,
              weeklyChecklistId: weeklyChecklistId,
              localDate: date,
              occurrenceNo: Value(occurrenceNo),
              identificationJson: jsonEncode(identification.toJson()),
              syncState: const Value('QUEUED'),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _db.batch((batch) {
        batch.insertAll(
          _db.localInspectionResponses,
          items
              .map(
                (item) => LocalInspectionResponsesCompanion.insert(
                  inspectionId: id,
                  itemId: item.id,
                  updatedAt: now,
                ),
              )
              .toList(growable: false),
        );
      });
      await _queueInspection(id, mutation: 'UPSERT');
    });
    return id;
  }

  @override
  Future<InspectionDraft> getInspection(String inspectionId) async =>
      _hydrateInspection(inspectionId);

  @override
  Stream<InspectionDraft> watchInspection(String inspectionId) => _db
      .customSelect(
        'SELECT 1 AS changed',
        readsFrom: {
          _db.localInspections,
          _db.localInspectionResponses,
          _db.localTemplateItems,
        },
      )
      .watch()
      .asyncMap((_) => _hydrateInspection(inspectionId));

  @override
  Future<void> saveAnswer({
    required String inspectionId,
    required String itemId,
    required InspectionResult? result,
    String? observation,
  }) async {
    final inspection = await (_db.select(_db.localInspections)
          ..where((table) => table.id.equals(inspectionId)))
        .getSingle();
    if (inspection.lifecycleStatus != 'DRAFT') {
      throw const ValidationFailure(
        'Uma inspeção concluída não pode ser alterada no aplicativo.',
      );
    }
    final now = DateTime.now().toUtc();
    await _db.transaction(() async {
      await (_db.update(_db.localInspectionResponses)
            ..where((table) =>
                table.inspectionId.equals(inspectionId) &
                table.itemId.equals(itemId)))
          .write(
        LocalInspectionResponsesCompanion(
          result: Value(result?.code),
          observation: Value(observation?.trim().isEmpty == true
              ? null
              : observation?.trim()),
          updatedAt: Value(now),
        ),
      );
      await _markInspectionChanged(inspectionId, now);
      await _queueInspection(inspectionId, mutation: 'UPSERT');
    });
  }

  @override
  Future<void> saveInspectionNotes({
    required String inspectionId,
    required String? observations,
  }) async {
    final now = DateTime.now().toUtc();
    await _db.transaction(() async {
      await (_db.update(_db.localInspections)
            ..where((table) => table.id.equals(inspectionId)))
          .write(
        LocalInspectionsCompanion(
          observations: Value(
            observations?.trim().isEmpty == true ? null : observations?.trim(),
          ),
          syncState: const Value('QUEUED'),
          lastError: const Value(null),
          updatedAt: Value(now),
        ),
      );
      await _queueInspection(inspectionId, mutation: 'UPSERT');
    });
  }

  @override
  Future<void> saveIdentification({
    required String inspectionId,
    required IdentificationSnapshot identification,
  }) async {
    _validateIdentification(identification);
    final now = DateTime.now().toUtc();
    await _db.transaction(() async {
      await (_db.update(_db.localInspections)
            ..where((table) => table.id.equals(inspectionId)))
          .write(
        LocalInspectionsCompanion(
          identificationJson: Value(jsonEncode(identification.toJson())),
          syncState: const Value('QUEUED'),
          lastError: const Value(null),
          updatedAt: Value(now),
        ),
      );
      await _queueInspection(inspectionId, mutation: 'UPSERT');
    });
  }

  @override
  Future<void> completeInspection(String inspectionId) async {
    final draft = await _hydrateInspection(inspectionId);
    final missing = draft.items
        .where((item) => item.requiredOnComplete && item.result == null)
        .toList(growable: false);
    if (missing.isNotEmpty) {
      throw ValidationFailure(
        'Responda os ${missing.length} itens obrigatórios antes de concluir.',
        fields: {
          for (final item in missing) '/responses/${item.id}/result': 'Obrigatório',
        },
      );
    }
    final missingObservations = draft.items.where(
      (item) =>
          item.result == InspectionResult.nonCompliant &&
          item.requireObservationWhenNc &&
          (item.observation?.trim().isEmpty ?? true),
    );
    if (missingObservations.isNotEmpty) {
      throw const ValidationFailure(
        'Inclua a observação exigida nos itens não conformes.',
      );
    }
    if (draft.items.any(
      (item) =>
          item.result == InspectionResult.nonCompliant &&
          item.requirePhotoWhenNc,
    )) {
      throw const ConfigurationFailure(
        'O modelo exige foto, mas o contrato de upload ainda não foi definido.',
      );
    }
    final now = DateTime.now().toUtc();
    await _db.transaction(() async {
      await (_db.update(_db.localInspections)
            ..where((table) => table.id.equals(inspectionId)))
          .write(
        LocalInspectionsCompanion(
          lifecycleStatus: const Value('COMPLETED'),
          syncState: const Value('QUEUED'),
          lastError: const Value(null),
          updatedAt: Value(now),
        ),
      );
      await _queueInspection(inspectionId, mutation: 'COMPLETE');
    });
  }

  Future<InspectionDraft> _hydrateInspection(String inspectionId) async {
    final inspection = await (_db.select(_db.localInspections)
          ..where((table) => table.id.equals(inspectionId)))
        .getSingle();
    final week = await (_db.select(_db.localWeeklyChecklists)
          ..where((table) => table.id.equals(inspection.weeklyChecklistId)))
        .getSingle();
    final version = await (_db.select(_db.localTemplateVersions)
          ..where((table) => table.id.equals(week.templateVersionId)))
        .getSingle();
    final itemRows = await (_db.select(_db.localTemplateItems)
          ..where((table) =>
              table.templateVersionId.equals(week.templateVersionId))
          ..orderBy([(table) => OrderingTerm.asc(table.sortOrder)]))
        .get();
    final sectionRows = await _db.select(_db.localTemplateSections).get();
    final sections = {for (final row in sectionRows) row.id: row.title};
    final responseRows = await (_db.select(_db.localInspectionResponses)
          ..where((table) => table.inspectionId.equals(inspectionId)))
        .get();
    final responses = {for (final row in responseRows) row.itemId: row};
    final items = itemRows
        .map((item) {
          final response = responses[item.id];
          return ChecklistItem(
            id: item.id,
            sectionId: item.sectionId,
            sectionTitle: sections[item.sectionId] ?? 'Itens gerais',
            text: item.textValue,
            order: item.sortOrder,
            requiredOnComplete: item.requiredOnComplete,
            requireObservationWhenNc: item.requireObservationWhenNc,
            requirePhotoWhenNc: item.requirePhotoWhenNc,
            sourcePrintedNumber: item.sourcePrintedNumber,
            result: InspectionResultX.fromCode(response?.result),
            observation: response?.observation,
          );
        })
        .toList(growable: false);
    return InspectionDraft(
      id: inspection.id,
      weeklyChecklistId: inspection.weeklyChecklistId,
      localDate: parseIsoDate(inspection.localDate),
      occurrenceNo: inspection.occurrenceNo,
      lifecycle: InspectionLifecycleX.fromCode(inspection.lifecycleStatus),
      syncState: LocalSyncStateX.fromCode(inspection.syncState),
      identification: IdentificationSnapshot.fromJson(
        (jsonDecode(inspection.identificationJson) as Map).cast<String, Object?>(),
      ),
      items: items,
      templateVersionNumber: version.versionNumber,
      observations: inspection.observations,
      revision: inspection.revision,
      lastError: inspection.lastError,
      conflictId: inspection.conflictId,
    );
  }

  Future<List<InspectionSummary>> _inspectionSummaries(String weekId) async {
    final inspections = await (_db.select(_db.localInspections)
          ..where((table) => table.weeklyChecklistId.equals(weekId))
          ..orderBy([
            (table) => OrderingTerm.asc(table.localDate),
            (table) => OrderingTerm.asc(table.occurrenceNo),
          ]))
        .get();
    final result = <InspectionSummary>[];
    for (final inspection in inspections) {
      final responses = await (_db.select(_db.localInspectionResponses)
            ..where((table) => table.inspectionId.equals(inspection.id)))
          .get();
      result.add(
        InspectionSummary(
          id: inspection.id,
          localDate: parseIsoDate(inspection.localDate),
          occurrenceNo: inspection.occurrenceNo,
          lifecycle:
              InspectionLifecycleX.fromCode(inspection.lifecycleStatus),
          syncState: LocalSyncStateX.fromCode(inspection.syncState),
          answeredCount: responses.where((row) => row.result != null).length,
          totalCount: responses.length,
          lastError: inspection.lastError,
          conflictId: inspection.conflictId,
        ),
      );
    }
    return result;
  }

  Future<void> _markInspectionChanged(String inspectionId, DateTime now) async {
    await (_db.update(_db.localInspections)
          ..where((table) => table.id.equals(inspectionId)))
        .write(
      LocalInspectionsCompanion(
        syncState: const Value('QUEUED'),
        lastError: const Value(null),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> _queueInspection(
    String inspectionId, {
    required String mutation,
  }) async {
    final inspection = await (_db.select(_db.localInspections)
          ..where((table) => table.id.equals(inspectionId)))
        .getSingle();
    final responses = await (_db.select(_db.localInspectionResponses)
          ..where((table) => table.inspectionId.equals(inspectionId)))
        .get();
    final payload = <String, Object?>{
      'weeklyChecklistId': inspection.weeklyChecklistId,
      'localDate': inspection.localDate,
      'occurrenceNo': inspection.occurrenceNo,
      'lifecycleStatus': inspection.lifecycleStatus,
      'identification': jsonDecode(inspection.identificationJson),
      'observations': inspection.observations,
      'responses': [
        for (final response in responses)
          {
            'itemId': response.itemId,
            'result': response.result,
            'observation': response.observation,
          },
      ],
    };
    final pending = await (_db.select(_db.syncOutboxOperations)
          ..where((table) =>
              table.entityId.equals(inspectionId) &
              table.state.equals('QUEUED'))
          ..limit(1))
        .getSingleOrNull();
    final now = DateTime.now().toUtc();
    if (pending != null) {
      await (_db.update(_db.syncOutboxOperations)
            ..where((table) => table.operationId.equals(pending.operationId)))
          .write(
        SyncOutboxOperationsCompanion(
          mutation: Value(mutation),
          baseRevision: Value(inspection.revision),
          clientOccurredAt: Value(now),
          payloadJson: Value(jsonEncode(payload)),
          lastError: const Value(null),
        ),
      );
      return;
    }
    await _db.into(_db.syncOutboxOperations).insert(
          SyncOutboxOperationsCompanion.insert(
            operationId: _uuid.v7(),
            entityType: 'INSPECTION',
            mutation: mutation,
            entityId: inspectionId,
            baseRevision: Value(inspection.revision),
            clientOccurredAt: now,
            payloadJson: jsonEncode(payload),
          ),
        );
  }

  void _validateIdentification(IdentificationSnapshot value) {
    final fields = <String, String>{};
    if (value.company.trim().isEmpty) fields['company'] = 'Informe a empresa.';
    if (value.site.trim().isEmpty) fields['site'] = 'Informe o local.';
    if (value.assetCode.trim().isEmpty) {
      fields['assetCode'] = 'Informe o código do ativo.';
    }
    if (value.responsiblePersonName.trim().isEmpty) {
      fields['responsiblePersonName'] = 'Informe o motorista ou operador.';
    }
    if (fields.isNotEmpty) {
      throw ValidationFailure('Confira os dados de identificação.', fields: fields);
    }
  }

  AssetSummary _assetFromRow(LocalAsset row) => AssetSummary(
        id: row.id,
        kind: row.kind,
        code: row.code,
        active: row.active,
        siteId: row.siteId,
        licensePlate: row.licensePlate,
        makeModel: row.makeModel,
        manufacturer: row.manufacturer,
        manufactureYear: row.manufactureYear,
        predominantColor: row.predominantColor,
        ownershipType: row.ownershipType,
      );

  static List<Map<String, Object?>> _objectList(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => item.cast<String, Object?>())
        .toList(growable: false);
  }

  static int _asInt(Object? value, {int fallback = 0}) => switch (value) {
        int number => number,
        num number => number.toInt(),
        String text => int.tryParse(text) ?? fallback,
        _ => fallback,
      };

  static int? _asNullableInt(Object? value) => switch (value) {
        int number => number,
        num number => number.toInt(),
        String text => int.tryParse(text),
        _ => null,
      };

  static DateTime? _asDateTime(Object? value) => value == null
      ? null
      : DateTime.tryParse(value.toString())?.toUtc();
}
