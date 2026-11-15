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
  test('sincroniza uma data concluída mantendo a outra em rascunho e não duplica',
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
    expect(await database.select(database.syncOutboxOperations).get(), isEmpty);

    await coordinator.syncNow();
    expect(remote.pushCalls, 1, reason: 'outbox vazia não deve reenviar');
  });

  test('falha preserva operação e nova tentativa reutiliza operationId', () async {
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
    final afterFailure = await database.select(database.syncOutboxOperations).get();
    expect(afterFailure, isNotEmpty);
    final idsBeforeRetry = afterFailure.map((item) => item.operationId).toSet();

    remote.failPush = false;
    await coordinator.syncNow();
    expect(remote.pushCalls, 2);
    expect(remote.receivedBatches.last, containsAll(idsBeforeRetry));
    expect(await database.select(database.syncOutboxOperations).get(), isEmpty);
  });

  test('sessão expirada preserva a outbox e permite retomar com os mesmos IDs',
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
    final preserved = await database.select(database.syncOutboxOperations).get();
    final operationIds = preserved.map((item) => item.operationId).toSet();
    expect(preserved, isNotEmpty);
    expect(
      coordinator.snapshot.value.state,
      SyncRunState.sessionExpired,
    );

    remote.expireSession = false;
    await coordinator.syncNow();
    expect(remote.pushCalls, 2);
    expect(remote.receivedBatches.last, containsAll(operationIds));
    expect(await database.select(database.syncOutboxOperations).get(), isEmpty);
  });

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
}

final class _FakeSyncRemote implements SyncRemote {
  bool failPush = false;
  bool expireSession = false;
  String? conflictEntityId;
  int pushCalls = 0;
  final List<Set<String>> receivedBatches = [];

  @override
  Future<Map<String, Object?>> push({
    required String deviceId,
    required List<SyncOperationDto> operations,
  }) async {
    pushCalls++;
    receivedBatches.add(operations.map((item) => item.operationId).toSet());
    if (failPush) {
      throw const NetworkFailure('Falha simulada; dados preservados.');
    }
    if (expireSession) throw const SessionExpiredFailure();
    return {
      'serverTime': DateTime.now().toUtc().toIso8601String(),
      'results': [
        for (final operation in operations)
          if (operation.entityId == conflictEntityId)
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
  }) async =>
      {
        'serverTime': DateTime.now().toUtc().toIso8601String(),
        'nextCursor': cursor,
        'hasMore': false,
        'changes': <Object?>[],
        'tombstones': <Object?>[],
      };
}

final class _FakeChecklistRemote implements ChecklistRemote {
  @override
  Future<Map<String, Object?>> bootstrap({String? sinceCursor}) async =>
      throw UnimplementedError();

  @override
  Future<Map<String, Object?>> me() async => throw UnimplementedError();
}

final class _FakeDeviceId implements DeviceIdProvider {
  @override
  Future<String> get id async => 'flutter-test-device';
}
