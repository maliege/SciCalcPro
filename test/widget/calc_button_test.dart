import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sci_calc_pro/widgets/calc_button.dart' as cb;

void main() {
  // Helper: puts a single CalcButton in a testable Row+Scaffold.
  // CalcButton uses Expanded internally so it must live inside a Row.
  Widget wrap({
    required String label,
    required VoidCallback onTap,
    cb.ButtonStyle style = cb.ButtonStyle.number,
    String? shiftLabel,
  }) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: SizedBox(
          height: 60,
          child: Row(
            children: [
              cb.CalcButton(
                label: label,
                shiftLabel: shiftLabel,
                style: style,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  group('CalcButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(wrap(label: '7', onTap: () {}));
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(wrap(label: '+', onTap: () => tapped = true));
      await tester.tap(find.text('+'));
      await tester.pump();
      expect(tapped, true);
    });

    testWidgets('shows shiftLabel above button', (tester) async {
      await tester.pumpWidget(
        wrap(label: 'sin', shiftLabel: 'sin⁻¹', onTap: () {}),
      );
      expect(find.text('sin'), findsOneWidget);
      expect(find.text('sin⁻¹'), findsOneWidget);
    });

    testWidgets('renders with function style without error', (tester) async {
      await tester.pumpWidget(
        wrap(label: 'log', style: cb.ButtonStyle.function, onTap: () {}),
      );
      expect(find.text('log'), findsOneWidget);
    });

    testWidgets('renders with accent style without error', (tester) async {
      await tester.pumpWidget(
        wrap(label: '=', style: cb.ButtonStyle.accent, onTap: () {}),
      );
      expect(find.text('='), findsOneWidget);
    });

    testWidgets('renders with delete style without error', (tester) async {
      await tester.pumpWidget(
        wrap(label: 'AC', style: cb.ButtonStyle.delete, onTap: () {}),
      );
      expect(find.text('AC'), findsOneWidget);
    });

    testWidgets('renders with shift style without error', (tester) async {
      await tester.pumpWidget(
        wrap(label: 'SHIFT', style: cb.ButtonStyle.shift, onTap: () {}),
      );
      expect(find.text('SHIFT'), findsOneWidget);
    });

    testWidgets('multiple taps fire multiple callbacks', (tester) async {
      int count = 0;
      await tester.pumpWidget(wrap(label: '5', onTap: () => count++));
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('5'));
      await tester.pump();
      expect(count, 2);
    });
  });
}
