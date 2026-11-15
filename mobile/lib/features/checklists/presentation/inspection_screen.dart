import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/state_badge.dart';
import '../domain/checklist_models.dart';
import '../domain/checklist_repository.dart';

class InspectionScreen extends StatefulWidget {
  const InspectionScreen({
    required this.repository,
    required this.inspectionId,
    super.key,
  });

  final ChecklistRepository repository;
  final String inspectionId;

  @override
  State<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  bool _completing = false;

  Future<void> _saveAnswer(
    ChecklistItem item,
    InspectionResult? result, {
    String? observation,
  }) async {
    try {
      await widget.repository.saveAnswer(
        inspectionId: widget.inspectionId,
        itemId: item.id,
        result: result,
        observation: observation ?? item.observation,
      );
    } on AppFailure catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  Future<void> _editObservation(ChecklistItem item) async {
    final controller = TextEditingController(text: item.observation);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Observação · item ${item.sourcePrintedNumber ?? item.order + 1}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 3,
          maxLines: 7,
          maxLength: 4000,
          decoration: const InputDecoration(
            hintText: 'Descreva a condição encontrada',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value != null) {
      await _saveAnswer(item, item.result, observation: value);
    }
  }

  Future<void> _editGeneralNotes(InspectionDraft draft) async {
    final controller = TextEditingController(text: draft.observations);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Observações da inspeção'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 4,
          maxLines: 8,
          maxLength: 10000,
          decoration: const InputDecoration(
            hintText: 'Informações gerais desta data',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value != null) {
      await widget.repository.saveInspectionNotes(
        inspectionId: draft.id,
        observations: value,
      );
    }
  }

  Future<void> _complete(InspectionDraft draft) async {
    if (!draft.canComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ainda faltam ${draft.requiredCount - draft.requiredAnsweredCount} item(ns) obrigatório(s).',
          ),
        ),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Concluir esta inspeção?'),
        content: const Text(
          'Somente esta data será concluída. Outras datas da semana não serão afetadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Voltar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.check),
            label: const Text('Concluir'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _completing = true);
    try {
      await widget.repository.completeInspection(draft.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inspeção concluída e adicionada à fila de envio.'),
        ),
      );
    } on AppFailure catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<InspectionDraft>(
        stream: widget.repository.watchInspection(widget.inspectionId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: snapshot.hasError
                    ? Text(snapshot.error.toString())
                    : const CircularProgressIndicator(),
              ),
            );
          }
          final draft = snapshot.requireData;
          final readOnly = draft.lifecycle != InspectionLifecycle.draft;
          return Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat("EEEE, dd 'de' MMMM", 'pt_BR')
                      .format(draft.localDate)),
                  Text(
                    'VL · versão ${draft.templateVersionNumber} fixada',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: readOnly
                ? null
                : SafeArea(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                      decoration: const BoxDecoration(
                        color: FieldColors.surface,
                        border: Border(top: BorderSide(color: FieldColors.line)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.save_outlined),
                              label: const Text('Continuar depois'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _completing ? null : () => _complete(draft),
                              icon: _completing
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.task_alt),
                              label: const Text('Concluir'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            body: ListView(
              padding: EdgeInsets.fromLTRB(16, 8, 16, readOnly ? 32 : 120),
              children: [
                _InspectionProgress(draft: draft),
                const SizedBox(height: 12),
                _IdentificationCard(draft: draft),
                const SizedBox(height: 12),
                const _Legend(),
                const SizedBox(height: 24),
                ..._buildSections(draft, readOnly),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.notes_outlined),
                    title: const Text('Observações da inspeção'),
                    subtitle: Text(
                      draft.observations?.isNotEmpty == true
                          ? draft.observations!
                          : 'Nenhuma observação geral',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: readOnly ? null : const Icon(Icons.edit_outlined),
                    onTap: readOnly ? null : () => _editGeneralNotes(draft),
                  ),
                ),
              ],
            ),
          );
        },
      );

  List<Widget> _buildSections(InspectionDraft draft, bool readOnly) {
    final sections = <String, List<ChecklistItem>>{};
    for (final item in draft.items) {
      sections.putIfAbsent(item.sectionTitle, () => []).add(item);
    }
    return [
      for (final entry in sections.entries) ...[
        Row(
          children: [
            Expanded(
              child: Text(entry.key,
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            Text(
              '${entry.value.where((item) => item.result != null).length}/${entry.value.length}',
              style: const TextStyle(color: FieldColors.notApplicable),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final item in entry.value) ...[
          _ItemCard(
            item: item,
            readOnly: readOnly,
            onChanged: (result) => _saveAnswer(item, result),
            onObservation: () => _editObservation(item),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 12),
      ],
    ];
  }
}

class _InspectionProgress extends StatelessWidget {
  const _InspectionProgress({required this.draft});
  final InspectionDraft draft;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${draft.answeredCount} de ${draft.items.length} itens',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  StateBadge(
                    label: draft.lifecycle.label,
                    icon: draft.lifecycle == InspectionLifecycle.completed
                        ? Icons.task_alt
                        : Icons.edit_note,
                    tone: draft.lifecycle == InspectionLifecycle.completed
                        ? BadgeTone.success
                        : BadgeTone.attention,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: draft.progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
                backgroundColor: FieldColors.steelSoft,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  StateBadge(
                    label: draft.syncState.label,
                    icon: draft.syncState == LocalSyncState.synced
                        ? Icons.cloud_done_outlined
                        : draft.syncState == LocalSyncState.conflict
                            ? Icons.call_split
                            : Icons.outbox_outlined,
                    tone: draft.syncState == LocalSyncState.synced
                        ? BadgeTone.success
                        : draft.syncState == LocalSyncState.conflict ||
                                draft.syncState == LocalSyncState.error
                            ? BadgeTone.danger
                            : BadgeTone.attention,
                  ),
                  const Spacer(),
                  const Text(
                    'Salvamento automático',
                    style: TextStyle(fontSize: 12, color: FieldColors.notApplicable),
                  ),
                ],
              ),
              if (draft.lastError != null) ...[
                const SizedBox(height: 8),
                Text(
                  draft.lastError!,
                  style: const TextStyle(color: FieldColors.nonCompliant),
                ),
              ],
            ],
          ),
        ),
      );
}

