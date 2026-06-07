import 'package:flutter/material.dart';
import '../../../shared/calc_form.dart';

const _accent = Color(0xFF66BB6A);
const _result = Color(0xFFA5D6A7);

class PowerTab extends StatefulWidget {
  const PowerTab({super.key});
  @override
  State<PowerTab> createState() => _PowerTabState();
}

class _PowerTabState extends State<PowerTab> {
  final _v = TextEditingController();
  final _i = TextEditingController(); // mA
  final _r = TextEditingController();
  List<CalcResultRow> _rows = [];

  void _calculate() {
    final v  = parseField(_v);
    final iMa = parseField(_i);
    final r  = parseField(_r);
    final i  = iMa != null ? iMa / 1000.0 : null;

    final rows = <CalcResultRow>[];

    if (v != null && i != null && v >= 0 && i >= 0) {
      rows.add(CalcResultRow('P = V × I', fmt(v * i * 1000, decimals: 3), unit: 'mW'));
    }
    if (i != null && r != null && i >= 0 && r > 0) {
      rows.add(CalcResultRow('P = I² × R', fmt(i * i * r * 1000, decimals: 3), unit: 'mW'));
    }
    if (v != null && r != null && v >= 0 && r > 0) {
      rows.add(CalcResultRow('P = V² / R', fmt(v * v / r * 1000, decimals: 3), unit: 'mW'));
    }
    if (v != null && r != null && r > 0) {
      rows.add(CalcResultRow('I = V / R', fmt(v / r * 1000, decimals: 3), unit: 'mA'));
    }
    if (i != null && r != null && r > 0) {
      rows.add(CalcResultRow('V = I × R', fmt(i * r, decimals: 3), unit: 'V'));
    }

    if (rows.isEmpty) return;
    setState(() => _rows = rows);
  }

  @override
  void dispose() { _v.dispose(); _i.dispose(); _r.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => CalcScaffold(children: [
    const Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Text('Bilinen değerleri girin — tüm uygulanabilir formüller hesaplanır.',
          style: TextStyle(color: Color(0xFF607080), fontSize: 11)),
    ),
    CalcField(label: 'Gerilim (V)', hint: '12',  unit: 'V',  ctrl: _v, accentColor: _accent),
    CalcField(label: 'Akım (I)',    hint: '500', unit: 'mA', ctrl: _i, accentColor: _accent),
    CalcField(label: 'Direnç (R)', hint: '24',  unit: 'Ω',  ctrl: _r, accentColor: _accent),
    CalcButton(onTap: _calculate, color: _accent),
    CalcResultCard(rows: _rows, resultColor: _result),
    const CalcInfoBox(
      description:
          'Elektrik gücü P = V × I, birim zamanda transfer edilen elektrik '
          'enerjisidir (Watt = Joule/saniye). Ohm Kanunu uygulandığında '
          'P = I²R (Joule ısısı) ve P = V²/R eşdeğer ifadeleri elde edilir. '
          'Joule ısısı, akımın direnç üzerinde ısıya dönüşmesini ifade eder.',
      references: [
        'Joule JP. On the Production of Heat by Voltaic Electricity. '
            'Proc R Soc Lond. 1841;4:280–282.',
      ],
    ),
  ]);
}
