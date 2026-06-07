import 'dart:math' as math;

enum AngleMode { degrees, radians }

enum MemoryOp { add, subtract, recall, clear }

class CalculatorEngine {
  String _display = '0';
  String _expression = '';
  double? _firstOperand;
  String? _pendingOperator;
  bool _newInput = true;
  double _memory = 0;
  AngleMode angleMode = AngleMode.degrees;
  bool _hasError = false;

  String get display => _display;
  String get expression => _expression;
  double get memory => _memory;
  bool get hasMemory => _memory != 0;
  bool get isRadMode => angleMode == AngleMode.radians;

  void toggleAngleMode() {
    angleMode = angleMode == AngleMode.degrees
        ? AngleMode.radians
        : AngleMode.degrees;
  }

  // ── Input ──────────────────────────────────────────────────────────────────

  void inputDigit(String digit) {
    if (_hasError) clear();
    if (_newInput) {
      _display = digit;
      _newInput = false;
    } else {
      if (_display == '0' && digit != '.') {
        _display = digit;
      } else if (digit == '.' && _display.contains('.')) {
        return;
      } else if (_display.length < 15) {
        _display += digit;
      }
    }
  }

  void inputDecimal() => inputDigit('.');

  void toggleSign() {
    if (_display == '0' || _hasError) return;
    if (_display.startsWith('-')) {
      _display = _display.substring(1);
    } else {
      _display = '-$_display';
    }
  }

  void backspace() {
    if (_hasError) { clear(); return; }
    if (_newInput) return;
    if (_display.length <= 1 || (_display.startsWith('-') && _display.length <= 2)) {
      _display = '0';
      _newInput = true;
    } else {
      _display = _display.substring(0, _display.length - 1);
    }
  }

  // ── Binary operators ───────────────────────────────────────────────────────

  void binaryOperator(String op) {
    if (_hasError) return;
    final current = _parseDisplay();
    if (current == null) return;

    if (_pendingOperator != null && !_newInput) {
      _applyPending(current);
      if (_hasError) return;
    } else {
      _firstOperand = current;
    }

    _pendingOperator = op;
    _expression = '${_formatNum(_firstOperand!)} $op';
    _newInput = true;
  }

  void equals() {
    if (_hasError) return;
    final current = _parseDisplay();
    if (current == null) return;

    if (_pendingOperator != null) {
      final a = _firstOperand!;
      _expression = '${_formatNum(a)} $_pendingOperator ${_formatNum(current)} =';
      _applyPending(current);
      _pendingOperator = null;
      _firstOperand = null;
    }
    _newInput = true;
  }

  void _applyPending(double b) {
    final a = _firstOperand!;
    double? result;
    switch (_pendingOperator) {
      case '+': result = a + b;
      case '-': result = a - b;
      case '×': result = a * b;
      case '÷':
        if (b == 0) { _setError('Sıfıra bölme'); return; }
        result = a / b;
      case 'xʸ': result = math.pow(a, b).toDouble();
      case 'ʸ√x':
        if (b == 0) { _setError('Geçersiz kök'); return; }
        if (a < 0) {
          // Negatif tabanda sadece tek sayı integer kökleri reel sonuç verir
          if (b != b.roundToDouble() || b.toInt().isEven) {
            _setError('Tanımsız'); return;
          }
          result = -math.pow(-a, 1 / b).toDouble();
        } else {
          result = math.pow(a, 1 / b).toDouble();
        }
      case 'nPr': result = _permutation(a, b);
      case 'nCr': result = _combination(a, b);
      case 'EE': result = a * math.pow(10, b).toDouble();
    }
    if (result == null) return;
    if (result.isNaN || result.isInfinite) { _setError('Tanımsız'); return; }
    _firstOperand = result;
    _display = _formatNum(result);
  }

  // ── Unary functions ────────────────────────────────────────────────────────

