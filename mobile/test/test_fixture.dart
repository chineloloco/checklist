import 'dart:convert';
import 'dart:io';

import 'package:checklist_mobile/features/checklists/data/drift_checklist_repository.dart';
import 'package:checklist_mobile/features/checklists/data/local/app_database.dart';
import 'package:checklist_mobile/features/checklists/domain/checklist_models.dart';

const templateId = '10000000-0000-4000-8000-000000000001';
const versionId = '10000000-0000-4000-8000-000000000002';
const sectionId = '10000000-0000-4000-8000-000000000003';
const assetId = '10000000-0000-4000-8000-000000000004';
const configId = '10000000-0000-4000-8000-000000000005';

Future<List<Map<String, Object?>>> realVlItems() async {
  final catalog = (jsonDecode(
    await File('assets/template-catalog.json').readAsString(),
  ) as Map)
      .cast<String, Object?>();
  final templates = (catalog['templates']! as List).cast<Map>();
  final vl = templates
      .map((item) => item.cast<String, Object?>())
      .singleWhere((item) => item['code'] == 'VL');
  final sections = (vl['sections']! as List).cast<Map>();
  final items = (sections.single['items']! as List).cast<Map>();
  return [
    for (var index = 0; index < items.length; index++)
      {
        'id': '20000000-0000-4000-8000-${index.toString().padLeft(12, '0')}',
        'sourcePrintedNumber': items[index]['printed_number'],
        'text': items[index]['text'],
        'order': index,
        'requiredOnComplete': true,
        'requireObservationWhenNc': false,
        'requirePhotoWhenNc': false,
      },
  ];
}

Future<void> seedVlBootstrap(DriftChecklistRepository repository) async {
  final items = await realVlItems();
  await repository.applyBootstrap({
    'serverTime': DateTime.now().toUtc().toIso8601String(),
    'cursor': '10',
    'timezone': 'America/Fortaleza',
    'weekStartsOn': 'MONDAY',
    'templateVersions': [
      {
        'id': versionId,
        'templateId': templateId,
        'versionNumber': 1,
        'status': 'PUBLISHED',
        'revision': 1,
        'checksum': 'sha256:test-vl',
        'publishedAt': DateTime.now().toUtc().toIso8601String(),
        'sections': [
          {
            'id': sectionId,
            'title': 'Itens gerais',
            'order': 0,
            'items': items,
          },
        ],
      },
    ],
    'assets': [
      {
        'id': assetId,
        'kind': 'VEHICLE',
        'code': 'VL-017',
        'active': true,
        'revision': 1,
        'siteId': null,
        'licensePlate': 'ABC1D23',
        'makeModel': 'Veículo leve',
        'manufacturer': null,
        'manufactureYear': 2022,
        'predominantColor': 'Branco',
        'ownershipType': 'OWN',
      },
    ],
    'operationConfigs': [
      {
        'id': configId,
        'templateId': templateId,
        'timezone': 'America/Fortaleza',
        'weekStartsOn': 'MONDAY',
        'requiredWeekdays': ['MONDAY', 'WEDNESDAY', 'FRIDAY'],
        'maxOccurrencesPerDate': 1,
      },
    ],
    'tombstones': <Object?>[],
  });
}

const identification = IdentificationSnapshot(
  company: 'Empresa Exemplo',
  site: 'Pátio Norte',
  assetCode: 'VL-017',
  ownershipType: 'OWN',
  responsiblePersonName: 'João da Silva',
  manufactureYear: 2022,
  predominantColor: 'Branco',
  licensePlate: 'ABC1D23',
  vehicleMakeModel: 'Veículo leve',
  driverLicenseNumber: '00000000000',
  driverLicenseExpiryDate: '2028-05-20',
);

Future<({String weekId, String firstId, String secondId})> createTwoDates(
  AppDatabase database,
  DriftChecklistRepository repository,
) async {
  await seedVlBootstrap(repository);
  final asset = (await repository.listAssets()).single;
  final template = (await repository.listTemplateChoices(asset.id)).single;
  final weekId = await repository.openWeeklyChecklist(
    assetId: asset.id,
    template: template,
    localDate: DateTime(2026, 11, 10),
  );
  final firstId = await repository.openInspection(
    weeklyChecklistId: weekId,
    localDate: DateTime(2026, 11, 10),
    identification: identification,
  );
  final secondId = await repository.openInspection(
    weeklyChecklistId: weekId,
    localDate: DateTime(2026, 11, 12),
    identification: identification,
  );
  return (weekId: weekId, firstId: firstId, secondId: secondId);
}
