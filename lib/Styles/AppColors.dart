import 'package:flutter/material.dart';

/// Zood Pay at Table palette — Teams / Dot-Ai identity.
/// See `docs/ZOOD_DESIGN_SYSTEM.md`.
abstract final class AppColors {
  static const Color primary = Color(0xFF004FEE);
  static const Color primaryDark = Color(0xFF0039C7);
  static const Color primaryBright = Color(0xFF4C7AF5);
  static const Color primarySoft = Color(0xFFE7EDFB);
  static const Color primaryDisabled = Color(0xFF82A9F8);

  /// Secondary highlight (blue family — not the old orange accent).
  static const Color accent = Color(0xFF4C7AF5);
  static const Color accentDeep = Color(0xFF0039C7);
  static const Color accentSoft = Color(0xFFE7EDFB);

  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEEF2FA);
  static const Color border = Color(0xFFF2F2F2);

  static const Color ink = Color(0xFF1C2434);
  static const Color inkMuted = Color(0xFF4D5F73);
  static const Color inkSubtle = Color(0xFF9B9B9B);

  static const Color success = Color(0xFF0F9F8A);
  static const Color successBorder = Color(0xFF1BDAC0);
  static const Color error = Color(0xFFC01148);
  static const Color errorSoft = Color(0xFFFDE9E9);

  static const Color shimmerBase = Color(0xFFE4E4EE);
  static const Color shimmerHighlight = Color(0xFFF5F7FD);

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEEF2FA), Color(0xFFF5F7FD), Color(0xFFEDF0F8)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0C1B4A), Color(0xFF0039C7), Color(0xFF004FEE)],
  );

  /// Primary call-to-action fill (buttons, selected chips, cart bar).
  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF0039C7), Color(0xFF004FEE), Color(0xFF4C7AF5)],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary, primaryBright],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF0C1B4A), Color(0xFF0039C7)],
  );

  /// Scrim laid over cover photos so white text stays legible.
  static const LinearGradient photoScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x660C1B4A), Color(0xCC0039C7), Color(0xF20039C7)],
    stops: [0, 0.55, 1],
  );

  static const List<BoxShadow> softShadow = [
    BoxShadow(color: Color(0x0F1C2434), blurRadius: 18, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x0A1C2434), blurRadius: 4, offset: Offset(0, 1)),
  ];

  static List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.35),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  /// Tints used for product artwork placeholders, keyed by category id.
  /// Decorative only — not brand colors.
  static const Map<String, List<Color>> categoryTints = {
    'hot_beverages': [Color(0xFFFFE6CC), Color(0xFFD9641E)],
    'cold_beverages': [Color(0xFFD6F0FB), Color(0xFF1F86B8)],
    'desserts': [Color(0xFFFFE0EA), Color(0xFFD0436F)],
  };

  /// Accepts a category id (`hot_beverages`) or English name
  /// (`Hot Beverages`).
  static String categoryKey(String? category) =>
      (category ?? '').trim().toLowerCase().replaceAll(' ', '_');

  static List<Color> tintFor(String? category) =>
      categoryTints[categoryKey(category)] ?? const [primarySoft, primary];
}