  void unaryFunction(String fn) {
    if (_hasError && fn != 'AC') return;
    final x = _parseDisplay();
    if (x == null) return;

    double? result;
    final xRad = angleMode == AngleMode.degrees ? x * math.pi / 180 : x;

    switch (fn) {
      case 'sin':   result = math.sin(xRad);
      case 'cos':   result = math.cos(xRad);
      case 'tan':
        if ((xRad % math.pi - math.pi / 2).abs() < 1e-10) {
          _setError('Tanımsız'); return;
        }
        result = math.tan(xRad);
      case 'sin⁻¹':
        if (x < -1 || x > 1) { _setError('Tanımsız'); return; }
        result = _toDeg(math.asin(x));
      case 'cos⁻¹':
        if (x < -1 || x > 1) { _setError('Tanımsız'); return; }
        result = _toDeg(math.acos(x));
      case 'tan⁻¹': result = _toDeg(math.atan(x));
      case 'log':
        if (x <= 0) { _setError('Tanımsız'); return; }
        result = math.log(x) / math.ln10;
      case 'ln':
        if (x <= 0) { _setError('Tanımsız'); return; }
        result = math.log(x);
      case '10ˣ': result = math.pow(10, x).toDouble();
      case 'eˣ':  result = math.exp(x);
      case 'x²':  result = x * x;
      case '√x':
        if (x < 0) { _setError('Tanımsız'); return; }
        result = math.sqrt(x);
      case '1/x':
        if (x == 0) { _setError('Sıfıra bölme'); return; }
        result = 1 / x;
      case 'x!':
        if (x < 0 || x != x.roundToDouble() || x > 170) {
          _setError('Tanımsız'); return;
        }
        result = _factorial(x.toInt());
      case 'abs': result = x.abs();
    }

    if (result == null) return;
    if (result.isNaN || result.isInfinite) { _setError('Tanımsız'); return; }
    _expression = '$fn(${_formatNum(x)}) =';
    _display = _formatNum(result);
    _newInput = true;
  }

  double _toDeg(double rad) =>
      angleMode == AngleMode.degrees ? rad * 180 / math.pi : rad;

  // ── Constants ──────────────────────────────────────────────────────────────

  void inputConstant(String name) {
    double value;
    switch (name) {
      case 'π': value = math.pi;
      case 'e': value = math.e;
      default: return;
    }
    _display = _formatNum(value);
    _newInput = false;
  }

  // ── Memory ─────────────────────────────────────────────────────────────────

  void memoryOperation(MemoryOp op) {
    final x = _parseDisplay() ?? 0;
    switch (op) {
      case MemoryOp.add:      _memory += x; _newInput = true;
      case MemoryOp.subtract: _memory -= x; _newInput = true;
      case MemoryOp.recall:
        _display = _formatNum(_memory);
        _newInput = false;
      case MemoryOp.clear:    _memory = 0;
    }
  }

  // ── Clear ──────────────────────────────────────────────────────────────────

  void clear() {
    _display = '0';
    _expression = '';
    _firstOperand = null;
    _pendingOperator = null;
    _newInput = true;
    _hasError = false;
  }

  void clearEntry() {
    _display = '0';
    _newInput = true;
    _hasError = false;
  }

  // ── Percent ────────────────────────────────────────────────────────────────

  void percent() {
    final x = _parseDisplay();
    if (x == null) return;
    if (_firstOperand != null && (_pendingOperator == '+' || _pendingOperator == '-')) {
      _display = _formatNum(_firstOperand! * x / 100);
    } else {
      _display = _formatNum(x / 100);
    }
    _newInput = true;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  double? _parseDisplay() {
    return double.tryParse(_display);
  }

  String _formatNum(double n) {
    if (n.isNaN) return 'Tanımsız';
    if (n.isInfinite) return n > 0 ? '+∞' : '-∞';
    if (n == n.truncateToDouble() && n.abs() < 1e15) {
      final i = n.toInt();
      return i.toString();
    }
    // Use toPrecision-like formatting
    final s = n.toStringAsPrecision(10).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    // Switch to scientific notation for very large/small values
    if (n.abs() >= 1e10 || (n.abs() < 1e-6 && n != 0)) {
      // 9 ondalık = 10 anlamlı rakam → normal yol ile tutarlı
      return n.toStringAsExponential(9).replaceAll(RegExp(r'0+e'), 'e').replaceAll(RegExp(r'\.e'), 'e');
    }
    return s;
  }

  void _setError(String msg) {
    _display = msg;
    _hasError = true;
    _newInput = true;
    _firstOperand = null;
    _pendingOperator = null;
    _expression = '';
  }

  double _factorial(int n) {
    double result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  double? _permutation(double n, double r) {
    if (n < 0 || r < 0 || r > n ||
        n != n.roundToDouble() || r != r.roundToDouble()) { return null; }
    int ni = n.toInt(), ri = r.toInt();
    double result = 1;
    for (int i = 0; i < ri; i++) { result *= (ni - i); }
    return result;
  }

  double? _combination(double n, double r) {
    if (n < 0 || r < 0 || r > n ||
        n != n.roundToDouble() || r != r.roundToDouble()) { return null; }
    int ni = n.toInt();
    // Simetri: C(n,r) = C(n, n-r) — her zaman küçük tarafı kullan
    int ri = r.toInt();
    if (ri > ni - ri) ri = ni - ri;
    // Her adımda çarp-böl: ara değerler her zaman tam sayı → taşma ve hassasiyet kaybı olmaz
    double result = 1;
    for (int i = 0; i < ri; i++) {
      result = result * (ni - i) / (i + 1);
    }
    return result;
  }
}
