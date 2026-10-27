import 'package:flutter/material.dart';
import 'package:zood_pay_at_table/Styles/AppColors.dart';

abstract final class AppTheme {
  static const double radiusSm = 10;
  static const double radiusMd = 16;
  static const double radiusLg = 24;

  /// Content is capped to this width so tablet/desktop browsers get a
  /// centered, phone-like column instead of stretched cards.
  static const double maxContentWidth = 1080;

  /// Bundled in `assets/fonts/cairo`; one family for Arabic and Latin so
  /// mixed strings (e.g. "ادفع بـ mada") share metrics.
  static const String fontFamily = 'Cairo';

  /// Cairo's own vertical metrics are very tall; every style pins its line
  /// height and spreads the leading evenly so Arabic and Latin sit centered.
  static TextTheme _withLineHeights(TextTheme t) {
    TextStyle? h(TextStyle? style, double height) => style?.copyWith(
      height: height,
      leadingDistribution: TextLeadingDistribution.even,
    );
    return t.copyWith(
      displayLarge: h(t.displayLarge, 1.15),
      displayMedium: h(t.displayMedium, 1.15),
      displaySmall: h(t.displaySmall, 1.2),
      headlineLarge: h(t.headlineLarge, 1.25),
      headlineMedium: h(t.headlineMedium, 1.3),
      headlineSmall: h(t.headlineSmall, 1.3),
      titleLarge: h(t.titleLarge, 1.35),
      titleMedium: h(t.titleMedium, 1.4),
      titleSmall: h(t.titleSmall, 1.4),
      bodyLarge: h(t.bodyLarge, 1.5),
      bodyMedium: h(t.bodyMedium, 1.5),
      bodySmall: h(t.bodySmall, 1.45),
      labelLarge: h(t.labelLarge, 1.3),
      labelMedium: h(t.labelMedium, 1.3),
      labelSmall: h(t.labelSmall, 1.3),
    );
  }

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    final textTheme = _withLineHeights(
      base.textTheme
          .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink)
          .copyWith(
            headlineMedium: const TextStyle(
              fontFamily: fontFamily,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
            titleLarge: const TextStyle(
              fontFamily: fontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
            titleMedium: const TextStyle(
              fontFamily: fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
            bodyMedium: const TextStyle(
              fontFamily: fontFamily,
              fontSize: 14,
              color: AppColors.inkMuted,
            ),
            labelLarge: const TextStyle(
              fontFamily: fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.ink,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceMuted,
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.inkSubtle),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
    );
  }
}
