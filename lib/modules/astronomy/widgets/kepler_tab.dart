import 'package:flutter/material.dart';
import '../astronomy_engine.dart';
import '../../../shared/calc_form.dart';

const _accent = Color(0xFF9C6FD6);
const _result = Color(0xFFCE93D8);

class KeplerTab extends StatefulWidget {
  const KeplerTab({super.key});
  @override
  State<KeplerTab> createState() => _KeplerTabState();
}

class _KeplerTabState extends State<KeplerTab> {
  final _a    = TextEditingController();
  final _mass = TextEditingController();
  List<CalcResultRow> _rows = [];

  void _calculate() {
    final a    = parseField(_a);
    final mass = parseField(_mass);
    if (a == null || mass == null || a <= 0 || mass <= 0) return;

    final res = calcKeplerPeriod(aMajorAU: a, centralMassEarth: mass);
    setState(() => _rows = [
      CalcResultRow('Periyot (yıl)',    fmt(res.years)),
      CalcResultRow('Periyot (gün)',    fmt(res.days,    decimals: 1)),
      CalcResultRow('Periyot (saniye)', fmt(res.seconds, decimals: 0), unit: 's'),
    ]);
  }

  @override
  void dispose() { _a.dispose(); _mass.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => CalcScaffold(children: [
    CalcField(label: 'Yarı-büyük eksen', hint: '0.00257', unit: 'AU',  ctrl: _a,    accentColor: _accent),
    CalcField(label: 'Merkez kütlesi',   hint: '1.0',    unit: 'M⊕',  ctrl: _mass, accentColor: _accent),
    const Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Text(
        '1 M⊕ = Dünya kütlesi  |  Güneş = 333 000 M⊕\n'
        'Ay örneği: a = 0.00257 AU, M = 1 M⊕ → T ≈ 27.3 gün',
        style: TextStyle(color: Color(0xFF607080), fontSize: 11),
      ),
    ),
    CalcButton(onTap: _calculate, color: _accent),
    CalcResultCard(rows: _rows, resultColor: _result),
    const CalcInfoBox(
      description:
          'Kepler\'in üçüncü yasası, bir gezegenin yörünge periyodunun karesinin '
          'yarı-büyük ekseninin küpüyle orantılı olduğunu belirtir (T² ∝ a³). '
          'Evrensel çekim sabitiyle genelleştirilmiş hâli T = 2π√(a³/GM) '
          'formülünü verir; burada G evrensel çekim sabiti, M merkez cismin kütlesidir. '
          'Merkez kütle M⊕ (Dünya kütlesi = 5.972×10²⁴ kg) cinsindendir. '
          'Güneş sistemi hesapları için Güneş kütlesini 333 000 M⊕ olarak giriniz.',
      references: [
        'Kepler J. Harmonices Mundi. Linz: Johannes Plancus; 1619.',
        'Newton I. Philosophiæ Naturalis Principia Mathematica. London: Royal Society; 1687.',
      ],
    ),
  ]);
}
