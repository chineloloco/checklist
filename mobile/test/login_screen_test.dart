import 'package:checklist_mobile/core/config/app_config.dart';
import 'package:checklist_mobile/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('entra com matrícula e preserva os zeros iniciais', (
    tester,
  ) async {
    String? submittedNumber;
    String? submittedPassword;
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          config: const AppConfig(apiBaseUrl: 'http://test.local'),
          onSignIn: (number, password) async {
            submittedNumber = number;
            submittedPassword = password;
          },
        ),
      ),
    );
    final fields = find.byType(TextFormField);
    expect(find.text('Matrícula'), findsOneWidget);
    expect(find.text('E-mail'), findsNothing);
    await tester.enterText(fields.at(0), '001234');
    await tester.enterText(fields.at(1), 'senha-de-teste');
    final enter = find.widgetWithText(FilledButton, 'Entrar');
    await tester.ensureVisible(enter);
    await tester.tap(enter);
    await tester.pumpAndSettle();
    expect(submittedNumber, '001234');
    expect(submittedPassword, 'senha-de-teste');
  });
}
