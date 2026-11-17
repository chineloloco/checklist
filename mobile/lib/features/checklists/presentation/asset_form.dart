import 'package:flutter/material.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/checklist_models.dart';
import 'registry_picker.dart';

class AssetForm extends StatefulWidget {
  const AssetForm({
    required this.dependencies,
    required this.template,
    super.key,
  });

  final AppDependencies dependencies;
  final TemplateChoice template;

  @override
  State<AssetForm> createState() => _AssetFormState();
}

class _AssetFormState extends State<AssetForm> {
  final _code = TextEditingController();
  final _description = TextEditingController();
  final _plate = TextEditingController();
  RegistryCompany? _company;
  RegistrySite? _site;
  String _ownership = 'OWN';
  bool _saving = false;
  bool _showValidation = false;
  String? _apiError;

  @override
  void dispose() {
    _code.dispose();
    _description.dispose();
    _plate.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_company == null ||
        _code.text.trim().isEmpty ||
        _description.text.trim().isEmpty) {
      setState(() => _showValidation = true);
      return;
    }
    setState(() {
      _saving = true;
      _apiError = null;
    });
    try {
      final asset = await widget.dependencies.registryApi.createAsset(
        companyId: _company!.id,
        siteId: _site?.id,
        kind: widget.template.assetKind,
        code: _code.text.trim(),
        description: _description.text.trim(),
        ownershipType: _ownership,
        template: widget.template,
        licensePlate: _plate.text,
      );
      if (mounted) Navigator.pop(context, asset);
    } on AppFailure catch (error) {
      if (mounted) setState(() => _apiError = error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.template.assetKind == 'VEHICLE';
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                vehicle ? 'Novo veículo' : 'Novo equipamento',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text('Será vinculado a ${widget.template.displayName}.'),
              const SizedBox(height: 18),
              RegistrySelectionTile(
                label: 'Empresa *',
                value: _company?.name,
                icon: Icons.business_outlined,
                onTap: _selectCompany,
                errorText: _showValidation && _company == null
                    ? 'Selecione uma empresa.'
                    : null,
              ),
              const SizedBox(height: 12),
              RegistrySelectionTile(
                label: 'Local',
                value: _site?.name,
                icon: Icons.location_on_outlined,
                onTap: _selectSite,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _code,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Código',
                  errorText: _showValidation && _code.text.trim().isEmpty
                      ? 'Informe o código.'
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _description,
                decoration: InputDecoration(
                  labelText: vehicle ? 'Marca e modelo' : 'Fabricante',
                  errorText: _showValidation && _description.text.trim().isEmpty
                      ? 'Preencha este campo.'
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
              if (vehicle) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _plate,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Placa (opcional)',
                  ),
                ),
              ],
              if (_apiError != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: FieldColors.nonCompliantSoft,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: FieldColors.nonCompliant),
                  ),
                  child: Text(
                    _apiError!,
                    style: const TextStyle(color: FieldColors.nonCompliant),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _ownership,
                decoration: const InputDecoration(labelText: 'Propriedade'),
                items: const [
                  DropdownMenuItem(value: 'OWN', child: Text('Próprio')),
                  DropdownMenuItem(
                    value: 'THIRD_PARTY',
                    child: Text('Terceiro'),
                  ),
                ],
                onChanged: (value) => _ownership = value ?? 'OWN',
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: Text(
                  _saving ? 'Cadastrando…' : 'Cadastrar e selecionar',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectCompany() async {
    final value = await pickCompany(context, widget.dependencies.registryApi);
    if (value != null && mounted) {
      setState(() {
        _company = value;
        if (_site != null &&
            _site!.companyId.isNotEmpty &&
            _site!.companyId != value.id) {
          _site = null;
        }
      });
    }
  }

  Future<void> _selectSite() async {
    final value = await pickSite(
      context,
      widget.dependencies.registryApi,
      _company,
    );
    if (value != null && mounted) {
      setState(() {
        _site = value.site;
        _company = value.company ?? _company;
      });
    }
  }
}
