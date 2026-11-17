import 'package:checklist_mobile/core/config/app_config.dart';
import 'package:checklist_mobile/core/network/authenticated_api_client.dart';
import 'package:checklist_mobile/features/auth/domain/auth_session.dart';
import 'package:checklist_mobile/features/checklists/data/local/app_database.dart';
import 'package:checklist_mobile/features/checklists/data/remote/registry_api.dart';
import 'package:checklist_mobile/features/checklists/presentation/registry_picker.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final kind in ['company', 'site', 'person']) {
    testWidgets('busca, limpa e seleciona $kind offline', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final api = RegistryApi(
        AuthenticatedApiClient(
          config: const AppConfig(apiBaseUrl: 'http://unused.test'),
          auth: _Auth(),
        ),
        db,
      );
      await tester.runAsync(() async {
        await api.createCompany(name: 'São José');
        await api.createCompany(name: 'Outra empresa');
        await api.createSite(name: 'São José');
        await api.createSite(name: 'Outro local');
        await api.createPerson(name: 'São José', kind: 'DRIVER');
        await api.createPerson(name: 'Outro motorista', kind: 'DRIVER');
      });
      Object? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  selected = await switch (kind) {
                    'company' => pickCompany(context, api),
                    'site' => pickSite(context, api),
                    _ => pickPerson(context, api),
                  };
                },
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        await tester.tap(find.text('Abrir'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();
      expect(find.text('Buscar'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'SAO jose');
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, 'São José'), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'inexistente');
      await tester.pumpAndSettle();
      expect(find.text('Nenhum resultado para esta busca.'), findsOneWidget);
      await tester.tap(find.byTooltip('Limpar busca'));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(2));
      await tester.tap(find.widgetWithText(ListTile, 'São José'));
      await tester.pumpAndSettle();
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      expect(selected, isNotNull);
      expect(tester.takeException(), isNull);
    });
  }
}

class _Auth implements AuthSessionRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
