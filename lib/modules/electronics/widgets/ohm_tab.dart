import 'package:flutter/material.dart';
import '../../../shared/calc_form.dart';

const _accent = Color(0xFF66BB6A);
const _result = Color(0xFFA5D6A7);

class OhmTab extends StatefulWidget {
  const OhmTab({super.key});
  @override
  State<OhmTab> createState() => _OhmTabState();
}

class _OhmTabState extends State<OhmTab> {
  final _v = TextEditingController();
  final _i = TextEditingController(); // mA
  final _r = TextEditingController();
  int _solveFor = 2; // 0=V  1=I  2=R
  List<CalcResultRow> _rows = [];

  void _calculate() {
    final v = _solveFor == 0 ? null : parseField(_v);
    final iMa = _solveFor == 1 ? null : parseField(_i);
    final r = _solveFor == 2 ? null : parseField(_r);
    final i = iMa != null ? iMa / 1000.0 : null; // mA → A

    double rv, ri, rr;

    if (_solveFor == 0) {
      if (i == null || r == null || i <= 0 || r <= 0) return;
      rv = i * r; ri = i; rr = r;
    } else if (_solveFor == 1) {
      if (v == null || r == null || r <= 0) return;
      rv = v; ri = v / r; rr = r;
    } else {
      if (v == null || i == null || i <= 0) return;
      rv = v; ri = i; rr = v / i;
    }

    setState(() => _rows = [
      CalcResultRow('Gerilim (V)',       fmt(rv,          decimals: 3), unit: 'V'),
      CalcResultRow('Akım (I)',          fmt(ri * 1000,   decimals: 3), unit: 'mA'),
      CalcResultRow('Direnç (R)',        fmt(rr,          decimals: 2), unit: 'Ω'),
      CalcResultRow('Güç (P = V × I)',   fmt(rv * ri * 1000, decimals: 3), unit: 'mW'),
    ]);
  }

  @override
  void dispose() { _v.dispose(); _i.dispose(); _r.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => CalcScaffold(children: [
    CalcOptionRow(
      label: 'Hesapla',
      options: const ['V', 'I', 'R'],
      selected: _solveFor,
      onChanged: (v) => setState(() { _solveFor = v; _rows = []; }),
      accentColor: _accent,
    ),
    const Divider(color: Color(0xFF1F2D42), height: 20),
    if (_solveFor != 0)
      CalcField(label: 'Gerilim (V)', hint: '5',   unit: 'V',  ctrl: _v, accentColor: _accent),
    if (_solveFor != 1)
      CalcField(label: 'Akım (I)',    hint: '100', unit: 'mA', ctrl: _i, accentColor: _accent),
    if (_solveFor != 2)
      CalcField(label: 'Direnç (R)', hint: '50',  unit: 'Ω',  ctrl: _r, accentColor: _accent),
    CalcButton(onTap: _calculate, color: _accent),
    CalcResultCard(rows: _rows, resultColor: _result),
    const CalcInfoBox(
      description:
          'Ohm Kanunu, bir iletkenin uçları arasındaki gerilimin içinden geçen '
          'akımla orantılı olduğunu belirtir: V = I × R. Bu ilişki yalnızca lineer '
          '(ohmik) dirençler için geçerlidir; yarı iletkenler ve doğrusal olmayan '
          'elemanlar bu yasaya uymaz.',
      references: [
        'Ohm GS. Die galvanische Kette, mathematisch bearbeitet. '
            'Berlin: T. H. Riemann; 1827.',
      ],
    ),
  ]);
}
