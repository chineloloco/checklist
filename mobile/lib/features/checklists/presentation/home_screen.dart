import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/state_badge.dart';
import '../../sync/presentation/sync_banner.dart';
import '../domain/checklist_models.dart';
import 'asset_display.dart';
import 'asset_form.dart';
import 'asset_search.dart';
import 'template_week_screen.dart';
import 'week_screen.dart';
import 'weekly_form_group.dart';

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
  bool _creatingChecklist = false;

  @override
  void initState() {
    super.initState();
    _message = widget.initialWarning;
  }

  // Kept temporarily for compatibility with the previous asset-first flow.
  // ignore: unused_element
  Future<void> _newChecklist() async {
    try {
      final assets = await widget.dependencies.checklistRepository.listAssets();
      if (!mounted) return;
      if (assets.isEmpty) {
        setState(
          () => _message =
              'Nenhum veículo ou equipamento foi baixado. Sincronize com internet.',
        );
        return;
      }
      final asset = await showModalBottomSheet<AssetSummary>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => _AssetPicker(assets: assets),
      );
      if (asset == null || !mounted) return;
      final templates = await widget.dependencies.checklistService.templatesFor(
        asset,
      );
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
    final pending =
        widget.dependencies.syncCoordinator.snapshot.value.pendingCount;
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

  Future<void> _newChecklistFromForm({
    String? templateId,
    int? templateVersionNumber,
  }) async {
    try {
      final templates = await widget.dependencies.checklistService
          .availableTemplates();
      if (!mounted) return;
      if (templates.isEmpty) {
        setState(
          () => _message =
              'Nenhum formulário publicado foi baixado. Sincronize com internet.',
        );
        return;
      }
      TemplateChoice? template;
      if (templateId != null) {
        for (final choice in templates) {
          if (choice.templateId == templateId &&
              (templateVersionNumber == null ||
                  choice.versionNumber == templateVersionNumber)) {
            template = choice;
            break;
          }
        }
        if (template == null) {
          setState(
            () => _message =
                'Este formulário não está mais disponível neste aparelho.',
          );
          return;
        }
      } else {
        template = await showModalBottomSheet<TemplateChoice>(
          context: context,
          showDragHandle: true,
          isScrollControlled: true,
          builder: (context) => _AllTemplatePicker(choices: templates),
        );
      }
      if (template == null || !mounted) return;
      final selectedTemplate = template;
      final allAssets = await widget.dependencies.checklistRepository
          .listAssets();
      final assets = allAssets
          .where((asset) => asset.kind == selectedTemplate.assetKind)
          .toList(growable: false);
      if (!mounted) return;
      final asset = await showModalBottomSheet<AssetSummary>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => _AssetPickerWithCreate(
          assets: assets,
          template: selectedTemplate,
          dependencies: widget.dependencies,
        ),
      );
      if (asset == null || !mounted) return;
      setState(() => _creatingChecklist = true);
      final assigned = await widget.dependencies.checklistRepository
          .listTemplateChoices(asset.id);
      if (!assigned.any(
        (choice) => choice.templateId == selectedTemplate.templateId,
      )) {
        await widget.dependencies.registryApi.assignTemplate(
          assetId: asset.id,
          template: selectedTemplate,
        );
        await widget.dependencies.syncCoordinator.bootstrap();
      }
      final weekId = await widget.dependencies.checklistService.openWeek(
        asset: asset,
        template: selectedTemplate,
        localDate: DateTime.now(),
      );
      if (!mounted) return;
      setState(() => _creatingChecklist = false);
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
    } finally {
      if (mounted && _creatingChecklist) {
        setState(() => _creatingChecklist = false);
      }
    }
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
      onPressed: _creatingChecklist ? null : () => _newChecklistFromForm(),
      icon: const Icon(Icons.add),
      label: const Text('Novo Formulário'),
    ),
    body: Stack(
      children: [
        StreamBuilder<List<WeeklyChecklistCard>>(
          stream: widget.dependencies.checklistRepository
              .watchWeeklyChecklists(),
          builder: (context, snapshot) {
            final weeks = snapshot.data ?? const [];
            final groups = groupWeeklyForms(weeks);
            return RefreshIndicator(
              onRefresh: widget.dependencies.syncCoordinator.syncNow,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 112),
                children: [
                  SyncBanner(coordinator: widget.dependencies.syncCoordinator),
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
                          'Formulários da semana',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      Text(
                        '${groups.length} formulário(s)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: FieldColors.notApplicable,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Abra um formulário para ver os veículos vinculados.',
                    style: TextStyle(color: FieldColors.notApplicable),
                  ),
                  const SizedBox(height: 16),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.all(36),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (groups.isEmpty)
                    const _EmptyWeeks()
                  else
                    for (final group in groups) ...[
                      _WeeklyFormCard(
                        group: group,
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => TemplateWeekScreen(
                                dependencies: widget.dependencies,
                                group: group,
                                onNewForm: () => _newChecklistFromForm(
                                  templateId: group.templateId,
                                  templateVersionNumber:
                                      group.templateVersionNumber,
                                ),
                              ),
                            ),
                          );
                          if (mounted) setState(() {});
                        },
                      ),
                      const SizedBox(height: 12),
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
        if (_creatingChecklist)
          const Positioned.fill(child: _ChecklistCreationSkeleton()),
      ],
    ),
  );
}

