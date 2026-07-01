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

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(10, 8, 10, 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF1A2535), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A3060A0),
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
              child: CustomPaint(painter: _DotMatrixPainter()),
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
                      _indicator(isRadMode ? 'Rad' : 'Deg',
                          const Color(0xFF58A8D8)),
                      const SizedBox(width: 6),
                      if (hasMemory)
                        _indicator('M', const Color(0xFF48B8B0)),
                      const Spacer(),
                      _indicator('S', const Color(0xFFD09030), active: false),
                      const SizedBox(width: 4),
                      _indicator('A', const Color(0xFFCC4444), active: false),
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
                      style: GoogleFonts.vt323(
                        color: const Color(0xFF3A6888),
                        fontSize: 16,
                        letterSpacing: 0.6,
                        height: 1.0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 2),

                  // ── Main result — dot-matrix pixel font ────────────────────
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
                            style: GoogleFonts.vt323(
                              color: isError
                                  ? const Color(0xFFFF4040)
                                  : const Color(0xFF98D8F8),
                              fontSize: 62,
                              letterSpacing: 2.5,
                              height: 1.0,
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
      style: GoogleFonts.vt323(
        color: active ? color : color.withOpacity(0.15),
        fontSize: 12,
        letterSpacing: 0.4,
        height: 1.0,
      ),
    );
  }
}

// Çok hafif unlit dot grid — gerçek dot-matrix LCD ekran dokusu
class _DotMatrixPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // LCD arka plan rengi
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF070B10),
    );

    // Sönük piksel ızgarası — Casio dot-matrix LCD'nin "off" pikselleri
    final dot = Paint()
      ..color = const Color(0x1890C0E0)
      ..style = PaintingStyle.fill;

    const double pitch = 3.5; // piksel arası mesafe
    const double r = 0.75;    // piksel yarıçapı

    for (double x = r; x < size.width; x += pitch) {
      for (double y = r; y < size.height; y += pitch) {
        canvas.drawCircle(Offset(x, y), r, dot);
      }
    }
  }

  @override
  bool shouldRepaint(_DotMatrixPainter old) => false;
}
