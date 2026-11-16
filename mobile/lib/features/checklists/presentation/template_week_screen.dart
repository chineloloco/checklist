import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/state_badge.dart';
import '../domain/checklist_models.dart';
import 'asset_display.dart';
import 'week_screen.dart';
import 'weekly_form_group.dart';

class TemplateWeekScreen extends StatelessWidget {
  const TemplateWeekScreen({
    required this.dependencies,
    required this.group,
    required this.onNewForm,
    super.key,
  });

  final AppDependencies dependencies;
  final WeeklyFormGroup group;
  final Future<void> Function() onNewForm;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Veículos do formulário')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _startNewForm(context),
      icon: const Icon(Icons.add),
      label: const Text('Novo Formulário'),
    ),
    body: StreamBuilder<List<WeeklyChecklistCard>>(
      stream: dependencies.checklistRepository.watchWeeklyChecklists(),
      builder: (context, snapshot) {
        final weeks = (snapshot.data ?? group.weeks)
            .where(group.matches)
            .toList(growable: false);
        return RefreshIndicator(
          onRefresh: dependencies.syncCoordinator.syncNow,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 112),
            children: [
              Text(
                group.templateDisplayName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '${DateFormat('dd/MM/yyyy').format(group.weekStartDate)} — '
                '${DateFormat('dd/MM/yyyy').format(group.weekEndDate)} · '
                'versão ${group.templateVersionNumber}',
                style: const TextStyle(color: FieldColors.notApplicable),
              ),
              const SizedBox(height: 6),
              Text(
                '${weeks.length} veículo(s) neste formulário semanal.',
                style: const TextStyle(color: FieldColors.notApplicable),
              ),
              const SizedBox(height: 18),
              if (snapshot.connectionState == ConnectionState.waiting &&
                  snapshot.data == null)
                const Center(child: CircularProgressIndicator())
              else if (weeks.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Nenhum veículo encontrado neste formulário.',
                    textAlign: TextAlign.center,
                  ),
                )
              else
                for (final week in weeks) ...[
                  _VehicleWeekCard(
                    week: week,
                    onTap: () => _openWeek(context, week.id),
                  ),
                  const SizedBox(height: 12),
                ],
            ],
          ),
        );
      },
    ),
  );

  Future<void> _openWeek(BuildContext context, String id) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            WeekScreen(dependencies: dependencies, weeklyChecklistId: id),
      ),
    );
  }

  Future<void> _startNewForm(BuildContext context) async {
    Navigator.of(context).pop();
    await Future<void>.delayed(Duration.zero);
    await onNewForm();
  }
}

class _VehicleWeekCard extends StatelessWidget {
  const _VehicleWeekCard({required this.week, required this.onTap});

  final WeeklyChecklistCard week;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: FieldColors.steelSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    week.asset.kind == 'VEHICLE'
                        ? Icons.directions_car_outlined
                        : Icons.precision_manufacturing_outlined,
                    color: FieldColors.steel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        week.asset.displayTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        week.asset.displaySubtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    value: '${week.inspections.length}',
                    label: 'datas registradas',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    value: '${week.completedCount}',
                    label: 'concluídas',
                  ),
                ),
                StateBadge(
                  label: week.hasPendingSync ? 'Pendente' : 'Enviado',
                  icon: week.hasPendingSync
                      ? Icons.outbox_outlined
                      : Icons.cloud_done_outlined,
                  tone: week.hasPendingSync
                      ? BadgeTone.attention
                      : BadgeTone.success,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      Text(
        label,
        style: const TextStyle(fontSize: 11, color: FieldColors.notApplicable),
      ),
    ],
  );
}
