import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sci_calc_pro/main.dart' as app;

// Integration tests drive the real app on a device/emulator.
// Run with: flutter test integration_test/app_test.dart -d <device>
//
// Each test taps actual buttons and verifies what the display shows.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Helper: tap a button by its visible label text.
  // Searches only inside GestureDetector widgets to avoid matching
  // the display text when the display happens to show the same value.
  Future<void> tap(WidgetTester tester, String label) async {
    final btn = find.descendant(
      of: find.byType(GestureDetector),
      matching: find.text(label),
    );
    expect(btn, findsWidgets,
        reason: 'Button "$label" not found on screen');
    await tester.tap(btn.first);
    await tester.pump();
  }

  group('calculator app', () {
    testWidgets('app launches and shows 0', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      expect(find.text('0'), findsWidgets);
    });

    testWidgets('2 + 3 = 5', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tap(tester, '2');
      await tap(tester, '+');
      await tap(tester, '3');
      await tap(tester, '=');
      await tester.pumpAndSettle();

      expect(find.text('5'), findsWidgets);
    });

    testWidgets('9 × 9 = 81', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tap(tester, '9');
      await tap(tester, '×');
      await tap(tester, '9');
      await tap(tester, '=');
      await tester.pumpAndSettle();

      expect(find.text('81'), findsWidgets);
    });

    testWidgets('AC resets display to 0', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tap(tester, '5');
      await tap(tester, '+');
      await tap(tester, '3');
      await tap(tester, 'AC');
      await tester.pumpAndSettle();

      expect(find.text('0'), findsWidgets);
    });

    testWidgets('backspace removes last digit', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tap(tester, '1');
      await tap(tester, '2');
      await tap(tester, '3');
      await tap(tester, '⌫');
      await tester.pumpAndSettle();

      expect(find.text('12'), findsWidgets);
    });

    testWidgets('division by zero shows error', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tap(tester, '5');
      await tap(tester, '÷');
      await tap(tester, '0');
      await tap(tester, '=');
      await tester.pumpAndSettle();

      expect(find.text('Sıfıra bölme'), findsOneWidget);
    });

    testWidgets('memory: M+ then MR recalls value', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tap(tester, '7');
      await tap(tester, 'M+');
      await tap(tester, 'AC');
      await tap(tester, 'MR');
      await tester.pumpAndSettle();

      expect(find.text('7'), findsWidgets);
    });
  });
}
