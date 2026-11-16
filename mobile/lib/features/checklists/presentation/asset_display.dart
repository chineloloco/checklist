import '../domain/checklist_models.dart';

extension AssetDisplay on AssetSummary {
  String get displayTitle {
    if (kind != 'VEHICLE') return code;

    final brand = manufacturer?.trim() ?? '';
    final model = makeModel?.trim() ?? '';
    if (brand.isEmpty && model.isEmpty) return code;
    if (brand.isEmpty) return model;
    if (model.isEmpty) return brand;
    if (model.toLowerCase().startsWith(brand.toLowerCase())) return model;
    return '$brand $model';
  }

  String get displaySubtitle {
    if (kind != 'VEHICLE') return description;

    final plate = licensePlate?.trim();
    return 'Placa: ${plate == null || plate.isEmpty ? 'Não informada' : plate} · Código: $code';
  }
}
