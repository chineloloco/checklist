import 'dart:io';

import 'package:checklist_mobile/features/checklists/data/drift_checklist_repository.dart';
import 'package:checklist_mobile/features/checklists/data/local/app_database.dart';
import 'package:checklist_mobile/features/checklists/domain/checklist_models.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_fixture.dart';

void main() {
  test('mantém duas datas offline independentes e fixa a versão VL', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftChecklistRepository(database);
    final ids = await createTwoDates(database, repository);

    final first = await repository.getInspection(ids.firstId);
    final second = await repository.getInspection(ids.secondId);
    expect(first.items, hasLength(34));
    expect(first.items.first.text, 'Carteira de habilitação');
    expect(first.items.last.text, 'Vazamentos');
    expect(first.templateVersionNumber, 1);

    await repository.saveAnswer(
      inspectionId: ids.firstId,
      itemId: first.items.first.id,
      result: InspectionResult.compliant,
    );
    await repository.saveAnswer(
      inspectionId: ids.secondId,
      itemId: second.items.first.id,
      result: InspectionResult.nonCompliant,
      observation: 'Documento ausente no segundo dia.',
    );

    final reloadedFirst = await repository.getInspection(ids.firstId);
    final reloadedSecond = await repository.getInspection(ids.secondId);
    expect(reloadedFirst.items.first.result, InspectionResult.compliant);
    expect(reloadedSecond.items.first.result, InspectionResult.nonCompliant);
    expect(reloadedSecond.items.first.observation, contains('segundo dia'));
  });

  test('preserva a versão fixada quando uma versão nova é baixada', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftChecklistRepository(database);
    final ids = await createTwoDates(database, repository);
    final sourceItems = await realVlItems();
    final items = [
      for (var index = 0; index < sourceItems.length; index++)
        {
          ...sourceItems[index],
          'id': '30000000-0000-4000-8000-${index.toString().padLeft(12, '0')}',
        },
    ];

    await repository.applyBootstrap({
      'cursor': '11',
      'templateVersions': [
        {
          'id': '10000000-0000-4000-8000-000000000012',
          'templateId': templateId,
          'versionNumber': 2,
          'status': 'PUBLISHED',
          'revision': 2,
          'sections': [
            {
              'id': '10000000-0000-4000-8000-000000000013',
              'title': 'Itens gerais',
              'order': 0,
              'items': items,
            },
          ],
        },
      ],
      'assets': <Object?>[],
      'operationConfigs': <Object?>[],
      'tombstones': <Object?>[],
    });

    final currentChoice =
        (await repository.listTemplateChoices(assetId)).single;
    final existingInspection = await repository.getInspection(ids.firstId);
    expect(currentChoice.versionNumber, 2);
    expect(existingInspection.templateVersionNumber, 1);
    expect(existingInspection.items, hasLength(34));
  });

  test('recupera rascunho e outbox depois de reiniciar', () async {
    final temp = await Directory.systemTemp.createTemp('checklist-mobile-test-');
    addTearDown(() => temp.delete(recursive: true));
    final file = File('${temp.path}/offline.sqlite');

    var database = AppDatabase(NativeDatabase(file));
    var repository = DriftChecklistRepository(database);
    final ids = await createTwoDates(database, repository);
    final draft = await repository.getInspection(ids.firstId);
    await repository.saveAnswer(
      inspectionId: ids.firstId,
      itemId: draft.items[4].id,
      result: InspectionResult.notApplicable,
    );
    final pendingBefore = await database.select(database.syncOutboxOperations).get();
    expect(pendingBefore, isNotEmpty);
    await database.close();

    database = AppDatabase(NativeDatabase(file));
    repository = DriftChecklistRepository(database);
    addTearDown(database.close);
    final restored = await repository.getInspection(ids.firstId);
    final pendingAfter = await database.select(database.syncOutboxOperations).get();
    expect(restored.items[4].result, InspectionResult.notApplicable);
    expect(pendingAfter.map((item) => item.operationId),
        containsAll(pendingBefore.map((item) => item.operationId)));
  });
}
