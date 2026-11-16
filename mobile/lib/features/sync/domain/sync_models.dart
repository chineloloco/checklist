enum SyncRunState { idle, running, offline, sessionExpired, failed }

final class SyncSnapshot {
  const SyncSnapshot({
    required this.state,
    required this.pendingCount,
    this.lastSyncedAt,
    this.message,
  });

  const SyncSnapshot.idle()
    : state = SyncRunState.idle,
      pendingCount = 0,
      lastSyncedAt = null,
      message = null;

  final SyncRunState state;
  final int pendingCount;
  final DateTime? lastSyncedAt;
  final String? message;
}

final class SyncOperationDto {
  const SyncOperationDto({
    required this.operationId,
    required this.entityType,
    required this.mutation,
    required this.entityId,
    required this.clientOccurredAt,
    required this.payload,
    this.baseRevision,
  });

  final String operationId;
  final String entityType;
  final String mutation;
  final String entityId;
  final int? baseRevision;
  final DateTime clientOccurredAt;
  final Map<String, Object?> payload;

  Map<String, Object?> toJson() => {
    'operationId': operationId,
    'entityType': entityType,
    'mutation': mutation,
    'entityId': entityId,
    'baseRevision': baseRevision,
    // Drift/SQLite pode reconstruir o DateTime como horário local. O
    // contrato da API exige um ISO 8601 com offset explícito.
    'clientOccurredAt': clientOccurredAt.toUtc().toIso8601String(),
    'payload': payload,
  };
}
