import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/state_badge.dart';
import '../application/sync_coordinator.dart';
import '../domain/sync_models.dart';

class SyncBanner extends StatelessWidget {
  const SyncBanner({required this.coordinator, super.key});
  final SyncCoordinator coordinator;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<SyncSnapshot>(
        valueListenable: coordinator.snapshot,
        builder: (context, value, _) {
          final (label, icon, tone) = switch (value.state) {
            SyncRunState.running =>
              ('Sincronizando', Icons.sync, BadgeTone.attention),
            SyncRunState.offline =>
              ('Sem conexão', Icons.cloud_off_outlined, BadgeTone.neutral),
            SyncRunState.sessionExpired =>
              ('Sessão expirada', Icons.lock_clock_outlined, BadgeTone.danger),
            SyncRunState.failed =>
              ('Falha', Icons.error_outline, BadgeTone.danger),
            SyncRunState.idle when value.pendingCount > 0 =>
              ('${value.pendingCount} pendente(s)', Icons.outbox_outlined, BadgeTone.attention),
            _ => ('Em dia', Icons.cloud_done_outlined, BadgeTone.success),
          };
          final lastSync = value.lastSyncedAt == null
              ? 'Nunca sincronizado'
              : 'Última: ${DateFormat('dd/MM HH:mm').format(value.lastSyncedAt!)}';
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 13, 10, 13),
            decoration: BoxDecoration(
              color: FieldColors.surface,
              border: Border.all(color: FieldColors.line),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StateBadge(label: label, icon: icon, tone: tone),
                      const SizedBox(height: 7),
                      Text(
                        value.message ?? lastSync,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: FieldColors.notApplicable,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: value.state == SyncRunState.running
                      ? null
                      : coordinator.syncNow,
                  tooltip: 'Sincronizar agora',
                  icon: const Icon(Icons.sync),
                ),
              ],
            ),
          );
        },
      );
}
