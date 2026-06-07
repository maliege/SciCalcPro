import 'package:flutter/material.dart';
import '../astronomy_engine.dart';
import '../../../shared/calc_form.dart';

const _accent = Color(0xFF9C6FD6);
const _result = Color(0xFFCE93D8);

class HubbleTab extends StatefulWidget {
  const HubbleTab({super.key});
  @override
  State<HubbleTab> createState() => _HubbleTabState();
}

class _HubbleTabState extends State<HubbleTab> {
  final _dist = TextEditingController();
  final _h0   = TextEditingController(text: '70');
  List<CalcResultRow> _rows = [];

  void _calculate() {
    final dist = parseField(_dist);
    final h0   = parseField(_h0);
    if (dist == null || h0 == null || dist <= 0 || h0 <= 0) return;

    final res = calcHubble(distanceMpc: dist, h0KmsMpc: h0);
    setState(() => _rows = [
      CalcResultRow('Uzaklaşma hızı', fmt(res.kms, decimals: 1), unit: 'km/s'),
      CalcResultRow('Yaklaşık kırmızıya kayma (z)', fmt(res.redshiftZ, decimals: 5)),
    ]);
  }

  @override
  void dispose() { _dist.dispose(); _h0.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => CalcScaffold(children: [
    CalcField(label: 'Mesafe',  hint: '100', unit: 'Mpc',       ctrl: _dist, accentColor: _accent),
    CalcField(label: 'H₀',      hint: '70',  unit: 'km/s/Mpc',  ctrl: _h0,   accentColor: _accent),
    const Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Text('1 Mpc = 3.26 milyon ışık yılı  |  ΛCDM: H₀ ≈ 67–73 km/s/Mpc',
          style: TextStyle(color: Color(0xFF607080), fontSize: 11)),
    ),
    CalcButton(onTap: _calculate, color: _accent),
    CalcResultCard(rows: _rows, resultColor: _result),
    const CalcInfoBox(
      description:
          'Hubble-Lemaître Yasası, uzak gökadaların bizden uzaklaşma hızının '
          'mesafeyle orantılı olduğunu gösterir: v = H₀ × d. H₀ Hubble sabitidir '
          '(güncel değer ~67–73 km/s/Mpc). Yaklaşık kırmızıya kayma z ≈ v/c '
          'bağıntısı yalnızca z << 1 (yakın evren) için geçerlidir.',
      references: [
        'Hubble E. A relation between distance and radial velocity among extra-galactic '
            'nebulae. Proc Natl Acad Sci USA. 1929;15(3):168–173.',
        'Riess AG, et al. A Comprehensive Measurement of the Local Value of the Hubble '
            'Constant with 1 km/s/Mpc Uncertainty. '
            'Astrophys J Lett. 2022;934(1):L7.',
      ],
    ),
  ]);
}
