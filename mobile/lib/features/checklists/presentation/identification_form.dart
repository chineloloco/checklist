import 'package:flutter/material.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/checklist_models.dart';
import 'asset_display.dart';
import 'registry_picker.dart';

class IdentificationForm extends StatefulWidget {
  const IdentificationForm({
    required this.asset,
    required this.dependencies,
    super.key,
  });

  final AssetSummary asset;
  final AppDependencies dependencies;

  @override
  State<IdentificationForm> createState() => _IdentificationFormState();
}

class _IdentificationFormState extends State<IdentificationForm> {
  RegistryCompany? _company;
  RegistrySite? _site;
  RegistryPerson? _person;
  bool _showValidation = false;

  void _submit() {
    if (_site == null || _person == null) {
      setState(() => _showValidation = true);
      return;
    }
    Navigator.pop(
      context,
      IdentificationSnapshot(
        company: _company!.name,
        site: _site!.name,
        assetCode: widget.asset.code,
        ownershipType: widget.asset.ownershipType,
        responsiblePersonName: _person!.name,
        responsiblePersonId: _person!.id,
        manufactureYear: widget.asset.manufactureYear,
        predominantColor: widget.asset.predominantColor,
        licensePlate: widget.asset.licensePlate,
        vehicleMakeModel: widget.asset.makeModel,
        manufacturer: widget.asset.manufacturer,
        driverLicenseNumber: _person!.driverLicenseNumber,
        driverLicenseExpiryDate: _person!.driverLicenseExpiryDate,
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
          RegistrySelectionTile(
            label: 'Local',
            value: _site?.name,
            icon: Icons.location_on_outlined,
            onTap: _selectSite,
            errorText: _showValidation && _site == null
                ? 'Selecione um local.'
                : null,
          ),
          const SizedBox(height: 12),
          RegistrySelectionTile(
            label: 'Motorista ou operador',
            value: _person?.name,
            icon: Icons.badge_outlined,
            onTap: _selectPerson,
            errorText: _showValidation && _person == null
                ? 'Selecione um motorista ou operador.'
                : null,
          ),
          const SizedBox(height: 14),
          const Text(
            'Toque em cada campo para escolher um cadastro existente ou criar um novo.',
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
  );

  Future<void> _selectSite() async {
    final value = await pickSite(context, widget.dependencies.registryApi);
    if (value != null && mounted) {
      setState(() {
        _site = value.site;
        _company = value.company;
      });
    }
  }

  Future<void> _selectPerson() async {
    final value = await pickPerson(context, widget.dependencies.registryApi);
    if (value != null && mounted) setState(() => _person = value);
  }
}
