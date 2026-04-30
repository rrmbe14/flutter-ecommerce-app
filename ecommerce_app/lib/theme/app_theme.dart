import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color _seed = Color(0xFF1F1F1F);
  static const String _fontFamily = 'Roboto';

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    final bool isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: isDark ? const Color(0xFF0E0E0E) : const Color(0xFFFAFAFA),
      dividerTheme: DividerThemeData(
        thickness: 0.5,
        space: 24,
        color: scheme.outlineVariant.withValues(alpha: 0.5),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF0E0E0E) : const Color(0xFFFAFAFA),
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w300,
          letterSpacing: 1.5,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? const Color(0xFF161616) : Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: BorderSide(color: scheme.onSurface.withValues(alpha: 0.4), width: 0.5),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.3), width: 0.5),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.3), width: 0.5),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.onSurface, width: 1),
        ),
        hintStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w300,
          color: scheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontFamily: _fontFamily, fontSize: 40, fontWeight: FontWeight.w300, letterSpacing: 1, color: scheme.onSurface),
        displayMedium: TextStyle(fontFamily: _fontFamily, fontSize: 32, fontWeight: FontWeight.w300, letterSpacing: 0.5, color: scheme.onSurface),
        headlineMedium: TextStyle(fontFamily: _fontFamily, fontSize: 22, fontWeight: FontWeight.w400, letterSpacing: 0.5, color: scheme.onSurface),
        titleLarge: TextStyle(fontFamily: _fontFamily, fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.3, color: scheme.onSurface),
        titleMedium: TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.3, color: scheme.onSurface),
        bodyLarge: TextStyle(fontFamily: _fontFamily, fontSize: 15, fontWeight: FontWeight.w300, height: 1.6, color: scheme.onSurface),
        bodyMedium: TextStyle(fontFamily: _fontFamily, fontSize: 13, fontWeight: FontWeight.w400, height: 1.5, color: scheme.onSurface.withValues(alpha: 0.8)),
        labelLarge: TextStyle(fontFamily: _fontFamily, fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 1.5, color: scheme.onSurface),
        labelMedium: TextStyle(fontFamily: _fontFamily, fontSize: 11, fontWeight: FontWeight.w400, letterSpacing: 1.2, color: scheme.onSurface.withValues(alpha: 0.6)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF0E0E0E) : const Color(0xFFFAFAFA),
        selectedItemColor: scheme.onSurface,
        unselectedItemColor: scheme.onSurface.withValues(alpha: 0.4),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w300, letterSpacing: 1),
      ),
    );
  }
}
