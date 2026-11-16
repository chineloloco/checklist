import 'package:checklist_mobile/features/checklists/domain/checklist_models.dart';
import 'package:checklist_mobile/features/checklists/presentation/weekly_form_group.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('agrupa os veículos pelo formulário e pela semana', () {
    final monday = DateTime(2026, 11, 9);
    final groups = groupWeeklyForms([
      _week(id: '1', assetCode: 'VL-001', weekStart: monday),
      _week(id: '2', assetCode: 'VL-002', weekStart: monday),
      _week(
        id: '3',
        assetCode: 'VL-003',
        weekStart: monday.add(const Duration(days: 7)),
      ),
    ]);

    expect(groups, hasLength(2));
    expect(groups.first.vehicleCount, 1);
    expect(groups.last.vehicleCount, 2);
    expect(groups.last.weeks.map((week) => week.asset.code), [
      'VL-001',
      'VL-002',
    ]);
  });
}

WeeklyChecklistCard _week({
  required String id,
  required String assetCode,
  required DateTime weekStart,
}) => WeeklyChecklistCard(
  id: id,
  asset: AssetSummary(
    id: 'asset-$id',
    kind: 'VEHICLE',
    code: assetCode,
    active: true,
  ),
  weekStartDate: weekStart,
  templateId: 'template-vl',
  templateVersionNumber: 1,
  templateDisplayName: 'Veículos leves',
  syncState: LocalSyncState.synced,
  inspections: const [],
);
