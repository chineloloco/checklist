import 'package:checklist_mobile/core/errors/app_failure.dart';
import 'package:checklist_mobile/features/checklists/data/drift_checklist_repository.dart';
import 'package:checklist_mobile/features/checklists/data/local/app_database.dart';
import 'package:checklist_mobile/features/checklists/data/remote/checklist_api.dart';
import 'package:checklist_mobile/features/checklists/domain/checklist_models.dart';
import 'package:checklist_mobile/features/sync/application/sync_coordinator.dart';
import 'package:checklist_mobile/features/sync/data/device_identity.dart';
import 'package:checklist_mobile/features/sync/data/sync_api.dart';
import 'package:checklist_mobile/features/sync/domain/sync_models.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_fixture.dart';

void main() {
  test('serializa clientOccurredAt como ISO 8601 UTC', () {
    final operation = SyncOperationDto(
      operationId: '00000000-0000-4000-8000-000000000001',
      entityType: 'INSPECTION',
      mutation: 'UPSERT',
      entityId: '00000000-0000-4000-8000-000000000002',
      clientOccurredAt: DateTime(2026, 11, 15, 15, 30),
      payload: const {},
    );

    final serialized = operation.toJson()['clientOccurredAt'] as String;

    expect(serialized, endsWith('Z'));
    expect(DateTime.parse(serialized).isUtc, isTrue);
  });

  test(
    'sincroniza uma data concluída mantendo a outra em rascunho e não duplica',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftChecklistRepository(database);
      final ids = await createTwoDates(database, repository);
      final first = await repository.getInspection(ids.firstId);
      for (final item in first.items) {
        await repository.saveAnswer(
          inspectionId: first.id,
          itemId: item.id,
          result: InspectionResult.compliant,
        );
      }
      await repository.completeInspection(first.id);

      final remote = _FakeSyncRemote();
      final coordinator = SyncCoordinator(
        database: database,
        syncApi: remote,
        checklistApi: _FakeChecklistRemote(),
        checklistRepository: repository,
        deviceIdentity: _FakeDeviceId(),
      );
      addTearDown(coordinator.dispose);

      await coordinator.syncNow();
      final completed = await repository.getInspection(ids.firstId);
      final draft = await repository.getInspection(ids.secondId);
      expect(completed.lifecycle, InspectionLifecycle.completed);
      expect(completed.syncState, LocalSyncState.synced);
      expect(draft.lifecycle, InspectionLifecycle.draft);
      expect(draft.syncState, LocalSyncState.synced);
      expect(
        await database.select(database.syncOutboxOperations).get(),
        isEmpty,
      );

      final pushesAfterFirstSync = remote.pushCalls;
      await coordinator.syncNow();
      expect(
        remote.pushCalls,
        pushesAfterFirstSync,
        reason: 'outbox vazia não deve reenviar',
      );
    },
  );

  test(
    'falha preserva operação e nova tentativa reutiliza operationId',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftChecklistRepository(database);
      await createTwoDates(database, repository);
      final remote = _FakeSyncRemote()..failPush = true;
      final coordinator = SyncCoordinator(
        database: database,
        syncApi: remote,
        checklistApi: _FakeChecklistRemote(),
        checklistRepository: repository,
        deviceIdentity: _FakeDeviceId(),
      );
      addTearDown(coordinator.dispose);

      await coordinator.syncNow();
      final afterFailure = await database
          .select(database.syncOutboxOperations)
          .get();
      expect(afterFailure, isNotEmpty);
      final idsBeforeRetry = afterFailure
          .map((item) => item.operationId)
          .toSet();

      remote.failPush = false;
      await coordinator.syncNow();
      expect(remote.pushCalls, greaterThan(1));
      expect(
        remote.receivedBatches.skip(1).expand((batch) => batch).toSet(),
        containsAll(idsBeforeRetry),
      );
      expect(
        await database.select(database.syncOutboxOperations).get(),
        isEmpty,
      );
    },
  );

  test(
    'sessão expirada preserva a outbox e permite retomar com os mesmos IDs',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftChecklistRepository(database);
      await createTwoDates(database, repository);
      final remote = _FakeSyncRemote()..expireSession = true;
      final coordinator = SyncCoordinator(
        database: database,
        syncApi: remote,
        checklistApi: _FakeChecklistRemote(),
        checklistRepository: repository,
        deviceIdentity: _FakeDeviceId(),
      );
      addTearDown(coordinator.dispose);

      await coordinator.syncNow();
      final preserved = await database
          .select(database.syncOutboxOperations)
          .get();
      final operationIds = preserved.map((item) => item.operationId).toSet();
      expect(preserved, isNotEmpty);
      expect(coordinator.snapshot.value.state, SyncRunState.sessionExpired);

      remote.expireSession = false;
      await coordinator.syncNow();
      expect(remote.pushCalls, greaterThan(1));
      expect(
        remote.receivedBatches.skip(1).expand((batch) => batch).toSet(),
        containsAll(operationIds),
      );
      expect(
        await database.select(database.syncOutboxOperations).get(),
        isEmpty,
      );
    },
  );

  test('conflito preserva inspeção e bloqueia somente sua operação', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftChecklistRepository(database);
    final ids = await createTwoDates(database, repository);
    final remote = _FakeSyncRemote()..conflictEntityId = ids.secondId;
    final coordinator = SyncCoordinator(
      database: database,
      syncApi: remote,
      checklistApi: _FakeChecklistRemote(),
      checklistRepository: repository,
      deviceIdentity: _FakeDeviceId(),
    );
    addTearDown(coordinator.dispose);

    await coordinator.syncNow();
    final conflicted = await repository.getInspection(ids.secondId);
    final preserved = await repository.getInspection(ids.firstId);
    expect(conflicted.syncState, LocalSyncState.conflict);
    expect(conflicted.conflictId, 'conflict-test');
    expect(conflicted.items, hasLength(34));
    expect(preserved.syncState, LocalSyncState.synced);
    final blocked = await database.select(database.syncOutboxOperations).get();
    expect(blocked.single.entityId, ids.secondId);
    expect(blocked.single.state, 'BLOCKED');
  });

  test('mudança de modelo no pull baixa um novo manifesto', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftChecklistRepository(database);
    await seedVlBootstrap(repository);
    final remote = _FakeSyncRemote()
      ..pullChanges = [
        {
          'entityType': 'TEMPLATE_VERSION',
          'entityId': versionId,
          'revision': 2,
          'payload': {'status': 'PUBLISHED'},
        },
      ];
    final checklistRemote = _FakeChecklistRemote({
      'cursor': '11',
      'templateVersions': <Object?>[],
      'assets': <Object?>[],
      'operationConfigs': <Object?>[],
      'assetTemplateAssignments': <Object?>[],
      'tombstones': <Object?>[],
    });
    final coordinator = SyncCoordinator(
      database: database,
      syncApi: remote,
      checklistApi: checklistRemote,
      checklistRepository: repository,
      deviceIdentity: _FakeDeviceId(),
    );
    addTearDown(coordinator.dispose);

    await coordinator.syncNow();

    expect(checklistRemote.bootstrapCalls, 1);
    expect(await repository.listTemplateChoices(assetId), isEmpty);
  });

  test(
    'conclusão de rascunho já enviado usa COMPLETE com a revisão do servidor',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftChecklistRepository(database);
      final ids = await createTwoDates(database, repository);
      final remote = _FakeSyncRemote();
      final coordinator = SyncCoordinator(
        database: database,
        syncApi: remote,
        checklistApi: _FakeChecklistRemote(),
        checklistRepository: repository,
        deviceIdentity: _FakeDeviceId(),
      );
      addTearDown(coordinator.dispose);

      await coordinator.syncNow();
      final draft = await repository.getInspection(ids.firstId);
      expect(draft.revision, 1);
      for (final item in draft.items) {
        await repository.saveAnswer(
          inspectionId: draft.id,
          itemId: item.id,
          result: InspectionResult.compliant,
        );
      }
      await repository.completeInspection(draft.id);
      await coordinator.syncNow();

      final complete = remote.receivedOperations.last.singleWhere(
        (operation) => operation.entityId == ids.firstId,
      );
      expect(complete.mutation, 'COMPLETE');
      expect(complete.baseRevision, 1);
    },
  );

  test(
    'recria a semana quando o servidor não encontra o checklist semanal',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = DriftChecklistRepository(database);
      final ids = await createTwoDates(database, repository);
      await (database.delete(
        database.syncOutboxOperations,
      )..where((table) => table.entityType.equals('WEEKLY_CHECKLIST'))).go();
      final remote = _FakeSyncRemote()..rejectMissingWeeklyOnce = true;
      final coordinator = SyncCoordinator(
        database: database,
        syncApi: remote,
        checklistApi: _FakeChecklistRemote(),
        checklistRepository: repository,
        deviceIdentity: _FakeDeviceId(),
      );
      addTearDown(coordinator.dispose);

      await coordinator.syncNow();

      expect(
        remote.receivedOperations[1].every(
          (operation) => operation.entityType == 'WEEKLY_CHECKLIST',
        ),
        isTrue,
      );
      expect(
        await database.select(database.syncOutboxOperations).get(),
        isEmpty,
      );
      expect(
        (await repository.getInspection(ids.firstId)).syncState,
        LocalSyncState.synced,
      );
    },
  );

  test('interrompe o pull quando o cursor nao avanca', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftChecklistRepository(database);
    await seedVlBootstrap(repository);
    final remote = _FakeSyncRemote()..pullHasMore = true;
    final coordinator = SyncCoordinator(
      database: database,
      syncApi: remote,
      checklistApi: _FakeChecklistRemote(),
      checklistRepository: repository,
      deviceIdentity: _FakeDeviceId(),
    );
    addTearDown(coordinator.dispose);

    await coordinator.syncNow();

    expect(remote.pullCalls, 1);
    expect(coordinator.snapshot.value.state, SyncRunState.failed);
    expect(
      coordinator.snapshot.value.message,
      contains('sem avançar o cursor'),
    );
  });
}

