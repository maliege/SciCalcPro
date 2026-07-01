import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../modules/electronics/widgets/ohm_tab.dart';
import '../modules/electronics/widgets/power_tab.dart';
import '../modules/electronics/widgets/rc_tab.dart';
import '../modules/electronics/widgets/resonance_tab.dart';
import '../modules/electronics/widgets/vdivider_tab.dart';

const _kAccent = Color(0xFF66BB6A);

class _Entry {
  final String label, subtitle;
  final Widget widget;
  const _Entry(this.label, this.subtitle, this.widget);
}

const _catalog = <_Entry>[
  _Entry('Ohm Kanunu',         'V = I × R  — V, I veya R hesapla',           OhmTab()),
  _Entry('Elektrik Gücü',      'P = VI = I²R = V²/R',                         PowerTab()),
  _Entry('RC Devresi',         'τ = RC · şarj/deşarj eğrisi',                RcTab()),
  _Entry('LC Rezonansı',       'f₀ = 1 / (2π√LC)',                            ResonanceTab()),
  _Entry('Gerilim Bölücü',     'V_out = V_in × R₂/(R₁+R₂)',                 VDividerTab()),
];

class ElectronicsScreen extends StatefulWidget {
  const ElectronicsScreen({super.key});
  @override
  State<ElectronicsScreen> createState() => _ElectronicsScreenState();
}

class _ElectronicsScreenState extends State<ElectronicsScreen> {
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: colors.headerBg,
        elevation: 0,
        title: Text(
          'Elektronik',
          style: TextStyle(color: colors.primaryText, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Selector(catalog: _catalog, selectedIndex: _idx,
              onChanged: (i) => setState(() => _idx = i)),
          Expanded(
            child: IndexedStack(
              index: _idx,
              children: _catalog.map((e) => e.widget).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Selector extends StatelessWidget {
  final List<_Entry> catalog;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  const _Selector({required this.catalog, required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      color: colors.headerBg,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: DropdownButtonFormField<int>(
        initialValue: selectedIndex,
        dropdownColor: colors.card,
        iconEnabledColor: _kAccent,
        isExpanded: true,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          filled: true,
          fillColor: colors.fieldFill,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: _kAccent, width: 1.5),
          ),
        ),
        items: List.generate(catalog.length, (i) => DropdownMenuItem<int>(
          value: i,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(catalog[i].label,
                  style: TextStyle(color: colors.primaryText, fontSize: 14, fontWeight: FontWeight.w600)),
              Text(catalog[i].subtitle,
                  style: TextStyle(color: colors.label, fontSize: 11)),
            ],
          ),
        )),
        selectedItemBuilder: (_) => List.generate(catalog.length, (i) => Align(
          alignment: Alignment.centerLeft,
          child: Text(catalog[i].label,
              style: TextStyle(color: colors.primaryText, fontSize: 14, fontWeight: FontWeight.w600)),
        )),
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
    );
  }
}
