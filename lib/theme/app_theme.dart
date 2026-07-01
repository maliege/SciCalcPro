import 'package:flutter/material.dart';

/// Semantic surface colors that adapt to light / dark mode.
///
/// The scientific keypad ([CalcButton]) and the LCD display are intentionally
/// kept dark in both themes to preserve the skeuomorphic Casio look, so they
/// do not read from this extension.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color scaffoldBg; // page background for form screens
  final Color calcBg; // background behind the calculator keypad
  final Color headerBg; // app bars, nav bar, section headers
  final Color card; // cards, dropdown menu surface, chips (unselected)
  final Color fieldFill; // text field fill
  final Color border; // outlines, dividers
  final Color label; // secondary / muted text
  final Color primaryText; // primary text on surfaces

  const AppColors({
    required this.scaffoldBg,
    required this.calcBg,
    required this.headerBg,
    required this.card,
    required this.fieldFill,
    required this.border,
    required this.label,
    required this.primaryText,
  });

  static const dark = AppColors(
    scaffoldBg: Color(0xFF0A0E1A),
    calcBg: Color(0xFF131825),
    headerBg: Color(0xFF0D1220),
    card: Color(0xFF111827),
    fieldFill: Color(0xFF0D1525),
    border: Color(0xFF1F2D42),
    label: Color(0xFF90A4AE),
    primaryText: Colors.white,
  );

  static const light = AppColors(
    scaffoldBg: Color(0xFFF4F6FA),
    calcBg: Color(0xFFE9ECF2),
    headerBg: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    fieldFill: Color(0xFFEEF1F6),
    border: Color(0xFFD3DAE6),
    label: Color(0xFF5A6B7B),
    primaryText: Color(0xFF1A2230),
  );

  @override
  AppColors copyWith({
    Color? scaffoldBg,
    Color? calcBg,
    Color? headerBg,
    Color? card,
    Color? fieldFill,
    Color? border,
    Color? label,
    Color? primaryText,
  }) {
    return AppColors(
      scaffoldBg: scaffoldBg ?? this.scaffoldBg,
      calcBg: calcBg ?? this.calcBg,
      headerBg: headerBg ?? this.headerBg,
      card: card ?? this.card,
      fieldFill: fieldFill ?? this.fieldFill,
      border: border ?? this.border,
      label: label ?? this.label,
      primaryText: primaryText ?? this.primaryText,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      scaffoldBg: Color.lerp(scaffoldBg, other.scaffoldBg, t)!,
      calcBg: Color.lerp(calcBg, other.calcBg, t)!,
      headerBg: Color.lerp(headerBg, other.headerBg, t)!,
      card: Color.lerp(card, other.card, t)!,
      fieldFill: Color.lerp(fieldFill, other.fieldFill, t)!,
      border: Color.lerp(border, other.border, t)!,
      label: Color.lerp(label, other.label, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
    );
  }
}

/// Convenience accessor: `context.appColors`.
extension AppColorsX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}

class AppTheme {
  const AppTheme._();

  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);
  static ThemeData light() => _build(Brightness.light, AppColors.light);

  static ThemeData _build(Brightness brightness, AppColors colors) {
    const seed = Color(0xFF00D4FF);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
      scaffoldBackgroundColor: colors.scaffoldBg,
      dividerColor: colors.border,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.headerBg,
        foregroundColor: colors.primaryText,
        elevation: 0,
      ),
      extensions: <ThemeExtension<dynamic>>[colors],
    );
  }
}
