import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

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
  final _scrollController = ScrollController();
  bool _completing = false;
  bool _addingPhoto = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _saveAnswer(
    ChecklistItem item,
    InspectionResult? result, {
    String? observation,
    bool advance = false,
  }) async {
    try {
      await widget.repository.saveAnswer(
        inspectionId: widget.inspectionId,
        itemId: item.id,
        result: result,
        observation: observation ?? item.observation,
      );
      if (mounted &&
          advance &&
          result != null &&
          _scrollController.hasClients) {
        await _scrollController.animateTo(
          (_scrollController.offset + 160).clamp(
            0.0,
            _scrollController.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    } on AppFailure catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _editObservation(ChecklistItem item) async {
    final value = await showDialog<String>(
      context: context,
      builder: (context) => _TextEditorDialog(
        title:
            'Observação · item ${item.sourcePrintedNumber ?? item.order + 1}',
        initialValue: item.observation,
        hintText: 'Descreva a condição encontrada',
        minLines: 3,
        maxLines: 7,
        maxLength: 4000,
      ),
    );
    if (value != null) {
      await _saveAnswer(item, item.result, observation: value);
    }
  }

  Future<void> _editGeneralNotes(InspectionDraft draft) async {
    final value = await showDialog<String>(
      context: context,
      builder: (context) => _TextEditorDialog(
        title: 'Observações da inspeção',
        initialValue: draft.observations,
        hintText: 'Informações gerais desta data',
        minLines: 4,
        maxLines: 8,
        maxLength: 10000,
      ),
    );
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  Future<void> _addPhoto(InspectionDraft draft) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Adicionar foto',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Tirar foto'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Escolher da galeria'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;
    setState(() => _addingPhoto = true);
    File? savedFile;
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (picked == null) return;
      if (await picked.length() > 2500000) {
        throw const ValidationFailure(
          'A foto ficou maior que 2,5 MB. Escolha uma imagem menor.',
        );
      }
      final root = await getApplicationDocumentsDirectory();
      final directory = Directory(
        '${root.path}${Platform.pathSeparator}inspection_photos'
        '${Platform.pathSeparator}${draft.id}',
      );
      await directory.create(recursive: true);
      final extension = picked.path.toLowerCase().endsWith('.png')
          ? 'png'
          : 'jpg';
      savedFile = File(
        '${directory.path}${Platform.pathSeparator}'
        '${DateTime.now().microsecondsSinceEpoch}.$extension',
      );
      await picked.saveTo(savedFile.path);
      await widget.repository.addPhotoAttachment(
        inspectionId: draft.id,
        localPath: savedFile.path,
        mediaType: extension == 'png' ? 'image/png' : 'image/jpeg',
      );
    } on AppFailure catch (error) {
      if (savedFile != null && await savedFile.exists()) {
        await savedFile.delete();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } on Object catch (_) {
      if (savedFile != null && await savedFile.exists()) {
        await savedFile.delete();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível anexar a foto.')),
      );
    } finally {
      if (mounted) setState(() => _addingPhoto = false);
    }
  }

  Future<void> _removePhoto(
    InspectionDraft draft,
    InspectionAttachment attachment,
  ) async {
    try {
      await widget.repository.removeAttachment(
        inspectionId: draft.id,
        attachmentId: attachment.id,
      );
    } on AppFailure catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _deactivateInspection(InspectionDraft draft) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desativar este formulário?'),
        content: const Text(
          'As respostas e fotos serão preservadas neste aparelho. O formulário deixará de ser enviado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Desativar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await widget.repository.deactivateUnsyncedInspection(draft.id);
      if (mounted) Navigator.pop(context, true);
    } on AppFailure catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
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
              Text(
                DateFormat(
                  "EEEE, dd 'de' MMMM",
                  'pt_BR',
                ).format(draft.localDate),
              ),
              Text(
                '${draft.templateDisplayName} · versão ${draft.templateVersionNumber} fixada',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
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
                          onPressed: _completing
                              ? null
                              : () => _complete(draft),
                          icon: _completing
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
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
          controller: _scrollController,
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
            const SizedBox(height: 12),
            _PhotoSection(
              attachments: draft.attachments,
              readOnly: readOnly,
              adding: _addingPhoto,
              onAdd: () => _addPhoto(draft),
              onRemove: (attachment) => _removePhoto(draft, attachment),
            ),
            if (draft.canDeleteBeforeSync) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => _deactivateInspection(draft),
                style: OutlinedButton.styleFrom(
                  foregroundColor: FieldColors.nonCompliant,
                  side: const BorderSide(color: FieldColors.nonCompliant),
                ),
                icon: const Icon(Icons.power_settings_new),
                label: const Text('Desativar formulário não enviado'),
              ),
            ],
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
              child: Text(
                entry.key,
                style: Theme.of(context).textTheme.titleLarge,
              ),
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
            onChanged: (result) => _saveAnswer(item, result, advance: true),
            onObservation: () => _editObservation(item),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 12),
      ],
    ];
  }
}

