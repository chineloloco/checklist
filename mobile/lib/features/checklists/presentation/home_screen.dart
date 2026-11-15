import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/state_badge.dart';
import '../../sync/presentation/sync_banner.dart';
import '../domain/checklist_models.dart';
import 'week_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.dependencies,
    required this.onSignOut,
    this.initialWarning,
    super.key,
  });

  final AppDependencies dependencies;
  final Future<void> Function() onSignOut;
  final String? initialWarning;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _message;

  @override
  void initState() {
    super.initState();
    _message = widget.initialWarning;
  }

  Future<void> _newChecklist() async {
    try {
      final assets = await widget.dependencies.checklistRepository.listAssets();
      if (!mounted) return;
      if (assets.isEmpty) {
        setState(() => _message =
            'Nenhum veículo ou equipamento foi baixado. Sincronize com internet.');
        return;
      }
      final asset = await showModalBottomSheet<AssetSummary>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => _AssetPicker(assets: assets),
      );
      if (asset == null || !mounted) return;
      final templates =
          await widget.dependencies.checklistService.templatesFor(asset);
      if (!mounted) return;
      final template = templates.length == 1
          ? templates.single
          : await showModalBottomSheet<TemplateChoice>(
              context: context,
              showDragHandle: true,
              builder: (context) => _TemplatePicker(choices: templates),
            );
      if (template == null || !mounted) return;
      final weekId = await widget.dependencies.checklistService.openWeek(
        asset: asset,
        template: template,
        localDate: DateTime.now(),
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => WeekScreen(
            dependencies: widget.dependencies,
            weeklyChecklistId: weekId,
          ),
        ),
      );
      if (mounted) setState(() {});
    } on AppFailure catch (error) {
      if (mounted) setState(() => _message = error.message);
    }
  }

  Future<void> _confirmSignOut() async {
    final pending = widget.dependencies.syncCoordinator.snapshot.value.pendingCount;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: Text(
          pending == 0
              ? 'Os dados offline permanecerão cifrados neste aparelho.'
              : 'Há $pending operação(ões) ainda não enviada(s). Elas permanecerão salvas e exigirão esta mesma conta para sincronizar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmed == true) await widget.onSignOut();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Operação de campo'),
              Text(
                'Checklists semanais',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: _confirmSignOut,
              tooltip: 'Sair da conta',
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _newChecklist,
          icon: const Icon(Icons.add),
          label: const Text('Abrir semana'),
        ),
        body: StreamBuilder<List<WeeklyChecklistCard>>(
          stream: widget.dependencies.checklistRepository.watchWeeklyChecklists(),
          builder: (context, snapshot) {
            final weeks = snapshot.data ?? const [];
            return RefreshIndicator(
              onRefresh: widget.dependencies.syncCoordinator.syncNow,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 112),
                children: [
                  SyncBanner(
                    coordinator: widget.dependencies.syncCoordinator,
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 12),
                    _InlineNotice(
                      message: _message!,
                      onDismiss: () => setState(() => _message = null),
                    ),
                  ],
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Diário semanal',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      Text(
                        '${weeks.length} semana(s)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: FieldColors.notApplicable,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Cada data é salva e enviada de forma independente.',
                    style: TextStyle(color: FieldColors.notApplicable),
                  ),
                  const SizedBox(height: 16),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.all(36),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (weeks.isEmpty)
                    const _EmptyWeeks()
                  else
                    for (final week in weeks) ...[
                      _WeekCard(
                        week: week,
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => WeekScreen(
                                dependencies: widget.dependencies,
                                weeklyChecklistId: week.id,
                              ),
                            ),
                          );
                          if (mounted) setState(() {});
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                ],
              ),
            );
          },
        ),
      );
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.week, required this.onTap});
  final WeeklyChecklistCard week;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final period =
        '${DateFormat('dd/MM').format(week.weekStartDate)} — ${DateFormat('dd/MM').format(week.weekEndDate)}';
    return Card(
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
                        Text(week.asset.code,
                            style: Theme.of(context).textTheme.titleLarge),
                        Text('${week.asset.description} · $period'),
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Modelo VL · v${week.templateVersionNumber}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: FieldColors.steel,
                        ),
                  ),
                  const Spacer(),
                  const Text(
                    'Versão fixada',
                    style: TextStyle(fontSize: 12, color: FieldColors.notApplicable),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
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

class _EmptyWeeks extends StatelessWidget {
  const _EmptyWeeks();

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.calendar_view_week_outlined,
                  size: 42, color: FieldColors.steel),
              const SizedBox(height: 12),
              Text('Nenhuma semana aberta',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              const Text(
                'Use “Abrir semana” para selecionar um veículo e começar.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.message, required this.onDismiss});
  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        decoration: BoxDecoration(
          color: FieldColors.amberSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF805000)),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
            IconButton(onPressed: onDismiss, icon: const Icon(Icons.close)),
          ],
        ),
      );
}

class _AssetPicker extends StatelessWidget {
  const _AssetPicker({required this.assets});
  final List<AssetSummary> assets;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selecione o ativo',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              const Text('Veículos e equipamentos autorizados para este aparelho.'),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: assets.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final asset = assets[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(asset.kind == 'VEHICLE'
                          ? Icons.directions_car_outlined
                          : Icons.precision_manufacturing_outlined),
                      title: Text(asset.code),
                      subtitle: Text(asset.description),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pop(context, asset),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
}

class _TemplatePicker extends StatelessWidget {
  const _TemplatePicker({required this.choices});
  final List<TemplateChoice> choices;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selecione o modelo',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              for (final choice in choices)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(choice.displayName),
                  subtitle: Text('Versão ${choice.versionNumber}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pop(context, choice),
                ),
            ],
          ),
        ),
      );
}
