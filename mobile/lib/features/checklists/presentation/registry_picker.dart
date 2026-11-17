import 'package:flutter/material.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/input/brazilian_date_input.dart';
import '../../../core/input/search_text.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/keyboard_aware_sheet.dart';
import '../data/remote/registry_api.dart';
import '../domain/checklist_models.dart';

Future<RegistryCompany?> pickCompany(
  BuildContext context,
  RegistryApi api,
) async {
  final items = await _guard(context, () => api.companies(localOnly: true));
  if (items == null) return null;
  final offline = api.lastReadUsedCache;
  if (!context.mounted) return null;
  return _pick<RegistryCompany>(
    context,
    title: 'Empresa',
    items: items,
    label: (item) => item.name,
    createLabel: 'Cadastrar nova empresa',
    offline: offline,
    onCreate: () => _createCompany(context, api),
  );
}

final class RegistrySiteChoice {
  const RegistrySiteChoice({required this.site, required this.company});

  final RegistrySite site;
  final RegistryCompany? company;
}

Future<RegistrySiteChoice?> pickSite(
  BuildContext context,
  RegistryApi api, [
  RegistryCompany? company,
]) async {
  final all = await _guard(context, () => api.sites(localOnly: true));
  if (all == null) return null;
  var offline = api.lastReadUsedCache;
  if (!context.mounted) return null;
  final companies = company == null
      ? await _guard(context, () => api.companies(localOnly: true))
      : <RegistryCompany>[company];
  if (companies == null) return null;
  offline = offline || api.lastReadUsedCache;
  if (!context.mounted) return null;
  final companiesById = {for (final item in companies) item.id: item};
  final choices = all
      .where(
        (item) =>
            item.companyId.isEmpty || companiesById.containsKey(item.companyId),
      )
      .map(
        (item) => RegistrySiteChoice(
          site: item,
          company: companiesById[item.companyId] ?? company,
        ),
      )
      .toList(growable: false);
  return _pick<RegistrySiteChoice>(
    context,
    title: company == null ? 'Local' : 'Local de ${company.name}',
    items: choices,
    label: (item) => item.site.name,
    subtitle: company == null
        ? (item) => item.company?.name ?? 'Local compartilhado'
        : null,
    createLabel: 'Cadastrar novo local',
    offline: offline,
    onCreate: () async {
      final site = await _createSite(context, api);
      return site == null
          ? null
          : RegistrySiteChoice(site: site, company: company);
    },
  );
}

Future<RegistryPerson?> pickPerson(
  BuildContext context,
  RegistryApi api,
) async {
  final items = await _guard(context, () => api.people(localOnly: true));
  if (items == null) return null;
  final offline = api.lastReadUsedCache;
  if (!context.mounted) return null;
  return _pick<RegistryPerson>(
    context,
    title: 'Motorista ou operador',
    items: items,
    label: (item) => item.name,
    subtitle: (item) => switch (item.kind) {
      'DRIVER' => 'Motorista',
      'OPERATOR' => 'Operador',
      _ => 'Supervisor',
    },
    createLabel: 'Cadastrar motorista ou operador',
    offline: offline,
    onCreate: () => _createPerson(context, api),
  );
}

Future<T?> _pick<T>(
  BuildContext context, {
  required String title,
  required List<T> items,
  required String Function(T) label,
  required String createLabel,
  required bool offline,
  required Future<T?> Function() onCreate,
  String Function(T)? subtitle,
}) => showModalBottomSheet<T>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (_) => _RegistryPicker<T>(
    title: title,
    items: items,
    label: label,
    subtitle: subtitle,
    createLabel: createLabel,
    offline: offline,
    onCreate: onCreate,
  ),
);

class _RegistryPicker<T> extends StatefulWidget {
  const _RegistryPicker({
    required this.title,
    required this.items,
    required this.label,
    required this.createLabel,
    required this.offline,
    required this.onCreate,
    this.subtitle,
  });

  final String title;
  final List<T> items;
  final String Function(T) label;
  final String Function(T)? subtitle;
  final String createLabel;
  final bool offline;
  final Future<T?> Function() onCreate;

  @override
  State<_RegistryPicker<T>> createState() => _RegistryPickerState<T>();
}

