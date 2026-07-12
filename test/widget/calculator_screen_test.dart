import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sci_calc_pro/screens/calculator_screen.dart';
import 'package:sci_calc_pro/theme/app_theme.dart';

void main() {
  Widget wrap() {
    return MaterialApp(
      theme: AppTheme.dark(),
      home: const CalculatorScreen(),
    );
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.tap(find.text(key).first);
    await tester.pumpAndSettle();
  }

  group('CalculatorScreen', () {
    testWidgets('CE clears current entry but keeps pending operation', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());

      await tapKey(tester, '5');
      await tapKey(tester, '+');
      await tapKey(tester, '3');
      await tapKey(tester, 'CE');
      await tapKey(tester, '2');
      await tapKey(tester, '=');

      expect(find.bySemanticsLabel('Sonuç: 7'), findsOneWidget);
    });

    testWidgets('ANS recalls the last equals result', (tester) async {
      await tester.pumpWidget(wrap());

      await tapKey(tester, '2');
      await tapKey(tester, '+');
      await tapKey(tester, '3');
      await tapKey(tester, '=');
      await tapKey(tester, 'AC');
      await tapKey(tester, 'ANS');

      expect(find.bySemanticsLabel('Sonuç: 5'), findsOneWidget);
    });

    testWidgets('constant input does not overwrite ANS', (tester) async {
      await tester.pumpWidget(wrap());

      await tapKey(tester, '4');
      await tapKey(tester, '+');
      await tapKey(tester, '1');
      await tapKey(tester, '=');
      await tapKey(tester, 'π');
      await tapKey(tester, 'AC');
      await tapKey(tester, 'ANS');

      expect(find.bySemanticsLabel('Sonuç: 5'), findsOneWidget);
    });

    testWidgets('ANS recalls unary result after clear', (tester) async {
      await tester.pumpWidget(wrap());

      await tapKey(tester, '9');
      await tapKey(tester, 'x²');
      await tapKey(tester, 'AC');
      await tapKey(tester, 'ANS');

      expect(find.bySemanticsLabel('Sonuç: 81'), findsOneWidget);
    });
  });
}
