import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../modules/astronomy/widgets/kepler_tab.dart';
import '../modules/astronomy/widgets/escape_vel_tab.dart';
import '../modules/astronomy/widgets/gravity_tab.dart';
import '../modules/astronomy/widgets/schwarzschild_tab.dart';
import '../modules/astronomy/widgets/hubble_tab.dart';

const _kAccent = Color(0xFF9C6FD6);

class _Entry {
  final String label, subtitle;
  final Widget widget;
  const _Entry(this.label, this.subtitle, this.widget);
}

const _catalog = <_Entry>[
  _Entry('Kepler 3. Yasası',        'Yörünge periyodu — T = 2π√(a³/GM)',    KeplerTab()),
  _Entry('Kaçış Hızı',              'vₑ = √(2GM/r)',                         EscapeVelTab()),
  _Entry('Newton Çekim Kuvveti',    'F = Gm₁m₂/r²',                          GravityTab()),
  _Entry('Schwarzschild Yarıçapı',  'Kara delik — rₛ = 2GM/c²',             SchwarzschildTab()),
  _Entry('Hubble Yasası',           'Uzaklaşma hızı — v = H₀ × d',          HubbleTab()),
];

class AstronomyScreen extends StatefulWidget {
  const AstronomyScreen({super.key});
  @override
  State<AstronomyScreen> createState() => _AstronomyScreenState();
}

class _AstronomyScreenState extends State<AstronomyScreen> {
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
          'Astronomi',
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
        value: selectedIndex,
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
