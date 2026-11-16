import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/input/brazilian_date_input.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/state_badge.dart';
import '../domain/checklist_models.dart';
import 'asset_display.dart';
import 'identification_form.dart';
import 'inspection_screen.dart';

class WeekScreen extends StatefulWidget {
  const WeekScreen({
    required this.dependencies,
    required this.weeklyChecklistId,
    super.key,
  });

  final AppDependencies dependencies;
  final String weeklyChecklistId;

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  Future<void> _openExisting(String id) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InspectionScreen(
          repository: widget.dependencies.checklistRepository,
          inspectionId: id,
        ),
      ),
    );
  }

  Future<void> _create(WeeklyChecklistDetail week, DateTime date) async {
    final identification = await showModalBottomSheet<IdentificationSnapshot>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => IdentificationForm(
        asset: week.asset,
        dependencies: widget.dependencies,
      ),
    );
    if (identification == null || !mounted) return;
    try {
      final id = await widget.dependencies.checklistService.openInspection(
        week: week,
        localDate: date,
        identification: identification,
      );
      if (!mounted) return;
      await _openExisting(id);
    } on AppFailure catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Checklist da semana')),
    body: StreamBuilder<WeeklyChecklistDetail>(
      stream: widget.dependencies.checklistRepository.watchWeeklyChecklist(
        widget.weeklyChecklistId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErrorState(
            message: snapshot.error.toString(),
            retry: () => setState(() {}),
          );
        }
        final week = snapshot.requireData;
        return RefreshIndicator(
          onRefresh: widget.dependencies.syncCoordinator.syncNow,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _WeekHeader(week: week),
              const SizedBox(height: 24),
              Text(
                'Datas da semana',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              const Text(
                'Toque em uma data vazia para iniciar ou retome um rascunho.',
                style: TextStyle(color: FieldColors.notApplicable),
              ),
              const SizedBox(height: 14),
              for (var offset = 0; offset < 7; offset++) ...[
                _DayTile(
                  date: week.weekStartDate.add(Duration(days: offset)),
                  inspection: _inspectionFor(
                    week.inspections,
                    week.weekStartDate.add(Duration(days: offset)),
                  ),
                  onTap: (inspection) => inspection == null
                      ? _create(
                          week,
                          week.weekStartDate.add(Duration(days: offset)),
                        )
                      : _openExisting(inspection.id),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 20),
              const Text(
                'Desenvolvido pelo setor de TI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: FieldColors.notApplicable,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  static InspectionSummary? _inspectionFor(
    List<InspectionSummary> inspections,
    DateTime date,
  ) {
    for (final inspection in inspections) {
      if (DateUtils.isSameDay(inspection.localDate, date)) return inspection;
    }
    return null;
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({required this.week});
  final WeeklyChecklistDetail week;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: FieldColors.steel,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.directions_car_outlined,
                  color: Colors.white,
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
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '${DateFormat('dd/MM/yyyy').format(week.weekStartDate)} — '
            '${DateFormat('dd/MM/yyyy').format(week.weekStartDate.add(const Duration(days: 6)))}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StateBadge(
                  label:
                      '${week.templateDisplayName} · versão ${week.templateVersionNumber}',
                  icon: Icons.lock_outline,
                  maxWidth: constraints.maxWidth,
                ),
                StateBadge(
                  label: '${week.inspections.length} data(s)',
                  icon: Icons.calendar_today_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.date,
    required this.inspection,
    required this.onTap,
  });

  final DateTime date;
  final InspectionSummary? inspection;
  final void Function(InspectionSummary?) onTap;

  @override
  Widget build(BuildContext context) {
    final item = inspection;
    return Card(
      child: InkWell(
        onTap: () => onTap(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: item == null
                      ? FieldColors.paper
                      : item.lifecycle == InspectionLifecycle.completed
                      ? FieldColors.compliantSoft
                      : FieldColors.amberSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('E', 'pt_BR').format(date).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${date.day}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: item == null
                    ? const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sem inspeção',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Toque para iniciar',
                            style: TextStyle(color: FieldColors.notApplicable),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.lifecycle.label,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${item.answeredCount} de ${item.totalCount} itens',
                          ),
                          const SizedBox(height: 5),
                          StateBadge(
                            label: item.syncState.label,
                            icon: _syncIcon(item.syncState),
                            tone: _syncTone(item.syncState),
                          ),
                        ],
                      ),
              ),
              Icon(
                item == null ? Icons.add_circle_outline : Icons.chevron_right,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _syncIcon(LocalSyncState value) => switch (value) {
    LocalSyncState.synced => Icons.cloud_done_outlined,
    LocalSyncState.conflict => Icons.call_split,
    LocalSyncState.error => Icons.error_outline,
    LocalSyncState.syncing => Icons.sync,
    _ => Icons.outbox_outlined,
  };

  static BadgeTone _syncTone(LocalSyncState value) => switch (value) {
    LocalSyncState.synced => BadgeTone.success,
    LocalSyncState.conflict || LocalSyncState.error => BadgeTone.danger,
    LocalSyncState.queued || LocalSyncState.syncing => BadgeTone.attention,
    _ => BadgeTone.neutral,
  };
}

class _IdentificationForm extends StatefulWidget {
  const _IdentificationForm({required this.asset});
  final AssetSummary asset;

  @override
  State<_IdentificationForm> createState() => _IdentificationFormState();
}

class _IdentificationFormState extends State<_IdentificationForm> {
  final _formKey = GlobalKey<FormState>();
  final _company = TextEditingController();
  final _site = TextEditingController();
  final _responsible = TextEditingController();
  final _license = TextEditingController();
  final _licenseExpiry = TextEditingController();

  @override
  void dispose() {
    _company.dispose();
    _site.dispose();
    _responsible.dispose();
    _license.dispose();
    _licenseExpiry.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      IdentificationSnapshot(
        company: _company.text.trim(),
        site: _site.text.trim(),
        assetCode: widget.asset.code,
        ownershipType: widget.asset.ownershipType,
        responsiblePersonName: _responsible.text.trim(),
        manufactureYear: widget.asset.manufactureYear,
        predominantColor: widget.asset.predominantColor,
        licensePlate: widget.asset.licensePlate,
        vehicleMakeModel: widget.asset.makeModel,
        manufacturer: widget.asset.manufacturer,
        driverLicenseNumber: _license.text.trim().isEmpty
            ? null
            : _license.text.trim(),
        driverLicenseExpiryDate: _licenseExpiry.text.trim().isEmpty
            ? null
            : brazilianDateToIso(_licenseExpiry.text)!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      0,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 20,
    ),
    child: SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Conferir identificação',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              widget.asset.displayTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              widget.asset.displaySubtitle,
              style: const TextStyle(color: FieldColors.steel),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _company,
              decoration: const InputDecoration(labelText: 'Empresa'),
              textInputAction: TextInputAction.next,
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _site,
              decoration: const InputDecoration(labelText: 'Local'),
              textInputAction: TextInputAction.next,
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _responsible,
              decoration: const InputDecoration(
                labelText: 'Motorista ou operador',
              ),
              textInputAction: TextInputAction.next,
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _license,
              decoration: const InputDecoration(labelText: 'CNH'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _licenseExpiry,
              decoration: const InputDecoration(
                labelText: 'Vencimento da CNH',
                hintText: 'DD/MM/AAAA',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: const [BrazilianDateInputFormatter()],
              validator: optionalBrazilianDateError,
            ),
            const SizedBox(height: 14),
            const Text(
              'Coleta de assinatura e arquivos aguarda a definição das regras e do contrato de upload.',
              style: TextStyle(color: FieldColors.notApplicable),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Abrir inspeção'),
            ),
          ],
        ),
      ),
    ),
  );

  static String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Campo obrigatório' : null;
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.retry});
  final String message;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 42),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: retry, child: const Text('Tentar novamente')),
        ],
      ),
    ),
  );
}
