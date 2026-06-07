import 'package:flutter/material.dart';
import '../astronomy_engine.dart';
import '../../../shared/calc_form.dart';

const _accent = Color(0xFF9C6FD6);
const _result = Color(0xFFCE93D8);

class EscapeVelTab extends StatefulWidget {
  const EscapeVelTab({super.key});
  @override
  State<EscapeVelTab> createState() => _EscapeVelTabState();
}

class _EscapeVelTabState extends State<EscapeVelTab> {
  final _mass   = TextEditingController();
  final _radius = TextEditingController();
  List<CalcResultRow> _rows = [];

  void _calculate() {
    final mass   = parseField(_mass);
    final radius = parseField(_radius);
    if (mass == null || radius == null || mass <= 0 || radius <= 0) return;

    final res = calcEscapeVelocity(massKg: mass, radiusM: radius);
    setState(() => _rows = [
      CalcResultRow('Kaçış hızı',        fmt(res.kms), unit: 'km/s'),
      CalcResultRow('Kaçış hızı (m/s)',  fmt(res.ms),  unit: 'm/s'),
    ]);
  }

  @override
  void dispose() { _mass.dispose(); _radius.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => CalcScaffold(children: [
    CalcField(label: 'Kütle',   hint: '5.972e24', unit: 'kg', ctrl: _mass,   accentColor: _accent),
    CalcField(label: 'Yarıçap', hint: '6371000',  unit: 'm',  ctrl: _radius, accentColor: _accent),
    const Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Text('Dünya: 5.972×10²⁴ kg · 6 371 000 m  |  Ay: 7.34×10²² kg · 1 737 000 m',
          style: TextStyle(color: Color(0xFF607080), fontSize: 11)),
    ),
    CalcButton(onTap: _calculate, color: _accent),
    CalcResultCard(rows: _rows, resultColor: _result),
    const CalcInfoBox(
      description:
          'Kaçış hızı, bir cismin başka bir cismin yerçekiminden kurtulup '
          'sonsuza ulaşabilmesi için gereken minimum başlangıç hızıdır. '
          'Kinetik ve potansiyel enerji denkliğinden elde edilen '
          'vₑ = √(2GM/r) formülü atmosfer direncini ve dönme etkisini ihmal eder.',
      references: [
        'Newton I. Philosophiæ Naturalis Principia Mathematica. London: Royal Society; 1687.',
      ],
    ),
  ]);
}
