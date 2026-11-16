import 'package:checklist_mobile/features/checklists/domain/checklist_models.dart';
import 'package:checklist_mobile/features/checklists/presentation/asset_display.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('veículo exibe marca e modelo acima da placa e do código', () {
    const asset = AssetSummary(
      id: '1',
      kind: 'VEHICLE',
      code: 'VL-017',
      active: true,
      licensePlate: 'ABC1D23',
      manufacturer: 'Mercedes-Benz',
      makeModel: 'Accelo 1016',
    );

    expect(asset.displayTitle, 'Mercedes-Benz Accelo 1016');
    expect(asset.displaySubtitle, 'Placa: ABC1D23 · Código: VL-017');
  });

  test('veículo sem marca e modelo usa o código como título', () {
    const asset = AssetSummary(
      id: '1',
      kind: 'VEHICLE',
      code: 'VL-017',
      active: true,
    );

    expect(asset.displayTitle, 'VL-017');
    expect(asset.displaySubtitle, 'Placa: Não informada · Código: VL-017');
  });

  test('equipamento mantém código e descrição atuais', () {
    const asset = AssetSummary(
      id: '2',
      kind: 'EQUIPMENT',
      code: 'EQ-004',
      active: true,
      manufacturer: 'Gerador',
    );

    expect(asset.displayTitle, 'EQ-004');
    expect(asset.displaySubtitle, 'Gerador');
  });
}
