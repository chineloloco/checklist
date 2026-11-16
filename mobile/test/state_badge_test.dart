import 'package:checklist_mobile/core/widgets/state_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('nome longo ocupa duas linhas sem overflow', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: StateBadge(
              label: 'Veículo de transporte de combustíveis · versão 123456',
              icon: Icons.lock_outline,
              maxWidth: 240,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Veículo de transporte'), findsOneWidget);
  });
}
