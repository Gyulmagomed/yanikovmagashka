import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Цвета одной темы (светлой или тёмной). Используйте [AppTheme.of(context)] в виджетах.
class AppThemeColors {
  const AppThemeColors({
    required this.background,
    required this.backgroundGradient,
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.borderBright,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
  });

  final Color background;
  final BoxDecoration backgroundGradient;
  final Color surface;
  final Color surfaceElevated;
  final Color border;
  final Color borderBright;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;

  static const AppThemeColors dark = AppThemeColors(
    background: Color(0xFF050505),
    backgroundGradient: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF050505),
          Color(0xFF070708),
          Color(0xFF08090A),
          Color(0xFF0A0B0C),
          Color(0xFF0C0D0E),
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
    ),
    surface: Color(0xFF111111),
    surfaceElevated: Color(0xFF1A1A1A),
    border: Color(0xFF2A2A2A),
    borderBright: Color(0xFF404040),
    textPrimary: Color(0xFFFAFAFA),
    textSecondary: Color(0xFFA3A3A3),
    accent: Colors.white,
  );

  static const AppThemeColors light = AppThemeColors(
    background: Color(0xFFF2F2F2),
    backgroundGradient: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFAFAFA),
          Color(0xFFF5F5F5),
          Color(0xFFF0F0F0),
          Color(0xFFEEEEEE),
          Color(0xFFEBEBEB),
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
    ),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFFAFAFA),
    border: Color(0xFFE8E8E8),
    borderBright: Color(0xFFD0D0D0),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF6B6B6B),
    accent: Color(0xFF1A1A1A),
  );
}

class AppTheme {
  AppTheme._();

  /// Цвета текущей темы (светлая/тёмная по контексту).
  static AppThemeColors of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppThemeColors.dark
        : AppThemeColors.light;
  }

  /// Обратная совместимость: статические тёмные цвета (для тем, где нет context).
  static const Color background = Color(0xFF050505);
  static const Color surface = Color(0xFF111111);
  static const Color surfaceElevated = Color(0xFF1A1A1A);
  static const Color border = Color(0xFF2A2A2A);
  static const Color borderBright = Color(0xFF404040);
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFFA3A3A3);
  static const Color accent = Colors.white;
  static BoxDecoration get backgroundGradient => AppThemeColors.dark.backgroundGradient;

  static ThemeData get dark => _buildTheme(AppThemeColors.dark);

  static ThemeData get light => _buildTheme(AppThemeColors.light);

  static ThemeData _buildTheme(AppThemeColors c) {
    return ThemeData(
      useMaterial3: true,
      brightness: c.background.computeLuminance() < 0.2 ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: c.background,
      colorScheme: c.background.computeLuminance() < 0.2
          ? ColorScheme.dark(
              surface: c.surface,
              onSurface: c.textPrimary,
              outline: c.border,
              primary: c.accent,
              onPrimary: c.background,
            )
          : ColorScheme.light(
              surface: c.surface,
              onSurface: c.textPrimary,
              outline: c.border,
              primary: c.accent,
              onPrimary: c.background,
            ),
      textTheme: GoogleFonts.outfitTextTheme(
        (c.background.computeLuminance() < 0.2 ? ThemeData.dark() : ThemeData.light()).textTheme.copyWith(
              headlineLarge: TextStyle(fontWeight: FontWeight.w200, letterSpacing: 12, color: c.textPrimary),
              headlineMedium: TextStyle(fontWeight: FontWeight.w300, letterSpacing: 2, color: c.textPrimary),
              titleLarge: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5, color: c.textPrimary),
              titleMedium: TextStyle(fontWeight: FontWeight.w500, color: c.textPrimary),
              bodyLarge: TextStyle(fontWeight: FontWeight.w400, color: c.textPrimary),
              bodyMedium: TextStyle(fontWeight: FontWeight.w400, color: c.textPrimary.withValues(alpha: 0.9)),
              labelLarge: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1, color: c.textPrimary),
            ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: c.textPrimary),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: c.textPrimary,
          letterSpacing: 4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.borderBright, width: 1.5),
        ),
        labelStyle: TextStyle(color: c.textSecondary),
        hintStyle: TextStyle(color: c.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: c.background,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: c.surfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: c.border, width: 1),
        ),
      ),
    );
  }
}
