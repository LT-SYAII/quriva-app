import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Monochrome (black & white) Quriva theme with a "liquid glass" feel:
/// translucent surfaces, hairline borders and no colored tints.
abstract final class QurivaTheme {
  static const _darkBase = Color(0xFF050505);
  static const _darkCard = Color(0xFF0E0E0F);
  static const _lightBase = Color(0xFFFAFAFA);
  static const _lightCard = Color(0xFFFFFFFF);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static SystemUiOverlayStyle _overlay(Brightness brightness) => switch (brightness) {
        Brightness.dark => SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: _darkBase,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
        Brightness.light => SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: _lightBase,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
      };

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF8F8F8F),
      brightness: brightness,
    ).copyWith(
      surface: isDark ? _darkBase : _lightBase,
      onSurface: isDark ? Colors.white : const Color(0xFF0A0A0A),
      primary: isDark ? Colors.white : const Color(0xFF0A0A0A),
      onPrimary: isDark ? _darkBase : Colors.white,
      surfaceTint: Colors.transparent,
    );

    final hairline = isDark
        ? Colors.white.withValues(alpha: .08)
        : Colors.black.withValues(alpha: .07);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        systemOverlayStyle: _overlay(brightness),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? _darkCard : _lightCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: hairline),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        height: 62,
        indicatorColor: scheme.primary.withValues(alpha: .12),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: .05) : Colors.black.withValues(alpha: .03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: scheme.onSurface.withValues(alpha: .35),
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? const Color(0xFF0B0B0C) : _lightCard,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
      ),
      dividerTheme: DividerThemeData(color: hairline, thickness: 1, space: 1),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          side: WidgetStatePropertyAll(BorderSide(color: hairline)),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            if (selected) return scheme.onSurface.withValues(alpha: .10);
            return Colors.transparent;
          }),
        ),
      ),
    );
  }
}
