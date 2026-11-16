import 'package:checklist_mobile/features/checklists/domain/checklist_models.dart';
import 'package:checklist_mobile/features/checklists/presentation/asset_search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const assets = [
    AssetSummary(
      id: '1',
      kind: 'VEHICLE',
      code: 'VL017',
      active: true,
      licensePlate: 'ABC1D23',
      makeModel: 'Caminhão tanque',
    ),
    AssetSummary(
      id: '2',
      kind: 'VEHICLE',
      code: 'VL042',
      active: true,
      manufacturer: 'Mercedes-Benz',
    ),
  ];

  test('filtra veículo por código, placa e descrição', () {
    expect(filterAssets(assets, '017'), [assets.first]);
    expect(filterAssets(assets, 'abc1'), [assets.first]);
    expect(filterAssets(assets, 'caminhao tanque'), [assets.first]);
    expect(filterAssets(assets, 'mercedes'), [assets.last]);
  });

  test('mantém todos os veículos quando a busca está vazia', () {
    expect(filterAssets(assets, '   '), assets);
  });
}