class _WeeklyFormCard extends StatelessWidget {
  const _WeeklyFormCard({required this.group, required this.onTap});

  final WeeklyFormGroup group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final period =
        '${DateFormat('dd/MM').format(group.weekStartDate)} — ${DateFormat('dd/MM').format(group.weekEndDate)}';
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
                    child: const Icon(
                      Icons.assignment_outlined,
                      color: FieldColors.steel,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.templateDisplayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '$period · versão ${group.templateVersionNumber}',
                          style: const TextStyle(
                            color: FieldColors.notApplicable,
                          ),
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
                      value: '${group.vehicleCount}',
                      label: 'veículos',
                    ),
                  ),
                  Expanded(
                    child: _Metric(
                      value: '${group.completedCount}/${group.inspectionCount}',
                      label: 'datas concluídas',
                    ),
                  ),
                  StateBadge(
                    label: group.hasPendingSync ? 'Pendente' : 'Enviado',
                    icon: group.hasPendingSync
                        ? Icons.outbox_outlined
                        : Icons.cloud_done_outlined,
                    tone: group.hasPendingSync
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

class _ChecklistCreationSkeleton extends StatelessWidget {
  const _ChecklistCreationSkeleton();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: SafeArea(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          Row(
            children: [
              const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Preparando checklist…',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Carregando o formulário e os dados do veículo.',
            style: TextStyle(color: FieldColors.notApplicable),
          ),
          const SizedBox(height: 24),
          const _SkeletonBlock(height: 22, widthFactor: .62),
          const SizedBox(height: 18),
          for (var index = 0; index < 3; index++) ...[
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBlock(height: 18, widthFactor: .74),
                    SizedBox(height: 12),
                    _SkeletonBlock(height: 13),
                    SizedBox(height: 8),
                    _SkeletonBlock(height: 13, widthFactor: .55),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    ),
  );
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.height, this.widthFactor = 1});

  final double height;
  final double widthFactor;

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    alignment: Alignment.centerLeft,
    widthFactor: widthFactor,
    child: Container(
      height: height,
      decoration: BoxDecoration(
        color: FieldColors.steelSoft,
        borderRadius: BorderRadius.circular(8),
      ),
    ),
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
          const Icon(
            Icons.calendar_view_week_outlined,
            size: 42,
            color: FieldColors.steel,
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhuma semana aberta',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'Use “Novo Formulário” para selecionar um formulário e um veículo.',
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
          Text(
            'Selecione o ativo',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
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
                  leading: Icon(
                    asset.kind == 'VEHICLE'
                        ? Icons.directions_car_outlined
                        : Icons.precision_manufacturing_outlined,
                  ),
                  title: Text(
                    asset.displayTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(asset.displaySubtitle),
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
          Text(
            'Selecione o modelo',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
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

class _AssetPickerWithCreate extends StatefulWidget {
  const _AssetPickerWithCreate({
    required this.assets,
    required this.template,
    required this.dependencies,
  });

  final List<AssetSummary> assets;
  final TemplateChoice template;
  final AppDependencies dependencies;

  @override
  State<_AssetPickerWithCreate> createState() => _AssetPickerWithCreateState();
}

class _AssetPickerWithCreateState extends State<_AssetPickerWithCreate> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAssets = filterAssets(widget.assets, _searchController.text);
    final isVehicle = widget.template.assetKind == 'VEHICLE';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .72,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isVehicle ? 'Selecione o veículo' : 'Selecione o equipamento',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                widget.template.displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: isVehicle
                      ? 'Buscar veículo'
                      : 'Buscar equipamento',
                  hintText: isVehicle
                      ? 'Digite o código, placa ou descrição'
                      : 'Digite o código ou descrição',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpar busca',
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final created = await showModalBottomSheet<AssetSummary>(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (_) => AssetForm(
                      dependencies: widget.dependencies,
                      template: widget.template,
                    ),
                  );
                  if (created != null && context.mounted) {
                    Navigator.pop(context, created);
                  }
                },
                icon: const Icon(Icons.add),
                label: Text(
                  isVehicle
                      ? 'Cadastrar novo veículo'
                      : 'Cadastrar novo equipamento',
                ),
              ),
              const SizedBox(height: 12),
              if (widget.assets.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Text(
                    'Nenhum cadastro compatível. Use a opção acima para adicionar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: FieldColors.notApplicable),
                  ),
                )
              else if (filteredAssets.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Text(
                    'Nenhum ${isVehicle ? 'veículo' : 'equipamento'} encontrado para “${_searchController.text.trim()}”.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: FieldColors.notApplicable),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: filteredAssets.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final asset = filteredAssets[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          asset.kind == 'VEHICLE'
                              ? Icons.directions_car_outlined
                              : Icons.precision_manufacturing_outlined,
                        ),
                        title: Text(
                          asset.displayTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          asset.displaySubtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pop(context, asset),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllTemplatePicker extends StatelessWidget {
  const _AllTemplatePicker({required this.choices});
  final List<TemplateChoice> choices;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .72,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Selecione o formulário',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            const Text('Todos os modelos publicados e ativos.'),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: choices.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final choice = choices[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      choice.assetKind == 'VEHICLE'
                          ? Icons.directions_car_outlined
                          : Icons.precision_manufacturing_outlined,
                    ),
                    title: Text(
                      choice.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text('Versão ${choice.versionNumber}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pop(context, choice),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
