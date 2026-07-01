import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

// ── CalcField ───────────────────────────────────────────────────────────────

class CalcField extends StatelessWidget {
  final String label;
  final String hint;
  final String unit;
  final TextEditingController ctrl;
  final bool allowDecimal;
  final Color accentColor;

  const CalcField({
    super.key,
    required this.label,
    required this.hint,
    required this.unit,
    required this.ctrl,
    this.allowDecimal = true,
    this.accentColor = const Color(0xFF4FC3F7),
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        SizedBox(
          width: 148,
          child: Text(label, style: TextStyle(color: colors.label, fontSize: 13)),
        ),
        Expanded(
          child: TextField(
            controller: ctrl,
            keyboardType:
                TextInputType.numberWithOptions(decimal: allowDecimal, signed: false),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  RegExp(allowDecimal ? r'[\d.eE+\-]' : r'\d')),
            ],
            style: TextStyle(color: colors.primaryText, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: colors.label.withValues(alpha: 0.55)),
              suffixText: unit,
              suffixStyle: TextStyle(color: colors.label, fontSize: 12),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: colors.fieldFill,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: accentColor, width: 1.5),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── CalcOptionRow — chip-based radio selector ───────────────────────────────

class CalcOptionRow extends StatelessWidget {
  final String label;
  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;
  final Color accentColor;

  const CalcOptionRow({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.accentColor = const Color(0xFF4FC3F7),
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        SizedBox(
          width: 148,
          child: Text(label, style: TextStyle(color: colors.label, fontSize: 13)),
        ),
        Wrap(
          spacing: 8,
          children: List.generate(
              options.length, (i) => _chip(context, options[i], i == selected, () => onChanged(i))),
        ),
      ]),
    );
  }

  Widget _chip(BuildContext context, String text, bool sel, VoidCallback onTap) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: sel ? accentColor.withValues(alpha: 0.15) : colors.card,
          border: Border.all(color: sel ? accentColor : colors.border, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: TextStyle(
                color: sel ? accentColor : colors.label,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ── CalcButton ──────────────────────────────────────────────────────────────

class CalcButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;

  const CalcButton({
    super.key,
    required this.onTap,
    this.color = const Color(0xFF4FC3F7),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.5),
          ),
          child: const Text('HESAPLA'),
        ),
      ),
    );
  }
}

// ── CalcResultCard ──────────────────────────────────────────────────────────

class CalcResultRow {
  final String label, value, unit;
  const CalcResultRow(this.label, this.value, {this.unit = ''});
}

class CalcResultCard extends StatelessWidget {
  final List<CalcResultRow> rows;
  final Color resultColor;

  const CalcResultCard({
    super.key,
    required this.rows,
    this.resultColor = const Color(0xFF80DEEA),
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: resultColor.withValues(alpha: 0.06),
        border: Border.all(color: resultColor.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sonuçlar',
              style: TextStyle(
                  color: resultColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1)),
          const SizedBox(height: 10),
          ...rows.map((r) => _rowWidget(context, r)),
        ],
      ),
    );
  }

  Widget _rowWidget(BuildContext context, CalcResultRow r) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Expanded(
            child: Text(r.label, style: TextStyle(color: colors.label, fontSize: 13))),
        Text(r.value,
            style: TextStyle(
                color: colors.primaryText,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace')),
        if (r.unit.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(r.unit, style: TextStyle(color: colors.label, fontSize: 12)),
          ),
      ]),
    );
  }
}

// ── CalcScaffold ─────────────────────────────────────────────────────────────

class CalcScaffold extends StatelessWidget {
  final List<Widget> children;
  const CalcScaffold({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.appColors.scaffoldBg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ),
    );
  }
}

// ── CalcInfoBox — collapsible description + references ───────────────────────

class CalcInfoBox extends StatefulWidget {
  final String description;
  final List<String> references;

  const CalcInfoBox({
    super.key,
    required this.description,
    this.references = const [],
  });

  @override
  State<CalcInfoBox> createState() => _CalcInfoBoxState();
}

class _CalcInfoBoxState extends State<CalcInfoBox> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: colors.card,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(children: [
                Icon(Icons.info_outline, size: 14, color: colors.label),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Formül Hakkında',
                      style: TextStyle(
                          color: colors.label,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18, color: colors.label),
              ]),
            ),
          ),
          if (_expanded) ...[
            Container(height: 1, color: colors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.description,
                      style: TextStyle(
                          color: colors.label, fontSize: 12, height: 1.65)),
                  if (widget.references.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text('Kaynaklar',
                        style: TextStyle(
                            color: colors.label,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 6),
                    ...widget.references.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${e.key + 1}. ',
                                style: TextStyle(
                                    color: colors.label, fontSize: 11)),
                            Expanded(
                              child: Text(e.value,
                                  style: TextStyle(
                                      color: colors.label,
                                      fontSize: 11,
                                      height: 1.55)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

String fmt(double v, {int decimals = 3}) {
  if (v.isNaN || v.isInfinite) return '—';
  final abs = v.abs();
  if (abs == 0) return '0';
  if (abs >= 1e5 || (abs < 0.01 && abs > 0)) {
    return v.toStringAsExponential(decimals);
  }
  return v.toStringAsFixed(decimals);
}

double? parseField(TextEditingController c) => double.tryParse(c.text.trim());
