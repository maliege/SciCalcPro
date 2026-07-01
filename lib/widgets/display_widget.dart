import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final _LcdPalette p = isLight ? _LcdPalette.light : _LcdPalette.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(10, 8, 10, 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: p.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: p.glow,
            blurRadius: 14,
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Stack(
          children: [
            // Layer 1: dot matrix LCD background (solid fill + unlit pixel dots)
            Positioned.fill(
              child: CustomPaint(
                painter: _DotMatrixPainter(bg: p.bg, dot: p.dot),
              ),
            ),

            // Layer 2: content
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Status bar ───────────────────────────────────────────
                  Row(
                    children: [
                      _indicator(isRadMode ? 'Rad' : 'Deg', p.indRad),
                      const SizedBox(width: 6),
                      if (hasMemory) _indicator('M', p.indMem),
                      const Spacer(),
                      _indicator('S', p.indShift, active: false),
                      const SizedBox(width: 4),
                      _indicator('A', p.indAlpha, active: false),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // ── Expression / history line ─────────────────────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      expression.isEmpty ? ' ' : expression,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.orbitron(
                        color: p.secondaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        height: 1.0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 2),

                  // ── Main result — digital display font ─────────────────────
                  SizedBox(
                    height: 64,
                    child: Semantics(
                      liveRegion: true,
                      label: isError ? 'Hata: $display' : 'Sonuç: $display',
                      excludeSemantics: true,
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
                              style: GoogleFonts.orbitron(
                                color: isError ? p.errorText : p.mainText,
                                fontSize: 52,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _indicator(String label, Color color, {bool active = true}) {
    return Text(
      label,
      style: GoogleFonts.orbitron(
        color: active ? color : color.withOpacity(0.18),
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        height: 1.0,
      ),
    );
  }
}

// LCD renk paleti — koyu ve açık tema için ayrı takımlar
class _LcdPalette {
  final Color bg;
  final Color dot;
  final Color border;
  final Color glow;
  final Color mainText;
  final Color secondaryText;
  final Color errorText;
  final Color indRad;
  final Color indMem;
  final Color indShift;
  final Color indAlpha;

  const _LcdPalette({
    required this.bg,
    required this.dot,
    required this.border,
    required this.glow,
    required this.mainText,
    required this.secondaryText,
    required this.errorText,
    required this.indRad,
    required this.indMem,
    required this.indShift,
    required this.indAlpha,
  });

  // Koyu tema — mavi parıltılı LCD (mevcut görünüm)
  static const dark = _LcdPalette(
    bg: Color(0xFF070B10),
    dot: Color(0x1890C0E0),
    border: Color(0xFF1A2535),
    glow: Color(0x1A3060A0),
    mainText: Color(0xFF98D8F8),
    secondaryText: Color(0xFF3A6888),
    errorText: Color(0xFFFF4040),
    indRad: Color(0xFF58A8D8),
    indMem: Color(0xFF48B8B0),
    indShift: Color(0xFFD09030),
    indAlpha: Color(0xFFCC4444),
  );

  // Açık tema — klasik Casio yeşilimsi gri LCD, koyu gri rakamlar
  static const light = _LcdPalette(
    bg: Color(0xFFC3CBB4),
    dot: Color(0x14263018),
    border: Color(0xFF8B937B),
    glow: Color(0x22000000),
    mainText: Color(0xFF232B1A),
    secondaryText: Color(0xFF5A6350),
    errorText: Color(0xFFA01818),
    indRad: Color(0xFF2E5878),
    indMem: Color(0xFF1E6860),
    indShift: Color(0xFF7A5410),
    indAlpha: Color(0xFF8A2020),
  );
}

// Çok hafif unlit dot grid — gerçek dot-matrix LCD ekran dokusu
class _DotMatrixPainter extends CustomPainter {
  final Color bg;
  final Color dot;

  const _DotMatrixPainter({required this.bg, required this.dot});

  @override
  void paint(Canvas canvas, Size size) {
    // LCD arka plan rengi
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = bg,
    );

    // Sönük piksel ızgarası — Casio dot-matrix LCD'nin "off" pikselleri
    final dotPaint = Paint()
      ..color = dot
      ..style = PaintingStyle.fill;

    const double pitch = 3.5; // piksel arası mesafe
    const double r = 0.75;    // piksel yarıçapı

    for (double x = r; x < size.width; x += pitch) {
      for (double y = r; y < size.height; y += pitch) {
        canvas.drawCircle(Offset(x, y), r, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotMatrixPainter old) =>
      old.bg != bg || old.dot != dot;
}
