import 'package:flutter/material.dart';
import '../models/calculator_engine.dart';
import '../theme/app_theme.dart';
import '../widgets/calc_button.dart' as cb;
import '../widgets/display_widget.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorEngine _engine = CalculatorEngine();
  static const EdgeInsets _numKeyPadding =
      EdgeInsets.symmetric(horizontal: 3, vertical: 1.2);

  // When true, next function press uses the SHIFT (yellow) variant.
  bool _shifted = false;

  // ── Dispatch ──────────────────────────────────────────────────────────────

  void _digit(String d) => setState(() => _engine.inputDigit(d));
  void _decimal()       => setState(() => _engine.inputDecimal());
  void _sign()          => setState(() => _engine.toggleSign());
  void _percent()       => setState(() => _engine.percent());
  void _backspace()     => setState(() => _engine.backspace());
  void _clear()         => setState(() => _engine.clear());
  void _clearEntry()    => setState(() => _engine.clearEntry());
  void _ans()           => setState(() => _engine.inputAns());
  void _random()        => setState(() => _engine.inputRandom());
  void _equals()        => setState(() => _engine.equals());
  void _binary(String op) => setState(() => _engine.binaryOperator(op));
  void _constant(String c) => setState(() => _engine.inputConstant(c));
  void _angleToggle()   => setState(() => _engine.toggleAngleMode());
  void _memory(MemoryOp op) => setState(() => _engine.memoryOperation(op));

  // Unary: auto-deactivate shift after use
  void _unary(String normal, [String? shifted]) {
    final fn = (_shifted && shifted != null) ? shifted : normal;
    setState(() {
      _engine.unaryFunction(fn);
      _shifted = false;
    });
  }

  // Binary: auto-deactivate shift after use
  void _binaryShift(String normal, [String? shifted]) {
    final op = (_shifted && shifted != null) ? shifted : normal;
    setState(() {
      _engine.binaryOperator(op);
      _shifted = false;
    });
  }

  void _toggleShift() => setState(() => _shifted = !_shifted);

  // ── Button factories ───────────────────────────────────────────────────────

  // Digit button
  cb.CalcButton _n(String d) => cb.CalcButton(
        label: d,
        style: cb.ButtonStyle.number,
        onTap: () => _digit(d),
      padding: _numKeyPadding,
      );

  // Operator button for numeric keypad rows with tighter spacing.
  cb.CalcButton _numOp(String label) => cb.CalcButton(
        label: label,
        style: cb.ButtonStyle.operator,
        onTap: () => _binary(label),
        padding: _numKeyPadding,
      );

  // Function button — shiftLabel shown in yellow above, activates on SHIFT press
  cb.CalcButton _fn(
    String label,
    String fn, {
    String? shiftLabel,
    String? shiftFn,
  }) =>
      cb.CalcButton(
        label: label,
        shiftLabel: shiftLabel,
        style: cb.ButtonStyle.function,
        onTap: () => _unary(fn, shiftFn),
      );

  // Memory button
  cb.CalcButton _mem(String label, MemoryOp op) => cb.CalcButton(
        label: label,
        style: cb.ButtonStyle.memory,
        onTap: () => _memory(op),
      );

  // ── Layout ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      backgroundColor: context.appColors.calcBg,
      body: SafeArea(
        child: isLandscape ? _landscape() : _portrait(),
      ),
    );
  }

  Widget _portrait() => Column(
        children: [
          _display(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 2, 5, 6),
              child: Column(children: _allRows()),
            ),
          ),
        ],
      );

  Widget _landscape() => Row(
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 2, 3, 6),
              child: Column(children: _funcRows()),
            ),
          ),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                _display(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(3, 2, 5, 6),
                    child: Column(children: _numRows()),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _display() => DisplayWidget(
        expression: _engine.expression,
        display: _engine.display,
        memory: _engine.memory,
        isRadMode: _engine.isRadMode,
        hasMemory: _engine.hasMemory,
      );

  List<Widget> _allRows() => [
        ..._funcRows(),
        ..._numRows(),
      ];

  List<Widget> _funcRows() => [
      Expanded(child: _rowControl()),
      Expanded(child: _rowTrig()),
      Expanded(child: _rowHyp()),
      Expanded(child: _rowPower()),
      Expanded(child: _rowMisc()),
      Expanded(child: _rowMemory()),
      ];

  List<Widget> _numRows() => [
      Expanded(child: _rowClear()),
      Expanded(child: _row789()),
      Expanded(child: _row456()),
      Expanded(child: _row123()),
      Expanded(child: _row0()),
      ];

  // ── Button rows ─────────────────────────────────────────────────────────

  // Row 1 (Control): SHIFT · DEG/RAD · π · EE · nPr/nCr
  Widget _rowControl() => Row(children: [
        cb.CalcButton(
          label: 'SHIFT',
          style: cb.ButtonStyle.shift,
          onTap: _toggleShift,
          fontSize: 12,
        ),
        cb.CalcButton(
          label: _engine.isRadMode ? 'DEG' : 'RAD',
          shiftLabel: 'MODE',
          style: cb.ButtonStyle.function,
          onTap: _angleToggle,
          fontSize: 12,
        ),
        cb.CalcButton(
          label: 'π',
          shiftLabel: 'e',
          style: cb.ButtonStyle.function,
          onTap: () => _constant(_shifted ? 'e' : 'π'),
          fontSize: 16,
        ),
        cb.CalcButton(
          label: 'EE',
          style: cb.ButtonStyle.function,
          onTap: () => _binary('EE'),
          fontSize: 14,
        ),
        cb.CalcButton(
          label: 'nPr',
          shiftLabel: 'nCr',
          style: cb.ButtonStyle.function,
          onTap: () => _binaryShift('nPr', 'nCr'),
          fontSize: 12,
        ),
      ]);

  // Memory: MC · MR · M+ · M- · ANS
  Widget _rowMemory() => Row(children: [
        _mem('MC', MemoryOp.clear),
        _mem('MR', MemoryOp.recall),
        _mem('M+', MemoryOp.add),
        _mem('M-', MemoryOp.subtract),
        cb.CalcButton(
          label: 'ANS',
          style: cb.ButtonStyle.memory,
          onTap: _ans,
          fontSize: 14,
        ),
      ]);

  // Row 3 (Trig): sin · cos · tan · log · ln
  Widget _rowTrig() => Row(children: [
        _fn('sin', 'sin', shiftLabel: 'sin⁻¹', shiftFn: 'sin⁻¹'),
        _fn('cos', 'cos', shiftLabel: 'cos⁻¹', shiftFn: 'cos⁻¹'),
        _fn('tan', 'tan', shiftLabel: 'tan⁻¹', shiftFn: 'tan⁻¹'),
        _fn('log', 'log', shiftLabel: '10ˣ',   shiftFn: '10ˣ'),
        _fn('ln',  'ln',  shiftLabel: 'eˣ',    shiftFn: 'eˣ'),
      ]);

  // Row 4 (Hyperbolic): sinh · cosh · tanh · mod · Ran#
  Widget _rowHyp() => Row(children: [
        _fn('sinh', 'sinh', shiftLabel: 'sinh⁻¹', shiftFn: 'sinh⁻¹'),
        _fn('cosh', 'cosh', shiftLabel: 'cosh⁻¹', shiftFn: 'cosh⁻¹'),
        _fn('tanh', 'tanh', shiftLabel: 'tanh⁻¹', shiftFn: 'tanh⁻¹'),
        cb.CalcButton(
          label: 'mod',
          style: cb.ButtonStyle.function,
          onTap: () => _binary('mod'),
          fontSize: 13,
        ),
        cb.CalcButton(
          label: 'Ran#',
          style: cb.ButtonStyle.function,
          onTap: _random,
          fontSize: 12,
        ),
      ]);

  // Row 5 (Power/Root): x² · x³ · xʸ · 1/x · x!
  Widget _rowPower() => Row(children: [
        _fn('x²', 'x²', shiftLabel: '√x',  shiftFn: '√x'),
        _fn('x³', 'x³', shiftLabel: '∛x',  shiftFn: '∛x'),
        cb.CalcButton(
          label: 'xʸ',
          shiftLabel: 'ʸ√x',
          style: cb.ButtonStyle.function,
          onTap: () => _binaryShift('xʸ', 'ʸ√x'),
          fontSize: 13,
        ),
        _fn('1/x', '1/x'),
        _fn('x!',  'x!'),
      ]);

  // Row 5 (Misc): +/- · % · |x| · Rnd · ⌊x⌋
  Widget _rowMisc() => Row(children: [
        cb.CalcButton(
          label: '+/-',
          style: cb.ButtonStyle.function,
          onTap: _sign,
          fontSize: 13,
        ),
        cb.CalcButton(
          label: '%',
          style: cb.ButtonStyle.function,
          onTap: _percent,
          fontSize: 16,
        ),
        _fn('|x|', 'abs'),
        _fn('Rnd', 'Rnd'),
        _fn('⌊x⌋', '⌊x⌋'),
      ]);

  // Numeric controls: AC · ⌫ · CE · ÷
  Widget _rowClear() => Row(children: [
        cb.CalcButton(
          label: 'AC',
          style: cb.ButtonStyle.delete,
          onTap: _clear,
          fontSize: 15,
          padding: _numKeyPadding,
        ),
        cb.CalcButton(
          label: '⌫',
          style: cb.ButtonStyle.delete,
          onTap: _backspace,
          fontSize: 18,
          padding: _numKeyPadding,
        ),
        cb.CalcButton(
          label: 'CE',
          style: cb.ButtonStyle.delete,
          onTap: _clearEntry,
          fontSize: 16,
          padding: _numKeyPadding,
        ),
        _numOp('÷'),
      ]);

  Widget _row789() => Row(children: [_n('7'), _n('8'), _n('9'), _numOp('×')]);
  Widget _row456() => Row(children: [_n('4'), _n('5'), _n('6'), _numOp('-')]);
  Widget _row123() => Row(children: [_n('1'), _n('2'), _n('3'), _numOp('+')]);

  Widget _row0() => Row(children: [
        cb.CalcButton(
          label: '0',
          style: cb.ButtonStyle.number,
          onTap: () => _digit('0'),
          flex: 2,
          padding: _numKeyPadding,
        ),
        cb.CalcButton(
          label: '.',
          style: cb.ButtonStyle.number,
          onTap: _decimal,
          fontSize: 22,
          padding: _numKeyPadding,
        ),
        cb.CalcButton(
          label: '=',
          style: cb.ButtonStyle.accent,
          onTap: _equals,
          fontSize: 22,
          padding: _numKeyPadding,
        ),
      ]);
}
