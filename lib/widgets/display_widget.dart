import 'package:flutter/material.dart';

// Casio fx-991EX ClassWiz style LCD display panel
class DisplayWidget extends StatelessWidget {
  final String expression;
  final String display;
  final double memory;
  final bool isRadMode;
  final bool hasMemory;

  const DisplayWidget({
    super.key,
    required this.expression,
    required this.display,
    required this.memory,
    required this.isRadMode,
    required this.hasMemory,
  });

  @override
  Widget build(BuildContext context) {
    final bool isError = display == 'Tanımsız' ||
        display == 'Sıfıra bölme' ||
        display == 'Geçersiz kök';

    return Container(
      width: double.infinity,
      // Casio LCD bezel — dark navy frame
      margin: const EdgeInsets.fromLTRB(10, 8, 10, 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0D14),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF2A3048), width: 1.5),
        boxShadow: const [
          // Inner LCD glow
          BoxShadow(
            color: Color(0x22B8D4FF),
            blurRadius: 12,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Container(
        // LCD screen surface — slight blue-green tint like real Casio
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D1525), Color(0xFF0B1020)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Status indicators (like Casio indicator row) ──────────────
            Row(
              children: [
                _indicator(isRadMode ? 'Rad' : 'Deg',
                    const Color(0xFF90CAF9)),
                const SizedBox(width: 6),
                if (hasMemory)
                  _indicator('M', const Color(0xFF80CBC4)),
                const Spacer(),
                _indicator('S', const Color(0xFFF5A623),
                    active: false), // SHIFT indicator (off for now)
                const SizedBox(width: 4),
                _indicator('A', const Color(0xFFEF5350),
                    active: false), // ALPHA indicator
              ],
            ),

            const SizedBox(height: 8),

            // ── Expression / history line ─────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                expression.isEmpty ? ' ' : expression,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFF5A7A9A),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const SizedBox(height: 2),

            // ── Main result ───────────────────────────────────────────────
            // SizedBox sabit yükseklik verir: basamak sayısı ne olursa olsun
            // display paneli küçülmez, FittedBox metni yatayda ölçekler.
            SizedBox(
              height: 64,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 120),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: child,
                ),
                child: SizedBox(
                  key: ValueKey(display),
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      display,
                      style: TextStyle(
                        color: isError
                            ? const Color(0xFFFF5252)
                            : const Color(0xFFE8F0FF),
                        fontSize: 52,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Small indicator dot — like Casio's "Math / Rad / M / S / A" indicators
  Widget _indicator(String label, Color color, {bool active = true}) {
    return Text(
      label,
      style: TextStyle(
        color: active ? color : color.withValues(alpha: 0.18),
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }

}
