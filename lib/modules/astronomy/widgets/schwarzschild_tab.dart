import 'package:flutter/material.dart';
import '../astronomy_engine.dart';
import '../../../shared/calc_form.dart';

const _accent = Color(0xFF9C6FD6);
const _result = Color(0xFFCE93D8);

class SchwarzschildTab extends StatefulWidget {
  const SchwarzschildTab({super.key});
  @override
  State<SchwarzschildTab> createState() => _SchwarzschildTabState();
}

class _SchwarzschildTabState extends State<SchwarzschildTab> {
  final _mass = TextEditingController();
  List<CalcResultRow> _rows = [];

  void _calculate() {
    final massSun = parseField(_mass);
    if (massSun == null || massSun <= 0) return;

    const mSun = 1.989e30;
    final res = calcSchwarzschildRadius(massKg: massSun * mSun);
    setState(() => _rows = [
      CalcResultRow('Schwarzschild yarıçapı', fmt(res.meters), unit: 'm'),
      CalcResultRow('Schwarzschild yarıçapı', fmt(res.km),     unit: 'km'),
    ]);
  }

  @override
  void dispose() { _mass.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => CalcScaffold(children: [
    CalcField(label: 'Kütle', hint: '1.0', unit: 'M☉', ctrl: _mass, accentColor: _accent),
    const Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Text('1 M☉ (Güneş) → rs ≈ 2.95 km  |  10 M☉ → rs ≈ 29.5 km',
          style: TextStyle(color: Color(0xFF607080), fontSize: 11)),
    ),
    CalcButton(onTap: _calculate, color: _accent),
    CalcResultCard(rows: _rows, resultColor: _result),
    const CalcInfoBox(
      description:
          'Schwarzschild yarıçapı, Einstein\'ın genel görelilik denklemlerinin '
          'küresel simetrik kütleler için Schwarzschild tarafından bulunan çözümünden '
          'elde edilir: rₛ = 2GM/c². Bu yarıçaptaki yüzey "olay ufku" olarak '
          'adlandırılır; ışık dahil hiçbir şey bu sınırın içinden kaçamaz.',
      references: [
        'Schwarzschild K. Über das Gravitationsfeld eines Massenpunktes nach der '
            'Einsteinschen Theorie. Sitzungsber Preuss Akad Wiss. 1916:189–196.',
        'Einstein A. Die Feldgleichungen der Gravitation. '
            'Sitzungsber Preuss Akad Wiss. 1915:844–847.',
      ],
    ),
  ]);
}