class _IdentificationCard extends StatelessWidget {
  const _IdentificationCard({required this.draft});
  final InspectionDraft draft;

  @override
  Widget build(BuildContext context) {
    final value = draft.identification;
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.badge_outlined),
        title: const Text('Identificação conferida'),
        subtitle: Text('${value.responsiblePersonName} · ${value.site}'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          _Detail(label: 'Empresa', value: value.company),
          _Detail(label: 'Ativo', value: value.assetCode),
          _Detail(label: 'Placa', value: value.licensePlate ?? '—'),
          _Detail(label: 'Motorista/operador', value: value.responsiblePersonName),
          _Detail(label: 'CNH', value: value.driverLicenseNumber ?? '—'),
        ],
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(color: FieldColors.notApplicable)),
            ),
            Expanded(
              child: Text(value, textAlign: TextAlign.end),
            ),
          ],
        ),
      );
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: FieldColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: FieldColors.line),
        ),
        child: const Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            _LegendItem(icon: Icons.check_circle_outline, label: 'C · Conforme'),
            _LegendItem(icon: Icons.warning_amber, label: 'NC · Não conforme'),
            _LegendItem(icon: Icons.block, label: 'NA · Não aplicável'),
            _LegendItem(icon: Icons.radio_button_unchecked, label: 'Sem resposta'),
          ],
        ),
      );
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.item,
    required this.readOnly,
    required this.onChanged,
    required this.onObservation,
  });

  final ChecklistItem item;
  final bool readOnly;
  final ValueChanged<InspectionResult?> onChanged;
  final VoidCallback onObservation;

  @override
  Widget build(BuildContext context) {
    final isNc = item.result == InspectionResult.nonCompliant;
    return Card(
      color: isNc ? FieldColors.nonCompliantSoft : FieldColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isNc ? FieldColors.nonCompliant : FieldColors.line,
          width: isNc ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isNc ? FieldColors.nonCompliant : FieldColors.steelSoft,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    item.sourcePrintedNumber ?? '${item.order + 1}',
                    style: TextStyle(
                      color: isNc ? Colors.white : FieldColors.steel,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.text,
                          style: Theme.of(context).textTheme.titleMedium),
                      if (isNc) ...[
                        const SizedBox(height: 5),
                        const Row(
                          children: [
                            Icon(Icons.warning_amber,
                                size: 17, color: FieldColors.nonCompliant),
                            SizedBox(width: 5),
                            Text(
                              'NC · Não conforme',
                              style: TextStyle(
                                color: FieldColors.nonCompliant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ResultButton(
                  label: 'C',
                  icon: Icons.check,
                  selected: item.result == InspectionResult.compliant,
                  color: FieldColors.compliant,
                  onPressed: readOnly
                      ? null
                      : () => onChanged(InspectionResult.compliant),
                ),
                _ResultButton(
                  label: 'NC',
                  icon: Icons.warning_amber,
                  selected: item.result == InspectionResult.nonCompliant,
                  color: FieldColors.nonCompliant,
                  onPressed: readOnly
                      ? null
                      : () => onChanged(InspectionResult.nonCompliant),
                ),
                _ResultButton(
                  label: 'NA',
                  icon: Icons.block,
                  selected: item.result == InspectionResult.notApplicable,
                  color: FieldColors.notApplicable,
                  onPressed: readOnly
                      ? null
                      : () => onChanged(InspectionResult.notApplicable),
                ),
                if (item.result != null && !readOnly)
                  TextButton.icon(
                    onPressed: () => onChanged(null),
                    icon: const Icon(Icons.undo, size: 18),
                    label: const Text('Sem resposta'),
                  ),
              ],
            ),
            if (item.observation?.isNotEmpty == true) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: FieldColors.paper,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(item.observation!),
              ),
            ],
            if (!readOnly) ...[
              const SizedBox(height: 6),
              TextButton.icon(
                onPressed: onObservation,
                icon: const Icon(Icons.notes_outlined, size: 18),
                label: Text(item.observation?.isNotEmpty == true
                    ? 'Editar observação'
                    : 'Adicionar observação'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultButton extends StatelessWidget {
  const _ResultButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
        selected: selected,
        button: true,
        label: label,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(76, 46),
            foregroundColor: selected ? Colors.white : color,
            backgroundColor: selected ? color : Colors.transparent,
            side: BorderSide(color: selected ? color : FieldColors.line),
          ),
          icon: Icon(icon, size: 18),
          label: Text(label),
        ),
      );
}
