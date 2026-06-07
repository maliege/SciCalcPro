import 'package:flutter/material.dart';
import '../astronomy_engine.dart';
import '../../../shared/calc_form.dart';

const _accent = Color(0xFF9C6FD6);
const _result = Color(0xFFCE93D8);

class GravityTab extends StatefulWidget {
  const GravityTab({super.key});
  @override
  State<GravityTab> createState() => _GravityTabState();
}

class _GravityTabState extends State<GravityTab> {
  final _m1   = TextEditingController();
  final _m2   = TextEditingController();
  final _dist = TextEditingController();
  List<CalcResultRow> _rows = [];

  void _calculate() {
    final m1   = parseField(_m1);
    final m2   = parseField(_m2);
    final dist = parseField(_dist);
    if (m1 == null || m2 == null || dist == null) return;
    if (m1 <= 0 || m2 <= 0 || dist <= 0) return;

    final f = calcGravForce(m1Kg: m1, m2Kg: m2, distM: dist);
    setState(() => _rows = [
      CalcResultRow('Çekim kuvveti', fmt(f), unit: 'N'),
    ]);
  }

  @override
  void dispose() { _m1.dispose(); _m2.dispose(); _dist.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => CalcScaffold(children: [
    CalcField(label: 'Kütle 1 (m₁)',  hint: '1.989e30', unit: 'kg', ctrl: _m1,   accentColor: _accent),
    CalcField(label: 'Kütle 2 (m₂)',  hint: '5.972e24', unit: 'kg', ctrl: _m2,   accentColor: _accent),
    CalcField(label: 'Mesafe (r)',     hint: '1.496e11', unit: 'm',  ctrl: _dist, accentColor: _accent),
    const Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Text('Güneş-Dünya örneği: m₁=1.989×10³⁰ kg · r=1.496×10¹¹ m',
          style: TextStyle(color: Color(0xFF607080), fontSize: 11)),
    ),
    CalcButton(onTap: _calculate, color: _accent),
    CalcResultCard(rows: _rows, resultColor: _result),
    const CalcInfoBox(
      description:
          'Newton\'un evrensel çekim yasası, iki kütleli cisim arasındaki çekim '
          'kuvvetinin kütlelerin çarpımıyla doğru, aralarındaki mesafenin karesiyle '
          'ters orantılı olduğunu ifade eder: F = Gm₁m₂/r². '
          'G = 6.674 × 10⁻¹¹ m³ kg⁻¹ s⁻² evrensel çekim sabitidir.',
      references: [
        'Newton I. Philosophiæ Naturalis Principia Mathematica. London: Royal Society; 1687.',
        'Cavendish H. Experiments to Determine the Density of the Earth. '
            'Phil Trans R Soc Lond. 1798;88:469–526.',
      ],
    ),
  ]);
}
