import 'package:flutter/material.dart';
import '../electronics_engine.dart';
import '../../../shared/calc_form.dart';

const _accent = Color(0xFF66BB6A);
const _result = Color(0xFFA5D6A7);

class ResonanceTab extends StatefulWidget {
  const ResonanceTab({super.key});
  @override
  State<ResonanceTab> createState() => _ResonanceTabState();
}

class _ResonanceTabState extends State<ResonanceTab> {
  final _l = TextEditingController(); // mH
  final _c = TextEditingController(); // nF
  List<CalcResultRow> _rows = [];

  void _calculate() {
    final lMh = parseField(_l);
    final cNf = parseField(_c);
    if (lMh == null || cNf == null || lMh <= 0 || cNf <= 0) return;

    final lH = lMh * 1e-3;  // mH → H
    final cF = cNf * 1e-9;  // nF → F
    final res = calcLCResonance(inductanceH: lH, capacitanceF: cF);

    final fKhz = res.freqHz / 1000;
    final tMs  = res.periodS * 1000;
    setState(() => _rows = [
      CalcResultRow('Rezonans frekansı (f₀)', fmt(fKhz, decimals: 3), unit: 'kHz'),
      CalcResultRow('Periyot (T)',             fmt(tMs,  decimals: 3), unit: 'ms'),
      CalcResultRow('Açısal frekans (ω₀)',     fmt(res.omega, decimals: 1), unit: 'rad/s'),
      CalcResultRow('Karakteristik empedans',  fmt(res.impedance, decimals: 2), unit: 'Ω'),
    ]);
  }

  @override
  void dispose() { _l.dispose(); _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => CalcScaffold(children: [
    CalcField(label: 'Endüktans (L)',  hint: '10',  unit: 'mH', ctrl: _l, accentColor: _accent),
    CalcField(label: 'Kapasitans (C)', hint: '100', unit: 'nF', ctrl: _c, accentColor: _accent),
    CalcButton(onTap: _calculate, color: _accent),
    CalcResultCard(rows: _rows, resultColor: _result),
    const CalcInfoBox(
      description:
          'LC devresinde endüktans reaktansı XL = ωL ile kapasitans reaktansı '
          'XC = 1/(ωC) birbirini tam dengelediğinde rezonans oluşur. '
          'Rezonans frekansı f₀ = 1/(2π√LC), karakteristik empedans Z₀ = √(L/C) '
          'olup bu değer devrenin Q faktörünü ve bant genişliğini etkiler.',
      references: [
        'Thomson W (Lord Kelvin). On transient electric currents. '
            'Philos Mag. 1853;5(28):393–405.',
        'Nilsson JW, Riedel SA. Electric Circuits. 11th ed. Hoboken: Pearson; 2019.',
      ],
    ),
  ]);
}
