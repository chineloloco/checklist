import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/app_failure.dart';
import '../../checklists/data/local/app_database.dart';
import '../../checklists/data/remote/checklist_api.dart';
import '../../checklists/domain/checklist_repository.dart';
import '../data/device_identity.dart';
import '../data/sync_api.dart';
import '../domain/sync_models.dart';

final class SyncCoordinator {
  SyncCoordinator({
    required AppDatabase database,
    required SyncRemote syncApi,
    required ChecklistRemote checklistApi,
    required ChecklistRepository checklistRepository,
    required DeviceIdProvider deviceIdentity,
    Connectivity? connectivity,
  })  : _db = database,
        _syncApi = syncApi,
        _checklistApi = checklistApi,
        _checklistRepository = checklistRepository,
        _deviceIdentity = deviceIdentity,
        _connectivity = connectivity ?? Connectivity();

  final AppDatabase _db;
  final SyncRemote _syncApi;
  final ChecklistRemote _checklistApi;
  final ChecklistRepository _checklistRepository;
  final DeviceIdProvider _deviceIdentity;
  final Connectivity _connectivity;

  final ValueNotifier<SyncSnapshot> snapshot =
      ValueNotifier(const SyncSnapshot.idle());
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _running = false;

  Future<void> initialize() async {
    await _publishIdleSnapshot();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        if (!results.contains(ConnectivityResult.none)) {
          unawaited(syncNow());
        } else {
          unawaited(_publishOfflineSnapshot());
        }
      },
    );
  }

  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    snapshot.dispose();
  }

  Future<void> syncNow() async {
    if (_running) return;
    _running = true;
    final pendingBefore = await _pendingCount();
    snapshot.value = SyncSnapshot(
      state: SyncRunState.running,
      pendingCount: pendingBefore,
      lastSyncedAt: await _lastSyncAt(),
      message: pendingBefore == 0 ? 'Verificando atualizações…' : 'Enviando dados salvos…',
    );

    try {
      await _requeueFailedOperations();
      await _pushPending();
      await _pullChanges();
      final now = DateTime.now().toUtc();
      await _putMetadata('last_sync_at', now.toIso8601String());
      snapshot.value = SyncSnapshot(
        state: SyncRunState.idle,
        pendingCount: await _pendingCount(),
        lastSyncedAt: now,
        message: 'Sincronização confirmada.',
      );
    } on SessionExpiredFailure catch (error) {
      await _resetSendingOperations();
      snapshot.value = SyncSnapshot(
        state: SyncRunState.sessionExpired,
        pendingCount: await _pendingCount(),
        lastSyncedAt: await _lastSyncAt(),
        message: error.message,
      );
    } on NetworkFailure catch (error) {
      await _resetSendingOperations();
      snapshot.value = SyncSnapshot(
        state: SyncRunState.offline,
        pendingCount: await _pendingCount(),
        lastSyncedAt: await _lastSyncAt(),
        message: error.message,
      );
    } on Object catch (error) {
      await _resetSendingOperations();
      snapshot.value = SyncSnapshot(
        state: SyncRunState.failed,
        pendingCount: await _pendingCount(),
        lastSyncedAt: await _lastSyncAt(),
        message: 'Falha ao sincronizar: $error',
      );
    } finally {
      _running = false;
    }
  }

  Future<void> bootstrap() async {
    final payload = await _checklistApi.bootstrap();
    await _checklistRepository.applyBootstrap(payload);
    await _putMetadata(
      'last_bootstrap_at',
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  Future<void> _pushPending() async {
    final rows = await (_db.select(_db.syncOutboxOperations)
          ..where((table) => table.state.equals('QUEUED'))
          ..orderBy([(table) => OrderingTerm.asc(table.clientOccurredAt)])
          ..limit(100))
        .get();
    if (rows.isEmpty) return;

    await _db.transaction(() async {
      for (final row in rows) {
        await (_db.update(_db.syncOutboxOperations)
              ..where((table) => table.operationId.equals(row.operationId)))
            .write(
          SyncOutboxOperationsCompanion(
            state: const Value('SENDING'),
            attemptCount: Value(row.attemptCount + 1),
            lastError: const Value(null),
          ),
        );
        await _writeEntitySyncState(row.entityType, row.entityId, 'SYNCING');
      }
    });

    final deviceId = await _deviceIdentity.id;
    final response = await _syncApi.push(
      deviceId: deviceId,
      operations: [
        for (final row in rows)
          SyncOperationDto(
            operationId: row.operationId,
            entityType: row.entityType,
            mutation: row.mutation,
            entityId: row.entityId,
            baseRevision: row.baseRevision,
            clientOccurredAt: row.clientOccurredAt,
            payload:
                (jsonDecode(row.payloadJson) as Map).cast<String, Object?>(),
          ),
      ],
    );
    final results = _objectList(response['results']);
    final byId = {for (final row in rows) row.operationId: row};
    final acknowledged = <String>{};

    await _db.transaction(() async {
      for (final result in results) {
        final operationId = result['operationId']?.toString();
        final row = byId[operationId];
        if (row == null) continue;
        acknowledged.add(row.operationId);
        final status = result['status']?.toString();
        final revision = _asNullableInt(result['serverRevision']);
        if (status == 'APPLIED' || status == 'ALREADY_APPLIED') {
          await (_db.delete(_db.syncOutboxOperations)
                ..where((table) => table.operationId.equals(row.operationId)))
              .go();
          await _writeEntityApplied(
            row.entityType,
            row.entityId,
            result['entityId']?.toString() ?? row.entityId,
            revision,
          );
          continue;
        }

        final problem = result['problem'] is Map
            ? (result['problem'] as Map).cast<String, Object?>()
            : const <String, Object?>{};
        final detail = problem['detail']?.toString() ??
            (status == 'CONFLICT'
                ? 'Outro dispositivo registrou o mesmo slot.'
                : 'A operação foi recusada pelo servidor.');
        final conflictId = problem['conflictId']?.toString();
        await (_db.update(_db.syncOutboxOperations)
              ..where((table) => table.operationId.equals(row.operationId)))
            .write(
          SyncOutboxOperationsCompanion(
            state: Value(status == 'CONFLICT' ? 'BLOCKED' : 'FAILED'),
            lastError: Value(detail),
          ),
        );
        await _writeEntityFailure(
          row.entityType,
          row.entityId,
          status == 'CONFLICT' ? 'CONFLICT' : 'ERROR',
          detail,
          conflictId,
        );
      }

      for (final row in rows) {
        if (acknowledged.contains(row.operationId)) continue;
        await (_db.update(_db.syncOutboxOperations)
              ..where((table) => table.operationId.equals(row.operationId)))
            .write(
          const SyncOutboxOperationsCompanion(
            state: Value('QUEUED'),
            lastError: Value(
              'O servidor não confirmou esta operação; o envio será repetido.',
            ),
          ),
        );
        await _writeEntitySyncState(row.entityType, row.entityId, 'QUEUED');
      }
    });

    if (rows.length == 100 && acknowledged.length == rows.length) {
      await _pushPending();
    }
  }

  Future<void> _pullChanges() async {
    var cursor = await _metadata('pull_cursor') ?? '0';
    var hasMore = true;
    while (hasMore) {
      late final Map<String, Object?> response;
      try {
        response = await _syncApi.pull(cursor: cursor);
      } on CursorExpiredFailure {
        final bootstrap = await _checklistApi.bootstrap();
        await _checklistRepository.applyBootstrap(bootstrap);
        return;
      }
      final changes = _objectList(response['changes']);
      final tombstones = _objectList(response['tombstones']);
      await _db.transaction(() async {
        for (final change in changes) {
          await _applyRemoteChange(change);
        }
        for (final tombstone in tombstones) {
          await _applyTombstone(tombstone);
        }
        cursor = response['nextCursor']?.toString() ?? cursor;
        await _putMetadata('pull_cursor', cursor);
      });
      hasMore = response['hasMore'] as bool? ?? false;
    }
  }

  Future<void> _applyRemoteChange(Map<String, Object?> change) async {
    final entityType = change['entityType']?.toString();
    final entityId = change['entityId']?.toString();
    if (entityId == null) return;
    final revision = _asNullableInt(change['revision']);
    final payload = change['payload'] is Map
        ? (change['payload'] as Map).cast<String, Object?>()
        : const <String, Object?>{};

    if (entityType == 'WEEKLY_CHECKLIST') {
      final local = await (_db.select(_db.localWeeklyChecklists)
            ..where((table) =>
                table.id.equals(entityId) | table.serverId.equals(entityId)))
          .getSingleOrNull();
      if (local != null) {
        await (_db.update(_db.localWeeklyChecklists)
              ..where((table) => table.id.equals(local.id)))
            .write(
          LocalWeeklyChecklistsCompanion(
            serverId: Value(entityId),
            revision: Value(revision),
            syncState: const Value('SYNCED'),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
      }
      return;
    }

    if (entityType == 'INSPECTION') {
      final local = await (_db.select(_db.localInspections)
            ..where((table) =>
                table.id.equals(entityId) | table.serverId.equals(entityId)))
          .getSingleOrNull();
      if (local != null) {
        if (local.syncState == 'CONFLICT') return;
        await (_db.update(_db.localInspections)
              ..where((table) => table.id.equals(local.id)))
            .write(
          LocalInspectionsCompanion(
            serverId: Value(entityId),
            revision: Value(revision),
            lifecycleStatus:
                Value(payload['lifecycleStatus']?.toString() ?? local.lifecycleStatus),
            syncState: const Value('SYNCED'),
            lastError: const Value(null),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
      }
    }
  }

  Future<void> _applyTombstone(Map<String, Object?> tombstone) async {
    if (tombstone['entityType']?.toString() == 'ASSET') {
      await (_db.update(_db.localAssets)
            ..where((table) =>
                table.id.equals(tombstone['entityId']!.toString())))
          .write(const LocalAssetsCompanion(active: Value(false)));
    }
    // Modelos e inspeções referenciados não são apagados: rascunhos e outbox
    // precisam continuar utilizáveis até confirmação do servidor.
  }

  Future<void> _writeEntityApplied(
    String entityType,
    String localId,
    String serverId,
    int? revision,
  ) async {
    if (entityType == 'WEEKLY_CHECKLIST') {
      await (_db.update(_db.localWeeklyChecklists)
            ..where((table) => table.id.equals(localId)))
          .write(
        LocalWeeklyChecklistsCompanion(
          serverId: Value(serverId),
          revision: Value(revision),
          syncState: const Value('SYNCED'),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
    } else {
      await (_db.update(_db.localInspections)
            ..where((table) => table.id.equals(localId)))
          .write(
        LocalInspectionsCompanion(
          serverId: Value(serverId),
          revision: Value(revision),
          syncState: const Value('SYNCED'),
          lastError: const Value(null),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
    }
  }

  Future<void> _writeEntitySyncState(
    String entityType,
    String entityId,
    String state,
  ) async {
    if (entityType == 'WEEKLY_CHECKLIST') {
      await (_db.update(_db.localWeeklyChecklists)
            ..where((table) => table.id.equals(entityId)))
          .write(LocalWeeklyChecklistsCompanion(syncState: Value(state)));
    } else {
      await (_db.update(_db.localInspections)
            ..where((table) => table.id.equals(entityId)))
          .write(LocalInspectionsCompanion(syncState: Value(state)));
    }
  }

  Future<void> _writeEntityFailure(
    String entityType,
    String entityId,
    String state,
    String detail,
    String? conflictId,
  ) async {
    if (entityType == 'WEEKLY_CHECKLIST') {
      await (_db.update(_db.localWeeklyChecklists)
            ..where((table) => table.id.equals(entityId)))
          .write(LocalWeeklyChecklistsCompanion(syncState: Value(state)));
    } else {
      await (_db.update(_db.localInspections)
            ..where((table) => table.id.equals(entityId)))
          .write(
        LocalInspectionsCompanion(
          syncState: Value(state),
          lastError: Value(detail),
          conflictId: Value(conflictId),
        ),
      );
    }
  }

  Future<void> _resetSendingOperations() async {
    final sending = await (_db.select(_db.syncOutboxOperations)
          ..where((table) => table.state.equals('SENDING')))
        .get();
    await _db.transaction(() async {
      for (final row in sending) {
        await (_db.update(_db.syncOutboxOperations)
              ..where((table) => table.operationId.equals(row.operationId)))
            .write(const SyncOutboxOperationsCompanion(state: Value('QUEUED')));
        await _writeEntitySyncState(row.entityType, row.entityId, 'QUEUED');
      }
    });
  }

  Future<void> _requeueFailedOperations() async {
    await (_db.update(_db.syncOutboxOperations)
          ..where((table) => table.state.equals('FAILED')))
        .write(const SyncOutboxOperationsCompanion(state: Value('QUEUED')));
  }

  Future<void> _publishIdleSnapshot() async {
    snapshot.value = SyncSnapshot(
      state: SyncRunState.idle,
      pendingCount: await _pendingCount(),
      lastSyncedAt: await _lastSyncAt(),
    );
  }

  Future<void> _publishOfflineSnapshot() async {
    snapshot.value = SyncSnapshot(
      state: SyncRunState.offline,
      pendingCount: await _pendingCount(),
      lastSyncedAt: await _lastSyncAt(),
      message: 'Sem conexão. Continue preenchendo; os dados estão salvos.',
    );
  }

  Future<int> _pendingCount() async {
    final count = _db.syncOutboxOperations.operationId.count();
    final query = _db.selectOnly(_db.syncOutboxOperations)..addColumns([count]);
    return (await query.map((row) => row.read(count) ?? 0).getSingle());
  }

  Future<DateTime?> _lastSyncAt() async {
    final value = await _metadata('last_sync_at');
    return value == null ? null : DateTime.tryParse(value)?.toLocal();
  }

  Future<String?> _metadata(String key) async {
    final row = await (_db.select(_db.localSyncMetadata)
          ..where((table) => table.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> _putMetadata(String key, String value) =>
      _db.into(_db.localSyncMetadata).insertOnConflictUpdate(
            LocalSyncMetadataCompanion.insert(
              key: key,
              value: value,
              updatedAt: DateTime.now().toUtc(),
            ),
          );

  static List<Map<String, Object?>> _objectList(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => item.cast<String, Object?>())
        .toList(growable: false);
  }

  static int? _asNullableInt(Object? value) => switch (value) {
        int number => number,
        num number => number.toInt(),
        String text => int.tryParse(text),
        _ => null,
      };
}
