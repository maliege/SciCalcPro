import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/unit_converter.dart';
import '../theme/app_theme.dart';

const _accent = Color(0xFF4DB6AC);

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final _input = TextEditingController(text: '1');
  int _catIdx = 0;
  int _fromIdx = 0;
  int _toIdx = 1;

  UnitCategory get _category => UnitConverter.categories[_catIdx];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _selectCategory(int i) {
    setState(() {
      _catIdx = i;
      _fromIdx = 0;
      _toIdx = _category.units.length > 1 ? 1 : 0;
    });
  }

  void _swap() {
    setState(() {
      final tmp = _fromIdx;
      _fromIdx = _toIdx;
      _toIdx = tmp;
    });
  }

  String get _result {
    final value = double.tryParse(_input.text.trim().replaceAll(',', '.'));
    if (value == null) return '—';
    final out = UnitConverter.convert(
      value: value,
      from: _category.units[_fromIdx],
      to: _category.units[_toIdx],
      category: _category,
    );
    return _format(out);
  }

  // Compact, human-friendly formatting with up to 6 significant digits.
  static String _format(double v) {
    if (v.isNaN || v.isInfinite) return '—';
    if (v == 0) return '0';
    final abs = v.abs();
    if (abs >= 1e9 || abs < 1e-4) {
      return v.toStringAsExponential(4);
    }
    var s = v.toStringAsFixed(6);
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'0+$'), '');
      s = s.replaceFirst(RegExp(r'\.$'), '');
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: colors.headerBg,
        elevation: 0,
        title: Text(
          'Birim Dönüştürücü',
          style: TextStyle(
              color: colors.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _categoryBar(colors),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _unitTile(
                    colors,
                    title: 'Değer',
                    unitIndex: _fromIdx,
                    onUnitChanged: (i) => setState(() => _fromIdx = i),
                    child: TextField(
                      controller: _input,
                      autofocus: false,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[\d.,eE+\-]')),
                      ],
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(
                          color: colors.primaryText,
                          fontSize: 26,
                          fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),
                  ),
                  _swapRow(colors),
                  _unitTile(
                    colors,
                    title: 'Sonuç',
                    unitIndex: _toIdx,
                    onUnitChanged: (i) => setState(() => _toIdx = i),
                    child: SizedBox(
                      height: 40,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _result,
                            style: const TextStyle(
                                color: _accent,
                                fontSize: 26,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _formulaLine(colors),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryBar(AppColors colors) {
    return Container(
      color: colors.headerBg,
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: UnitConverter.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final sel = i == _catIdx;
            return GestureDetector(
              onTap: () => _selectCategory(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: sel ? _accent.withValues(alpha: 0.15) : colors.card,
                  border: Border.all(
                      color: sel ? _accent : colors.border, width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  UnitConverter.categories[i].name,
                  style: TextStyle(
                    color: sel ? _accent : colors.label,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _unitTile(
    AppColors colors, {
    required String title,
    required int unitIndex,
    required ValueChanged<int> onUnitChanged,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: colors.card,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(color: colors.label, fontSize: 11)),
                const SizedBox(height: 2),
                child,
              ],
            ),
          ),
          const SizedBox(width: 8),
          _unitDropdown(colors, unitIndex, onUnitChanged),
        ],
      ),
    );
  }

  Widget _unitDropdown(
      AppColors colors, int unitIndex, ValueChanged<int> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: colors.fieldFill,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: unitIndex,
          dropdownColor: colors.card,
          iconEnabledColor: _accent,
          isDense: true,
          borderRadius: BorderRadius.circular(8),
          items: List.generate(
            _category.units.length,
            (i) => DropdownMenuItem<int>(
              value: i,
              child: Text(
                _category.units[i].id,
                style: TextStyle(
                    color: colors.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          selectedItemBuilder: (_) => List.generate(
            _category.units.length,
            (i) => Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _category.units[i].id,
                style: TextStyle(
                    color: colors.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }

  Widget _swapRow(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Divider(color: colors.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Material(
              color: _accent.withValues(alpha: 0.14),
              shape: const CircleBorder(),
              child: Tooltip(
                message: 'Birimleri değiştir',
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _swap,
                  child: Semantics(
                    button: true,
                    label: 'Birimleri değiştir',
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.swap_vert, color: _accent, size: 22),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: Divider(color: colors.border)),
        ],
      ),
    );
  }

  Widget _formulaLine(AppColors colors) {
    final from = _category.units[_fromIdx];
    final to = _category.units[_toIdx];
    final value = _input.text.trim().isEmpty ? '1' : _input.text.trim();
    return Text(
      '$value ${from.name} = $_result ${to.name}',
      textAlign: TextAlign.center,
      style: TextStyle(color: colors.label, fontSize: 12, height: 1.5),
    );
  }
}