class _PhotoSection extends StatelessWidget {
  const _PhotoSection({
    required this.attachments,
    required this.readOnly,
    required this.adding,
    required this.onAdd,
    required this.onRemove,
  });

  final List<InspectionAttachment> attachments;
  final bool readOnly;
  final bool adding;
  final VoidCallback onAdd;
  final ValueChanged<InspectionAttachment> onRemove;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_camera_back_outlined),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Fotos da inspeção',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text('${attachments.length}/5'),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Anexe fotos gerais ou evidências encontradas durante o checklist.',
            style: TextStyle(color: FieldColors.notApplicable),
          ),
          if (attachments.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final attachment in attachments)
                  _PhotoThumbnail(
                    attachment: attachment,
                    onRemove: readOnly ? null : () => onRemove(attachment),
                  ),
              ],
            ),
          ],
          if (!readOnly && attachments.length < 5) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: adding ? null : onAdd,
              icon: adding
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_a_photo_outlined),
              label: Text(adding ? 'Anexando…' : 'Adicionar foto'),
            ),
          ],
        ],
      ),
    ),
  );
}

class _PhotoThumbnail extends StatelessWidget {
  const _PhotoThumbnail({required this.attachment, this.onRemove});

  final InspectionAttachment attachment;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(attachment.localPath),
          width: 104,
          height: 104,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            width: 104,
            height: 104,
            color: FieldColors.steelSoft,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image_outlined),
          ),
        ),
      ),
      if (onRemove != null)
        Positioned(
          top: -8,
          right: -8,
          child: IconButton.filled(
            tooltip: 'Remover foto',
            onPressed: onRemove,
            style: IconButton.styleFrom(
              backgroundColor: FieldColors.nonCompliant,
              foregroundColor: Colors.white,
              minimumSize: const Size(32, 32),
              padding: EdgeInsets.zero,
            ),
            iconSize: 18,
            icon: const Icon(Icons.close),
          ),
        ),
    ],
  );
}

class _TextEditorDialog extends StatefulWidget {
  const _TextEditorDialog({
    required this.title,
    required this.hintText,
    required this.minLines,
    required this.maxLines,
    required this.maxLength,
    this.initialValue,
  });

  final String title;
  final String? initialValue;
  final String hintText;
  final int minLines;
  final int maxLines;
  final int maxLength;

  @override
  State<_TextEditorDialog> createState() => _TextEditorDialogState();
}

class _TextEditorDialogState extends State<_TextEditorDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: _controller,
      autofocus: true,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      decoration: InputDecoration(hintText: widget.hintText),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _controller.text),
        child: const Text('Salvar'),
      ),
    ],
  );
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
                style: TextStyle(
                  fontSize: 12,
                  color: FieldColors.notApplicable,
                ),
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
          _Detail(
            label: 'Motorista/operador',
            value: value.responsiblePersonName,
          ),
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
          child: Text(
            label,
            style: const TextStyle(color: FieldColors.notApplicable),
          ),
        ),
        Expanded(child: Text(value, textAlign: TextAlign.end)),
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
        _LegendItem(
          icon: Icons.touch_app_outlined,
          label: 'Toque novamente para desmarcar',
        ),
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
    return Card(
      color: FieldColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: FieldColors.line),
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
                    color: FieldColors.steelSoft,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    item.sourcePrintedNumber ?? '${item.order + 1}',
                    style: TextStyle(
                      color: FieldColors.steel,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.text,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
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
                      : () => onChanged(
                          item.result == InspectionResult.compliant
                              ? null
                              : InspectionResult.compliant,
                        ),
                ),
                _ResultButton(
                  label: 'NC',
                  icon: Icons.warning_amber,
                  selected: item.result == InspectionResult.nonCompliant,
                  color: FieldColors.nonCompliant,
                  onPressed: readOnly
                      ? null
                      : () => onChanged(
                          item.result == InspectionResult.nonCompliant
                              ? null
                              : InspectionResult.nonCompliant,
                        ),
                ),
                _ResultButton(
                  label: 'NA',
                  icon: Icons.block,
                  selected: item.result == InspectionResult.notApplicable,
                  color: FieldColors.notApplicable,
                  onPressed: readOnly
                      ? null
                      : () => onChanged(
                          item.result == InspectionResult.notApplicable
                              ? null
                              : InspectionResult.notApplicable,
                        ),
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
                label: Text(
                  item.observation?.isNotEmpty == true
                      ? 'Editar observação'
                      : 'Adicionar observação',
                ),
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
