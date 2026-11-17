import 'package:checklist_mobile/features/checklists/domain/checklist_models.dart';
import 'package:checklist_mobile/features/checklists/domain/checklist_repository.dart';
import 'package:checklist_mobile/features/checklists/presentation/inspection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  testWidgets('rola suavemente ao selecionar uma resposta', (tester) async {
    final repository = _InspectionRepository(_draft(result: null));
    await tester.pumpWidget(
      MaterialApp(
        home: InspectionScreen(repository: repository, inspectionId: 'i-1'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('C'));
    await tester.pumpAndSettle();
    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    final before = scrollable.position.pixels;
    await tester.tap(find.text('C'));
    await tester.pumpAndSettle();
    expect(repository.savedResult, InspectionResult.compliant);
    expect(scrollable.position.pixels, greaterThan(before));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tocar na resposta selecionada remove a seleção', (tester) async {
    final repository = _InspectionRepository(_draft());
    await tester.pumpWidget(
      MaterialApp(
        home: InspectionScreen(repository: repository, inspectionId: 'i-1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sem resposta'), findsNothing);
    await tester.tap(find.text('C'));
    await tester.pump();

    expect(repository.savedResult, isNull);
    expect(repository.saveCalls, 1);
  });

  testWidgets('salvar observação fecha o diálogo sem erro de dependentes', (
    tester,
  ) async {
    final repository = _InspectionRepository(_draft(result: null));
    await tester.pumpWidget(
      MaterialApp(
        home: InspectionScreen(repository: repository, inspectionId: 'i-1'),
      ),
    );
    await tester.pumpAndSettle();

    final addObservation = find.text('Adicionar observação');
    await tester.ensureVisible(addObservation);
    await tester.pumpAndSettle();
    await tester.tap(addObservation);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Ruído no rolamento');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(repository.savedObservation, 'Ruído no rolamento');
    expect(tester.takeException(), isNull);
  });

  testWidgets('permite a desativação de formulário não enviado', (
    tester,
  ) async {
    final repository = _InspectionRepository(_draft());
    await tester.pumpWidget(
      MaterialApp(
        home: InspectionScreen(repository: repository, inspectionId: 'i-1'),
      ),
    );
    await tester.pumpAndSettle();

    final delete = find.text('Desativar formulário não enviado');
    await tester.scrollUntilVisible(delete, 400);
    await tester.tap(delete);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Desativar'));
    await tester.pumpAndSettle();
    expect(repository.deleted, isTrue);
  });
}

InspectionDraft _draft({
  InspectionResult? result = InspectionResult.compliant,
}) => InspectionDraft(
  id: 'i-1',
  weeklyChecklistId: 'w-1',
  localDate: DateTime(2026, 11, 15),
  occurrenceNo: 1,
  lifecycle: InspectionLifecycle.draft,
  syncState: LocalSyncState.localOnly,
  identification: const IdentificationSnapshot(
    company: 'Empresa',
    site: 'Local',
    assetCode: 'VL-01',
    ownershipType: 'OWN',
    responsiblePersonName: 'Motorista',
  ),
  items: [
    ChecklistItem(
      id: 'item-1',
      sectionId: 'section-1',
      sectionTitle: 'Segurança',
      text: 'Estado dos pneus',
      order: 0,
      requiredOnComplete: true,
      requireObservationWhenNc: false,
      requirePhotoWhenNc: false,
      result: result,
    ),
  ],
  templateVersionNumber: 1,
  templateDisplayName: 'VL · Veículo',
);

final class _InspectionRepository implements ChecklistRepository {
  _InspectionRepository(this.draft);

  final InspectionDraft draft;
  int saveCalls = 0;
  InspectionResult? savedResult;
  String? savedObservation;
  bool deleted = false;

  @override
  Stream<InspectionDraft> watchInspection(String inspectionId) =>
      Stream.value(draft);

  @override
  Future<void> saveAnswer({
    required String inspectionId,
    required String itemId,
    required InspectionResult? result,
    String? observation,
  }) async {
    saveCalls++;
    savedResult = result;
    savedObservation = observation;
  }

  @override
  Future<void> deactivateUnsyncedInspection(String inspectionId) async {
    deleted = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
