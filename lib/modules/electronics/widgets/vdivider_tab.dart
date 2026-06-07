import 'package:flutter/material.dart';
import '../electronics_engine.dart';
import '../../../shared/calc_form.dart';

const _accent = Color(0xFF66BB6A);
const _result = Color(0xFFA5D6A7);

class VDividerTab extends StatefulWidget {
  const VDividerTab({super.key});
  @override
  State<VDividerTab> createState() => _VDividerTabState();
}

class _VDividerTabState extends State<VDividerTab> {
  final _vin = TextEditingController();
  final _r1  = TextEditingController();
  final _r2  = TextEditingController();
  List<CalcResultRow> _rows = [];

  void _calculate() {
    final vin = parseField(_vin);
    final r1  = parseField(_r1);
    final r2  = parseField(_r2);
    if (vin == null || r1 == null || r2 == null) return;
    if (vin <= 0 || r1 <= 0 || r2 <= 0) return;

    final res = calcVoltageDivider(vin: vin, r1: r1, r2: r2);
    setState(() => _rows = [
      CalcResultRow('Çıkış gerilimi (V_out)',   fmt(res.vout,   decimals: 3), unit: 'V'),
      CalcResultRow('R₁ gerilim düşümü',        fmt(res.vDrop1, decimals: 3), unit: 'V'),
      CalcResultRow('Devre akımı (I)',           fmt(res.current * 1000, decimals: 3), unit: 'mA'),
      CalcResultRow('Toplam güç tüketimi',       fmt(res.power * 1000, decimals: 3), unit: 'mW'),
    ]);
  }

  @override
  void dispose() { _vin.dispose(); _r1.dispose(); _r2.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => CalcScaffold(children: [
    CalcField(label: 'Giriş gerilimi (V_in)', hint: '12',    unit: 'V', ctrl: _vin, accentColor: _accent),
    CalcField(label: 'R₁',                    hint: '10000', unit: 'Ω', ctrl: _r1,  accentColor: _accent),
    CalcField(label: 'R₂',                    hint: '10000', unit: 'Ω', ctrl: _r2,  accentColor: _accent),
    CalcButton(onTap: _calculate, color: _accent),
    CalcResultCard(rows: _rows, resultColor: _result),
    const CalcInfoBox(
      description:
          'Gerilim bölücü devre, Kirchhoff\'un gerilim yasası ve Ohm Kanunu\'ndan '
          'türetilen V_out = V_in × R₂/(R₁+R₂) bağıntısını uygular. '
          'Yük direnci bağlandığında gerçek çıkış gerilimi bu değerden düşer; '
          'hassas uygulamalarda yük etkisi göz önüne alınmalıdır.',
      references: [
        'Kirchhoff GR. Ueber den Durchgang eines elektrischen Stromes durch eine Ebene. '
            'Ann Phys Chem. 1845;64:497–514.',
      ],
    ),
  ]);
}
