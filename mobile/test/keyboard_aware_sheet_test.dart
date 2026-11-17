import 'package:checklist_mobile/core/widgets/keyboard_aware_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('keeps search and results reachable above the keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => KeyboardAwareSheet(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const TextField(
                        decoration: InputDecoration(labelText: 'Buscar'),
                      ),
                      for (var i = 0; i < 20; i++)
                        ListTile(title: Text('Vehicle $i')),
                    ],
                  ),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextField));
    tester.view.viewInsets = const FakeViewPadding(bottom: 350);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      tester.getBottomLeft(find.byType(TextField)).dy,
      lessThanOrEqualTo(350),
    );
    await tester.dragUntilVisible(
      find.text('Vehicle 19'),
      find.byType(SingleChildScrollView),
      const Offset(0, -150),
    );
    expect(
      tester.getBottomLeft(find.text('Vehicle 19')).dy,
      lessThanOrEqualTo(350),
    );
    expect(tester.takeException(), isNull);
  });
}
