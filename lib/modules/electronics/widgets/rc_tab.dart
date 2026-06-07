import 'package:flutter/material.dart';
import '../electronics_engine.dart';
import '../../../shared/calc_form.dart';

const _accent = Color(0xFF66BB6A);
const _result = Color(0xFFA5D6A7);

class RcTab extends StatefulWidget {
  const RcTab({super.key});
  @override
  State<RcTab> createState() => _RcTabState();
}

class _RcTabState extends State<RcTab> {
  final _r  = TextEditingController();
  final _c  = TextEditingController(); // μF
  final _v0 = TextEditingController();
  final _t  = TextEditingController(); // ms
  List<CalcResultRow> _rows = [];

  void _calculate() {
    final r   = parseField(_r);
    final cUf = parseField(_c);
    final v0  = parseField(_v0);
    final tMs = parseField(_t);
    if (r == null || cUf == null || v0 == null || tMs == null) return;
    if (r <= 0 || cUf <= 0 || v0 <= 0 || tMs < 0) return;

    final cF = cUf * 1e-6;   // μF → F
    final t  = tMs * 1e-3;   // ms → s
    final res = calcRC(resistanceOhm: r, capacitanceF: cF, v0: v0, tSec: t);

    final tauMs = res.tau * 1000;
    setState(() => _rows = [
      CalcResultRow('Zaman sabiti (τ)',       fmt(tauMs, decimals: 2), unit: 'ms'),
      CalcResultRow('V(t) — şarj',            fmt(res.vCharge,    decimals: 3), unit: 'V'),
      CalcResultRow('V(t) — deşarj',          fmt(res.vDischarge, decimals: 3), unit: 'V'),
      CalcResultRow('Tam şarj yükü (Q=CV₀)', fmt(res.charge * 1e6, decimals: 3), unit: 'μC'),
      CalcResultRow('Depolanan enerji (E)',    fmt(res.energy * 1e6, decimals: 3), unit: 'μJ'),
    ]);
  }

  @override
  void dispose() {
    _r.dispose(); _c.dispose(); _v0.dispose(); _t.dispose(); super.dispose();
  }

  @override
  Widget build(BuildContext context) => CalcScaffold(children: [
    CalcField(label: 'Direnç (R)',    hint: '1000', unit: 'Ω',  ctrl: _r,  accentColor: _accent),
    CalcField(label: 'Kapasitans (C)', hint: '100', unit: 'μF', ctrl: _c,  accentColor: _accent),
    CalcField(label: 'Başlangıç V₀', hint: '5',    unit: 'V',  ctrl: _v0, accentColor: _accent),
    CalcField(label: 'Zaman (t)',     hint: '100',  unit: 'ms', ctrl: _t,  accentColor: _accent),
    CalcButton(onTap: _calculate, color: _accent),
    CalcResultCard(rows: _rows, resultColor: _result),
    const CalcInfoBox(
      description:
          'RC devresinde kondansatörün şarj-deşarj süreci zaman sabiti τ = RC ile '
          'karakterize edilir. Şarj: V(t) = V₀(1 − e^(−t/τ)); '
          'Deşarj: V(t) = V₀ × e^(−t/τ). Bir zaman sabitinde kondansatör '
          'yaklaşık %63.2 şarj olur; 5τ\'da tam şarj kabul edilir.',
      references: [
        'Nilsson JW, Riedel SA. Electric Circuits. 11th ed. Hoboken: Pearson; 2019.',
      ],
    ),
  ]);
}