class _RegistryPickerState<T> extends State<_RegistryPicker<T>> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final terms = normalizeSearchText(
      _search.text,
    ).split(RegExp(r'\s+')).where((term) => term.isNotEmpty);
    final items = widget.items
        .where((item) {
          final text = normalizeSearchText(
            '${widget.label(item)} ${widget.subtitle?.call(item) ?? ''}',
          );
          return terms.every(text.contains);
        })
        .toList(growable: false);
    return KeyboardAwareSheet(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: double.infinity),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _search,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: 'Buscar',
                  hintText: 'Digite o nome',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpar busca',
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _search.clear();
                            setState(() {});
                          },
                        ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final created = await widget.onCreate();
                  if (created != null && context.mounted) {
                    Navigator.pop(context, created);
                  }
                },
                icon: const Icon(Icons.add),
                label: Text(widget.createLabel),
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    _search.text.trim().isNotEmpty
                        ? 'Nenhum resultado para esta busca.'
                        : widget.offline
                        ? 'Nenhum cadastro salvo. Use a opção acima para cadastrar offline.'
                        : 'Nenhum cadastro encontrado. Use a opção acima para adicionar.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: FieldColors.notApplicable),
                  ),
                )
              else
                SizedBox(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(widget.label(item)),
                        subtitle: widget.subtitle == null
                            ? null
                            : Text(widget.subtitle!(item)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pop(context, item),
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

Future<RegistryCompany?> _createCompany(
  BuildContext context,
  RegistryApi api,
) async {
  final result = await _showForm(
    context,
    title: 'Nova empresa',
    fields: const [
      _FieldSpec('name', 'Nome da empresa', required: true),
      _FieldSpec('document', 'CNPJ ou documento'),
    ],
  );
  if (result == null || !context.mounted) return null;
  return _guard(
    context,
    () =>
        api.createCompany(name: result['name']!, document: result['document']),
  );
}

Future<RegistrySite?> _createSite(BuildContext context, RegistryApi api) async {
  final result = await _showForm(
    context,
    title: 'Novo local',
    fields: const [_FieldSpec('name', 'Nome do local', required: true)],
  );
  if (result == null || !context.mounted) return null;
  return _guard(context, () => api.createSite(name: result['name']!));
}

Future<RegistryPerson?> _createPerson(BuildContext context, RegistryApi api) =>
    showDialog<RegistryPerson>(
      context: context,
      builder: (context) => _PersonFormDialog(api: api),
    );

class _PersonFormDialog extends StatefulWidget {
  const _PersonFormDialog({required this.api});

  final RegistryApi api;

  @override
  State<_PersonFormDialog> createState() => _PersonFormDialogState();
}

class _PersonFormDialogState extends State<_PersonFormDialog> {
  final _name = TextEditingController();
  final _license = TextEditingController();
  final _expiry = TextEditingController();
  String _kind = 'DRIVER';
  String? _nameError;
  String? _expiryError;
  String? _apiError;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _license.dispose();
    _expiry.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final expiry = _expiry.text.trim();
    final expiryIso = expiry.isEmpty ? null : brazilianDateToIso(expiry);
    setState(() {
      _nameError = _name.text.trim().isEmpty
          ? 'Informe o nome completo.'
          : null;
      _expiryError = optionalBrazilianDateError(expiry);
      _apiError = null;
    });
    if (_nameError != null || _expiryError != null) return;

    setState(() => _saving = true);
    try {
      final created = await widget.api.createPerson(
        name: _name.text.trim(),
        kind: _kind,
        driverLicenseNumber: _license.text,
        driverLicenseExpiryDate: expiryIso,
      );
      if (mounted) Navigator.pop(context, created);
    } on AppFailure catch (error) {
      if (mounted) setState(() => _apiError = error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Novo motorista ou operador'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _kind,
            decoration: const InputDecoration(labelText: 'Função'),
            items: const [
              DropdownMenuItem(value: 'DRIVER', child: Text('Motorista')),
              DropdownMenuItem(value: 'OPERATOR', child: Text('Operador')),
            ],
            onChanged: _saving
                ? null
                : (value) => setState(() => _kind = value ?? 'DRIVER'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            enabled: !_saving,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Nome completo',
              errorText: _nameError,
            ),
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _license,
            enabled: !_saving,
            decoration: const InputDecoration(labelText: 'CNH (opcional)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _expiry,
            enabled: !_saving,
            keyboardType: TextInputType.number,
            inputFormatters: const [BrazilianDateInputFormatter()],
            decoration: InputDecoration(
              labelText: 'Vencimento da CNH',
              hintText: 'DD/MM/AAAA',
              errorText: _expiryError,
            ),
            onChanged: (_) {
              if (_expiryError != null) setState(() => _expiryError = null);
            },
          ),
          if (_apiError != null) ...[
            const SizedBox(height: 12),
            Text(
              _apiError!,
              style: const TextStyle(color: FieldColors.nonCompliant),
            ),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: _saving ? null : _submit,
        child: _saving
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Cadastrar'),
      ),
    ],
  );
}

Future<Map<String, String>?> _showForm(
  BuildContext context, {
  required String title,
  required List<_FieldSpec> fields,
}) {
  final controllers = {
    for (final field in fields) field.key: TextEditingController(),
  };
  var showErrors = false;
  return showDialog<Map<String, String>>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < fields.length; index++) ...[
              if (index > 0) const SizedBox(height: 12),
              TextField(
                controller: controllers[fields[index].key],
                decoration: InputDecoration(
                  labelText: fields[index].label,
                  errorText:
                      showErrors &&
                          fields[index].required &&
                          controllers[fields[index].key]!.text.trim().isEmpty
                      ? 'Campo obrigatório.'
                      : null,
                ),
                onChanged: (_) {
                  if (showErrors) setDialogState(() {});
                },
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (fields.any(
                (field) =>
                    field.required &&
                    controllers[field.key]!.text.trim().isEmpty,
              )) {
                setDialogState(() => showErrors = true);
                return;
              }
              Navigator.pop(context, {
                for (final field in fields)
                  field.key: controllers[field.key]!.text.trim(),
              });
            },
            child: const Text('Cadastrar'),
          ),
        ],
      ),
    ),
  );
}

Future<T?> _guard<T>(BuildContext context, Future<T> Function() action) async {
  try {
    return await action();
  } on AppFailure catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
    return null;
  }
}

final class _FieldSpec {
  const _FieldSpec(this.key, this.label, {this.required = false});
  final String key;
  final String label;
  final bool required;
}

class RegistrySelectionTile extends StatelessWidget {
  const RegistrySelectionTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.errorText,
    super.key,
  });
  final String label;
  final String? value;
  final IconData icon;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) => Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: errorText == null ? FieldColors.line : FieldColors.nonCompliant,
      ),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: FieldColors.steel),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 2),
                  Text(value ?? 'Toque para selecionar ou cadastrar'),
                  if (errorText != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      errorText!,
                      style: const TextStyle(
                        color: FieldColors.nonCompliant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.expand_more),
          ],
        ),
      ),
    ),
  );
}