final class _FakeSyncRemote implements SyncRemote {
  bool failPush = false;
  bool expireSession = false;
  String? conflictEntityId;
  int pushCalls = 0;
  int pullCalls = 0;
  bool pullHasMore = false;
  bool rejectMissingWeeklyOnce = false;
  List<Map<String, Object?>> pullChanges = const [];
  final List<Set<String>> receivedBatches = [];
  final List<List<SyncOperationDto>> receivedOperations = [];

  @override
  Future<Map<String, Object?>> push({
    required String deviceId,
    required List<SyncOperationDto> operations,
  }) async {
    pushCalls++;
    receivedBatches.add(operations.map((item) => item.operationId).toSet());
    receivedOperations.add(List.of(operations));
    if (failPush) {
      throw const NetworkFailure('Falha simulada; dados preservados.');
    }
    if (expireSession) throw const SessionExpiredFailure();
    final rejectMissingWeekly =
        rejectMissingWeeklyOnce &&
        operations.every(
          (operation) => operation.entityType != 'WEEKLY_CHECKLIST',
        );
    if (rejectMissingWeekly) rejectMissingWeeklyOnce = false;
    return {
      'serverTime': DateTime.now().toUtc().toIso8601String(),
      'results': [
        for (final operation in operations)
          if (rejectMissingWeekly && operation.entityType == 'INSPECTION')
            {
              'operationId': operation.operationId,
              'status': 'REJECTED',
              'entityId': operation.entityId,
              'serverRevision': null,
              'problem': {
                'code': 'NOT_FOUND',
                'detail': 'Checklist semanal não encontrado.',
              },
            }
          else if (operation.entityId == conflictEntityId)
            {
              'operationId': operation.operationId,
              'status': 'CONFLICT',
              'entityId': operation.entityId,
              'serverRevision': null,
              'problem': {
                'code': 'DUPLICATE_SLOT',
                'conflictId': 'conflict-test',
                'detail': 'Outro dispositivo registrou o mesmo slot.',
              },
            }
          else
            {
              'operationId': operation.operationId,
              'status': 'APPLIED',
              'entityId': operation.entityId,
              'serverRevision': 1,
              'problem': null,
            },
      ],
    };
  }

  @override
  Future<Map<String, Object?>> pull({
    required String cursor,
    int limit = 200,
  }) async {
    pullCalls++;
    return {
      'serverTime': DateTime.now().toUtc().toIso8601String(),
      'nextCursor': cursor,
      'hasMore': pullHasMore,
      'changes': pullChanges,
      'tombstones': <Object?>[],
    };
  }
}

final class _FakeChecklistRemote implements ChecklistRemote {
  _FakeChecklistRemote([this.payload]);

  final Map<String, Object?>? payload;
  int bootstrapCalls = 0;

  @override
  Future<Map<String, Object?>> bootstrap({String? sinceCursor}) async {
    bootstrapCalls++;
    return payload ?? (throw UnimplementedError());
  }

  @override
  Future<Map<String, Object?>> me() async => throw UnimplementedError();
}

final class _FakeDeviceId implements DeviceIdProvider {
  @override
  Future<String> get id async => 'flutter-test-device';
}
