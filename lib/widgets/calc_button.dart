import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Casio fx-991EX ClassWiz inspired button styles
enum ButtonStyle {
  number,    // gray-blue digit keys
  operator,  // arithmetic operator keys
  function,  // scientific function keys (dark navy)
  shift,     // SHIFT key (amber/gold)
  delete,    // AC / backspace (dark red)
  memory,    // memory keys (dark teal)
  accent,    // EXE / equals (blue)
}

/// [shiftLabel] — yellow text printed above the button (SHIFT function)
/// [alphaLabel] — red text printed above the button (ALPHA function)
class CalcButton extends StatefulWidget {
  final String label;
  final String? shiftLabel;  // shown in yellow above main label
  final String? alphaLabel;  // shown in red above main label
  final ButtonStyle style;
  final VoidCallback onTap;
  final double? fontSize;
  final int flex;

  const CalcButton({
    super.key,
    required this.label,
    this.shiftLabel,
    this.alphaLabel,
    this.style = ButtonStyle.number,
    required this.onTap,
    this.fontSize,
    this.flex = 1,
  });

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _press; // pixel offset, fixed 2 px
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 70),
    );
    _press = Tween<double>(begin: 0, end: 2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    setState(() => _pressed = true);
    _ctrl.forward();
    HapticFeedback.selectionClick();
  }

  void _onTapUp(_) {
    setState(() => _pressed = false);
    _ctrl.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
    _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final spec = _spec(widget.style);

    return Expanded(
      flex: widget.flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3.5),
        child: Semantics(
          button: true,
          label: _semanticLabel(),
          excludeSemantics: true,
          onTap: widget.onTap,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: AnimatedBuilder(
              animation: _press,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _press.value),
                child: child,
              ),
              child: _CasioKey(
                label: widget.label,
                shiftLabel: widget.shiftLabel,
                alphaLabel: widget.alphaLabel,
                spec: spec,
                pressed: _pressed,
                fontSize: widget.fontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Screen-reader friendly label including the SHIFT/ALPHA alternate functions.
  String _semanticLabel() {
    final buffer = StringBuffer(widget.label);
    if (widget.shiftLabel != null) {
      buffer.write(', SHIFT ${widget.shiftLabel}');
    }
    if (widget.alphaLabel != null) {
      buffer.write(', ALPHA ${widget.alphaLabel}');
    }
    return buffer.toString();
  }

  _KeySpec _spec(ButtonStyle s) {
    switch (s) {
      case ButtonStyle.number:
        return const _KeySpec(
          face: Color(0xFF3C4058),
          top:  Color(0xFF5A5F7A),
          bot:  Color(0xFF22253A),
          fg:   Colors.white,
        );
      case ButtonStyle.operator:
        return const _KeySpec(
          face: Color(0xFF2C3654),
          top:  Color(0xFF3E4E70),
          bot:  Color(0xFF18203A),
          fg:   Color(0xFFB8D4FF),
        );
      case ButtonStyle.function:
        return const _KeySpec(
          face: Color(0xFF222840),
          top:  Color(0xFF303858),
          bot:  Color(0xFF12162A),
          fg:   Color(0xFFD0DCF8),
        );
      case ButtonStyle.shift:
        return const _KeySpec(
          face: Color(0xFFB07800),
          top:  Color(0xFFD49200),
          bot:  Color(0xFF705000),
          fg:   Colors.white,
        );
      case ButtonStyle.delete:
        return const _KeySpec(
          face: Color(0xFF7A1A1A),
          top:  Color(0xFF9E2A2A),
          bot:  Color(0xFF4A0E0E),
          fg:   Color(0xFFFFCDD2),
        );
      case ButtonStyle.memory:
        return const _KeySpec(
          face: Color(0xFF1A3530),
          top:  Color(0xFF284D45),
          bot:  Color(0xFF0E1F1C),
          fg:   Color(0xFF80CBC4),
        );
      case ButtonStyle.accent:
        return const _KeySpec(
          face: Color(0xFF1A3D78),
          top:  Color(0xFF2A55A0),
          bot:  Color(0xFF0E2248),
          fg:   Colors.white,
        );
    }
  }
}

// ── Visual key widget ────────────────────────────────────────────────────────

class _CasioKey extends StatelessWidget {
  final String label;
  final String? shiftLabel;
  final String? alphaLabel;
  final _KeySpec spec;
  final bool pressed;
  final double? fontSize;

  const _CasioKey({
    required this.label,
    required this.shiftLabel,
    required this.alphaLabel,
    required this.spec,
    required this.pressed,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    // The 3-D illusion: a "base" block + a raised face on top.
    // When pressed, the face moves down and the base shrinks.
    const baseH = 4.0;
    final faceColor = pressed
        ? Color.lerp(spec.face, spec.bot, 0.35)!
        : spec.face;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Labels printed ABOVE button (on body, like real Casio) ──────────
        SizedBox(
          height: 14,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (shiftLabel != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    shiftLabel!,
                    style: const TextStyle(
                      color: Color(0xFFF5A623),   // Casio shift yellow
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      height: 1,
                    ),
                  ),
                ),
              if (alphaLabel != null)
                Text(
                  alphaLabel!,
                  style: const TextStyle(
                    color: Color(0xFFEF5350),     // Casio alpha red
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    height: 1,
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 1),

        // ── Key body ─────────────────────────────────────────────────────────
        Expanded(
          child: Stack(
            children: [
              // Base / shadow block
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: spec.bot,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),

              // Face — gradient simulates top-light bevel (no border needed)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: pressed ? 0 : baseH,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      // Three-stop gradient: bright top → face → slightly dark bottom
                      colors: [
                        Color.lerp(spec.top, Colors.white, 0.12)!,
                        faceColor,
                        Color.lerp(faceColor, spec.bot, 0.25)!,
                      ],
                      stops: const [0.0, 0.30, 1.0],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: spec.fg,
                        fontSize: fontSize ?? _autoSize(label),
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _autoSize(String s) {
    if (s.length >= 5) return 11;
    if (s.length == 4) return 12;
    if (s.length == 3) return 13;
    return 18;
  }
}

// ── Palette record ───────────────────────────────────────────────────────────

class _KeySpec {
  final Color face;   // main face colour
  final Color top;    // top-highlight / gradient start
  final Color bot;    // bottom-shadow / base block
  final Color fg;     // text/icon colour

  const _KeySpec({
    required this.face,
    required this.top,
    required this.bot,
    required this.fg,
  });
}
