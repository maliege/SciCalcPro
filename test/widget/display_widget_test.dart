import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sci_calc_pro/widgets/display_widget.dart';

void main() {
  // Helper: pump DisplayWidget inside a MaterialApp with dark theme.
  Widget wrap({
    required String display,
    String expression = '',
    double memory = 0,
    bool isRadMode = false,
    bool hasMemory = false,
  }) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: DisplayWidget(
          display: display,
          expression: expression,
          memory: memory,
          isRadMode: isRadMode,
          hasMemory: hasMemory,
        ),
      ),
    );
  }

  group('DisplayWidget', () {
    testWidgets('shows the display value', (tester) async {
      await tester.pumpWidget(wrap(display: '42'));
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('shows expression when set', (tester) async {
      await tester.pumpWidget(wrap(display: '5', expression: '2 + 3 ='));
      expect(find.text('2 + 3 ='), findsOneWidget);
    });

    testWidgets('shows DEG indicator when in degree mode', (tester) async {
      await tester.pumpWidget(wrap(display: '0', isRadMode: false));
      expect(find.text('Deg'), findsOneWidget);
    });

    testWidgets('shows Rad indicator when in radian mode', (tester) async {
      await tester.pumpWidget(wrap(display: '0', isRadMode: true));
      expect(find.text('Rad'), findsOneWidget);
    });

    testWidgets('shows M indicator when memory is non-zero', (tester) async {
      await tester.pumpWidget(wrap(display: '0', hasMemory: true));
      expect(find.text('M'), findsOneWidget);
    });

    testWidgets('does not show M indicator when memory is zero', (tester) async {
      await tester.pumpWidget(wrap(display: '0', hasMemory: false));
      expect(find.text('M'), findsNothing);
    });

    testWidgets('error text renders without throwing', (tester) async {
      await tester.pumpWidget(wrap(display: 'Tanımsız'));
      expect(find.text('Tanımsız'), findsOneWidget);
    });
  });
}
