import 'package:flutter/material.dart';

/// Semantic colors used across the app. Read them with `context.colors`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color navBar;
  final Color border;
  final Color primary;
  final Color primaryLight;
  final Color primarySoft;
  final Color onPrimary;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color success;
  final Color danger;
  final Color warning;
  final Color glass;
  final Color glassOutline;
  final Color shadow;

  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.navBar,
    required this.border,
    required this.primary,
    required this.primaryLight,
    required this.primarySoft,
    required this.onPrimary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.danger,
    required this.warning,
    required this.glass,
    required this.glassOutline,
    required this.shadow,
  });

  static const light = AppColors(
    background: Color(0xFFF3F8FD),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEAF3FC),
    navBar: Color(0xFFFFFFFF),
    border: Color(0xFFDCE8F5),
    primary: Color(0xFF1E88E5),
    primaryLight: Color(0xFF5DB4FF),
    primarySoft: Color(0xFFDDEEFF),
    onPrimary: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF0D2541),
    textSecondary: Color(0xFF5A6F88),
    textMuted: Color(0xFF94A6BC),
    success: Color(0xFF1FA971),
    danger: Color(0xFFE5484D),
    warning: Color(0xFFF97316),
    glass: Color(0xFFE3F0FC),
    glassOutline: Color(0xFFBFDBF7),
    shadow: Color(0x1A1E5AA0),
  );

  static const dark = AppColors(
    background: Color(0xFF0E1621),
    surface: Color(0xFF16202A),
    surfaceAlt: Color(0xFF1B2633),
    navBar: Color(0xFF0B1220),
    border: Color(0xFF1E2A3A),
    primary: Color(0xFF2F8BEF),
    primaryLight: Color(0xFF5DB4FF),
    primarySoft: Color(0xFF223A55),
    onPrimary: Color(0xFFFFFFFF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0x8AFFFFFF),
    textMuted: Color(0x61FFFFFF),
    success: Color(0xFF4ADE80),
    danger: Color(0xFFFF5252),
    warning: Color(0xFFF97316),
    glass: Color(0xFF0F172A),
    glassOutline: Color(0x14FFFFFF),
    shadow: Color(0x40000000),
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceAlt: l(surfaceAlt, other.surfaceAlt),
      navBar: l(navBar, other.navBar),
      border: l(border, other.border),
      primary: l(primary, other.primary),
      primaryLight: l(primaryLight, other.primaryLight),
      primarySoft: l(primarySoft, other.primarySoft),
      onPrimary: l(onPrimary, other.onPrimary),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textMuted: l(textMuted, other.textMuted),
      success: l(success, other.success),
      danger: l(danger, other.danger),
      warning: l(warning, other.warning),
      glass: l(glass, other.glass),
      glassOutline: l(glassOutline, other.glassOutline),
      shadow: l(shadow, other.shadow),
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get colors {
    final theme = Theme.of(this);
    return theme.extension<AppColors>() ??
        (theme.brightness == Brightness.dark ? AppColors.dark : AppColors.light);
  }
}

class AppTheme {
  static ThemeData get light => _build(AppColors.light, Brightness.light);
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: c.primary,
      brightness: brightness,
    ).copyWith(
      primary: c.primary,
      onPrimary: c.onPrimary,
      surface: c.surface,
      onSurface: c.textPrimary,
      error: c.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Inter',
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      extensions: [c],
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          color: c.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.textPrimary == Colors.white
            ? const Color(0xFF1E2A38)
            : const Color(0xFF0D2541),
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter',
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: c.primaryLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          color: c.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(fontFamily: 'Inter', color: c.textSecondary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : c.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? c.primary
              : c.surfaceAlt,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : c.border,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.primary),
      textSelectionTheme: TextSelectionThemeData(cursorColor: c.primary),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: c.surface,
        hourMinuteColor: c.primarySoft,
        hourMinuteTextColor: c.textPrimary,
        dialHandColor: c.primary,
        dialBackgroundColor: c.surfaceAlt,
        dayPeriodColor: c.primarySoft,
        dayPeriodTextColor: c.textPrimary,
        dayPeriodBorderSide: BorderSide(color: c.primary),
        entryModeIconColor: c.primary,
        helpTextStyle: TextStyle(color: c.textSecondary, fontSize: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(backgroundColor: WidgetStatePropertyAll(c.surface)),
      ),
    );
  }
}
