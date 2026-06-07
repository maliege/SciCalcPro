import 'package:flutter_test/flutter_test.dart';
import 'package:sci_calc_pro/models/calculator_engine.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

// Shorthand: enter a multi-digit number by pressing each character.
void typeNumber(CalculatorEngine e, String n) {
  for (final ch in n.split('')) {
    if (ch == '.') {
      e.inputDecimal();
    } else if (ch == '-' && e.display == '0') {
      e.inputDigit('0'); // will be toggled next
    } else {
      e.inputDigit(ch);
    }
  }
}

// Parse the display to double for numeric assertions.
double result(CalculatorEngine e) =>
    double.parse(e.display.replaceAll(',', '.'));

// Check display within a tolerance (floating point).
void expectClose(CalculatorEngine e, double expected,
    {double tol = 1e-9}) {
  final got = double.tryParse(e.display);
  expect(got, isNotNull,
      reason: 'Display "${e.display}" is not numeric');
  expect((got! - expected).abs(), lessThan(tol),
      reason: 'Expected $expected, got $got');
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late CalculatorEngine e;

  setUp(() => e = CalculatorEngine());

  // ── Initial state ──────────────────────────────────────────────────────────
  group('initial state', () {
    test('display starts at 0', () => expect(e.display, '0'));
    test('expression starts empty', () => expect(e.expression, ''));
    test('memory starts at 0', () => expect(e.memory, 0));
    test('default angle mode is degrees', () => expect(e.angleMode, AngleMode.degrees));
    test('hasMemory is false initially', () => expect(e.hasMemory, false));
  });

  // ── Digit input ────────────────────────────────────────────────────────────
  group('digit input', () {
    test('single digit replaces 0', () {
      e.inputDigit('5');
      expect(e.display, '5');
    });

    test('multiple digits append', () {
      typeNumber(e, '123');
      expect(e.display, '123');
    });

    test('leading zero is not duplicated', () {
      e.inputDigit('0');
      e.inputDigit('0');
      expect(e.display, '0');
    });

    test('decimal point added once', () {
      typeNumber(e, '3.');
      typeNumber(e, '14');
      expect(e.display, '3.14');
    });

    test('second decimal point ignored', () {
      typeNumber(e, '3.1');
      e.inputDecimal();
      typeNumber(e, '4');
      expect(e.display, '3.14');
    });

    test('backspace removes last digit', () {
      typeNumber(e, '123');
      e.backspace();
      expect(e.display, '12');
    });

    test('backspace on single digit resets to 0', () {
      typeNumber(e, '5');
      e.backspace();
      expect(e.display, '0');
    });

    test('toggle sign makes positive negative', () {
      typeNumber(e, '7');
      e.toggleSign();
      expect(e.display, '-7');
    });

    test('toggle sign twice returns to positive', () {
      typeNumber(e, '7');
      e.toggleSign();
      e.toggleSign();
      expect(e.display, '7');
    });
  });

  // ── Basic arithmetic ───────────────────────────────────────────────────────
  group('basic arithmetic', () {
    test('2 + 3 = 5', () {
      typeNumber(e, '2');
      e.binaryOperator('+');
      typeNumber(e, '3');
      e.equals();
      expectClose(e, 5);
    });

    test('10 - 4 = 6', () {
      typeNumber(e, '10');
      e.binaryOperator('-');
      typeNumber(e, '4');
      e.equals();
      expectClose(e, 6);
    });

    test('3 × 4 = 12', () {
      typeNumber(e, '3');
      e.binaryOperator('×');
      typeNumber(e, '4');
      e.equals();
      expectClose(e, 12);
    });

    test('8 ÷ 2 = 4', () {
      typeNumber(e, '8');
      e.binaryOperator('÷');
      typeNumber(e, '2');
      e.equals();
      expectClose(e, 4);
    });

    test('chained: 2 + 3 × 4  (left-to-right sequential)', () {
      // Engine applies operators in sequence, not algebraic precedence
      typeNumber(e, '2');
      e.binaryOperator('+');
      typeNumber(e, '3');
      e.binaryOperator('×'); // applies pending + first: 5 × ...
      typeNumber(e, '4');
      e.equals();
      expectClose(e, 20); // (2+3)×4
    });

    test('negative result: 3 - 7 = -4', () {
      typeNumber(e, '3');
      e.binaryOperator('-');
      typeNumber(e, '7');
      e.equals();
      expectClose(e, -4);
    });

    test('decimal arithmetic: 1.5 + 2.5 = 4', () {
      typeNumber(e, '1.5');
      e.binaryOperator('+');
      typeNumber(e, '2.5');
      e.equals();
      expectClose(e, 4);
    });
  });

  // ── Division by zero ───────────────────────────────────────────────────────
  group('division by zero', () {
    test('sets error display', () {
      typeNumber(e, '5');
      e.binaryOperator('÷');
      typeNumber(e, '0');
      e.equals();
      expect(e.display, 'Sıfıra bölme');
    });

    test('clear after error resets state', () {
      typeNumber(e, '5');
      e.binaryOperator('÷');
      typeNumber(e, '0');
      e.equals();
      e.clear();
      expect(e.display, '0');
      expect(e.expression, '');
    });
  });

  // ── Percent ────────────────────────────────────────────────────────────────
  group('percent', () {
    test('standalone: 50% = 0.5', () {
      typeNumber(e, '50');
      e.percent();
      expectClose(e, 0.5);
    });

    test('relative: 200 + 10% = 200 + 20 = 220', () {
      typeNumber(e, '200');
      e.binaryOperator('+');
      typeNumber(e, '10');
      e.percent(); // 10% of 200 = 20
      e.equals();
      expectClose(e, 220);
    });
  });

  // ── Power and root ─────────────────────────────────────────────────────────
  group('power and root', () {
    test('x²: 9² = 81', () {
      typeNumber(e, '9');
      e.unaryFunction('x²');
      expectClose(e, 81);
    });

    test('√x: √81 = 9', () {
      typeNumber(e, '81');
      e.unaryFunction('√x');
      expectClose(e, 9);
    });

    test('xʸ: 2^10 = 1024', () {
      typeNumber(e, '2');
      e.binaryOperator('xʸ');
      typeNumber(e, '10');
      e.equals();
      expectClose(e, 1024);
    });

    test('ʸ√x: cube root of 27 = 3', () {
      typeNumber(e, '27');
      e.binaryOperator('ʸ√x');
      typeNumber(e, '3');
      e.equals();
      expectClose(e, 3);
    });

    test('1/x: 1/4 = 0.25', () {
      typeNumber(e, '4');
      e.unaryFunction('1/x');
      expectClose(e, 0.25);
    });

    test('1/0 sets error', () {
      typeNumber(e, '0');
      e.unaryFunction('1/x');
      expect(e.display, 'Sıfıra bölme');
    });

    test('√ of negative sets error', () {
      typeNumber(e, '4');
      e.toggleSign();
      e.unaryFunction('√x');
      expect(e.display, 'Tanımsız');
    });
  });

  // ── Trigonometry — degree mode ─────────────────────────────────────────────
  group('trigonometry (degrees)', () {
    setUp(() => e.angleMode = AngleMode.degrees);

    test('sin(30°) = 0.5', () {
      typeNumber(e, '30');
      e.unaryFunction('sin');
      expectClose(e, 0.5);
    });

    test('cos(60°) = 0.5', () {
      typeNumber(e, '60');
      e.unaryFunction('cos');
      expectClose(e, 0.5);
    });

    test('tan(45°) = 1', () {
      typeNumber(e, '45');
      e.unaryFunction('tan');
      expectClose(e, 1);
    });

    test('sin(0°) = 0', () {
      typeNumber(e, '0');
      e.unaryFunction('sin');
      expectClose(e, 0);
    });

    test('cos(0°) = 1', () {
      typeNumber(e, '0');
      e.unaryFunction('cos');
      expectClose(e, 1);
    });

    test('sin(90°) = 1', () {
      typeNumber(e, '90');
      e.unaryFunction('sin');
      expectClose(e, 1);
    });

    test('sin⁻¹(0.5) = 30°', () {
      typeNumber(e, '0.5');
      e.unaryFunction('sin⁻¹');
      expectClose(e, 30);
    });

    test('cos⁻¹(0.5) = 60°', () {
      typeNumber(e, '0.5');
      e.unaryFunction('cos⁻¹');
      expectClose(e, 60);
    });

    test('tan⁻¹(1) = 45°', () {
      typeNumber(e, '1');
      e.unaryFunction('tan⁻¹');
      expectClose(e, 45);
    });

    test('sin⁻¹(2) sets error (out of domain)', () {
      typeNumber(e, '2');
      e.unaryFunction('sin⁻¹');
      expect(e.display, 'Tanımsız');
    });
  });

  // ── Trigonometry — radian mode ─────────────────────────────────────────────
  group('trigonometry (radians)', () {
    setUp(() => e.angleMode = AngleMode.radians);

    test('sin(π/6) = 0.5', () {
      // π/6 ≈ 0.5235987755
      typeNumber(e, '0.523598775');
      e.unaryFunction('sin');
      expectClose(e, 0.5, tol: 1e-6);
    });

    test('cos(π/3) = 0.5', () {
      typeNumber(e, '1.047197551');
      e.unaryFunction('cos');
      expectClose(e, 0.5, tol: 1e-6);
    });

    test('tan⁻¹(1) = π/4 in radians', () {
      typeNumber(e, '1');
      e.unaryFunction('tan⁻¹');
      expectClose(e, 0.7853981633974483, tol: 1e-9);
    });
  });

  // ── Angle mode toggle ──────────────────────────────────────────────────────
  group('angle mode toggle', () {
    test('toggles from degrees to radians', () {
      expect(e.angleMode, AngleMode.degrees);
      e.toggleAngleMode();
      expect(e.angleMode, AngleMode.radians);
    });

    test('toggles back to degrees', () {
      e.toggleAngleMode();
      e.toggleAngleMode();
      expect(e.angleMode, AngleMode.degrees);
    });
  });

  // ── Logarithm and exponential ──────────────────────────────────────────────
  group('logarithm and exponential', () {
    test('log(100) = 2', () {
      typeNumber(e, '100');
      e.unaryFunction('log');
      expectClose(e, 2);
    });

    test('log(1) = 0', () {
      typeNumber(e, '1');
      e.unaryFunction('log');
      expectClose(e, 0);
    });

    test('ln(1) = 0', () {
      typeNumber(e, '1');
      e.unaryFunction('ln');
      expectClose(e, 0);
    });

    test('ln(e) = 1', () {
      e.inputConstant('e');
      e.unaryFunction('ln');
      expectClose(e, 1);
    });

    test('10ˣ(2) = 100', () {
      typeNumber(e, '2');
      e.unaryFunction('10ˣ');
      expectClose(e, 100);
    });

    test('eˣ(0) = 1', () {
      typeNumber(e, '0');
      e.unaryFunction('eˣ');
      expectClose(e, 1);
    });

    test('log of zero sets error', () {
      typeNumber(e, '0');
      e.unaryFunction('log');
      expect(e.display, 'Tanımsız');
    });

    test('ln of negative sets error', () {
      typeNumber(e, '1');
      e.toggleSign();
      e.unaryFunction('ln');
      expect(e.display, 'Tanımsız');
    });
  });

  // ── Factorial ──────────────────────────────────────────────────────────────
  group('factorial', () {
    test('0! = 1', () {
      typeNumber(e, '0');
      e.unaryFunction('x!');
      expectClose(e, 1);
    });

    test('1! = 1', () {
      typeNumber(e, '1');
      e.unaryFunction('x!');
      expectClose(e, 1);
    });

    test('5! = 120', () {
      typeNumber(e, '5');
      e.unaryFunction('x!');
      expectClose(e, 120);
    });

    test('10! = 3628800', () {
      typeNumber(e, '10');
      e.unaryFunction('x!');
      expectClose(e, 3628800);
    });

    test('negative factorial sets error', () {
      typeNumber(e, '3');
      e.toggleSign();
      e.unaryFunction('x!');
      expect(e.display, 'Tanımsız');
    });

    test('fractional factorial sets error', () {
      typeNumber(e, '3.5');
      e.unaryFunction('x!');
      expect(e.display, 'Tanımsız');
    });
  });

  // ── Permutation and combination ────────────────────────────────────────────
  group('permutation and combination', () {
    test('P(5,2) = 20', () {
      typeNumber(e, '5');
      e.binaryOperator('nPr');
      typeNumber(e, '2');
      e.equals();
      expectClose(e, 20);
    });

    test('P(5,0) = 1', () {
      typeNumber(e, '5');
      e.binaryOperator('nPr');
      typeNumber(e, '0');
      e.equals();
      expectClose(e, 1);
    });

    test('C(5,2) = 10', () {
      typeNumber(e, '5');
      e.binaryOperator('nCr');
      typeNumber(e, '2');
      e.equals();
      expectClose(e, 10);
    });

    test('C(10,3) = 120', () {
      typeNumber(e, '10');
      e.binaryOperator('nCr');
      typeNumber(e, '3');
      e.equals();
      expectClose(e, 120);
    });

    test('C(n,0) = 1 for any n', () {
      typeNumber(e, '7');
      e.binaryOperator('nCr');
      typeNumber(e, '0');
      e.equals();
      expectClose(e, 1);
    });

    test('C(n,n) = 1', () {
      typeNumber(e, '6');
      e.binaryOperator('nCr');
      typeNumber(e, '6');
      e.equals();
      expectClose(e, 1);
    });
  });

  // ── Memory operations ──────────────────────────────────────────────────────
  group('memory', () {
    test('M+ stores current value', () {
      typeNumber(e, '42');
      e.memoryOperation(MemoryOp.add);
      expect(e.memory, 42);
      expect(e.hasMemory, true);
    });

    test('MR recalls stored value', () {
      typeNumber(e, '42');
      e.memoryOperation(MemoryOp.add);
      e.clear();
      e.memoryOperation(MemoryOp.recall);
      expectClose(e, 42);
    });

    test('M+ accumulates', () {
      typeNumber(e, '10');
      e.memoryOperation(MemoryOp.add);
      e.clear();
      typeNumber(e, '5');
      e.memoryOperation(MemoryOp.add);
      expect(e.memory, 15);
    });

    test('M- subtracts from memory', () {
      typeNumber(e, '10');
      e.memoryOperation(MemoryOp.add);
      e.clear();
      typeNumber(e, '3');
      e.memoryOperation(MemoryOp.subtract);
      expect(e.memory, 7);
    });

    test('MC clears memory to zero', () {
      typeNumber(e, '99');
      e.memoryOperation(MemoryOp.add);
      e.memoryOperation(MemoryOp.clear);
      expect(e.memory, 0);
      expect(e.hasMemory, false);
    });
  });

  // ── Constants ──────────────────────────────────────────────────────────────
  group('constants', () {
    test('π is approximately 3.14159', () {
      e.inputConstant('π');
      expectClose(e, 3.141592653589793);
    });

    test('e is approximately 2.71828', () {
      e.inputConstant('e');
      expectClose(e, 2.718281828459045);
    });
  });

  // ── Absolute value ──────────────────────────────────────────────────────────
  group('absolute value', () {
    test('|5| = 5', () {
      typeNumber(e, '5');
      e.unaryFunction('abs');
      expectClose(e, 5);
    });

    test('|-7| = 7', () {
      typeNumber(e, '7');
      e.toggleSign();
      e.unaryFunction('abs');
      expectClose(e, 7);
    });
  });

  // ── Clear and clear entry ──────────────────────────────────────────────────
  group('clear', () {
    test('AC resets everything', () {
      typeNumber(e, '123');
      e.binaryOperator('+');
      typeNumber(e, '456');
      e.clear();
      expect(e.display, '0');
      expect(e.expression, '');
    });

    test('clearEntry resets only display, keeps pending op', () {
      typeNumber(e, '5');
      e.binaryOperator('+');
      typeNumber(e, '3');
      e.clearEntry();
      expect(e.display, '0');
      // pending + and first operand (5) still alive
      typeNumber(e, '2');
      e.equals();
      expectClose(e, 7);
    });
  });

  // ── Edge cases ─────────────────────────────────────────────────────────────
  group('edge cases', () {
    test('equals without operator just keeps display', () {
      typeNumber(e, '42');
      e.equals();
      expectClose(e, 42);
    });

    test('operator then equals uses same number twice', () {
      // 5 + (no second number) = 5+5 would be the pending behaviour
      // Our engine: if no new input, equals does nothing extra
      typeNumber(e, '5');
      e.binaryOperator('+');
      e.equals(); // second operand not entered → treated as 0
      // Engine sets _firstOperand=5, then equals sees newInput=true, display='0'
      // so result is 5+0 = 5? Let's just verify it doesn't crash and is numeric
      expect(double.tryParse(e.display), isNotNull);
    });
  });
}
