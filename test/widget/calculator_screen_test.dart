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
    testWidgets('places memory keys above AC and swaps CE with percent', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: const MediaQuery(
            data: MediaQueryData(size: Size(600, 900)),
            child: CalculatorScreen(),
          ),
        ),
      );

      final percentCenter = tester.getCenter(find.text('%'));
      final memoryCenter = tester.getCenter(find.text('MC'));
      final ansCenter = tester.getCenter(find.text('ANS'));
      final permutationCenter = tester.getCenter(find.text('nPr'));
      final acCenter = tester.getCenter(find.text('AC'));
      final backspaceCenter = tester.getCenter(find.text('⌫'));
      final ceCenter = tester.getCenter(find.text('CE'));

      expect(percentCenter.dy, lessThan(memoryCenter.dy));
      expect(permutationCenter.dy, lessThan(memoryCenter.dy));
      expect(ansCenter.dy, closeTo(memoryCenter.dy, 0.01));
      expect(memoryCenter.dy, lessThan(acCenter.dy));
      expect(ceCenter.dy, closeTo(acCenter.dy, 0.01));
      expect(backspaceCenter.dy, closeTo(acCenter.dy, 0.01));
    });

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

    testWidgets('new scientific keys dispatch their operations', (tester) async {
      await tester.pumpWidget(wrap());

      await tapKey(tester, '3');
      await tapKey(tester, 'x³');
      expect(find.bySemanticsLabel('Sonuç: 27'), findsOneWidget);

      await tapKey(tester, 'SHIFT');
      await tapKey(tester, '∛x');
      expect(find.bySemanticsLabel('Sonuç: 3'), findsOneWidget);

      await tapKey(tester, 'AC');
      await tapKey(tester, '1');
      await tapKey(tester, '0');
      await tapKey(tester, 'mod');
      await tapKey(tester, '3');
      await tapKey(tester, '=');
      expect(find.bySemanticsLabel('Sonuç: 1'), findsOneWidget);

      await tapKey(tester, 'AC');
      await tapKey(tester, '2');
      await tapKey(tester, '.');
      await tapKey(tester, '6');
      await tapKey(tester, 'Rnd');
      expect(find.bySemanticsLabel('Sonuç: 3'), findsOneWidget);
    });
  });
}
