import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF1B3FDB);
  static const Color primaryDark = Color(0xFF102A8A);
  static const Color primaryBright = Color(0xFF4C74F0);
  static const Color primarySoft = Color(0xFFE7EDFB);
  static const Color accent = Color(0xFFE8892C);
  static const Color accentDeep = Color(0xFFC45C12);
  static const Color accentSoft = Color(0xFFF8E7D4);

  static const Color background = Color(0xFFF4F1EB);
  static const Color surface = Color(0xFFFFFCF8);
  static const Color surfaceMuted = Color(0xFFEFEBE4);
  static const Color border = Color(0xFFE4DDD2);

  static const Color ink = Color(0xFF1A1714);
  static const Color inkMuted = Color(0xFF6B6258);
  static const Color inkSubtle = Color(0xFF9A9086);

  static const Color success = Color(0xFF1BA160);
  static const Color error = Color(0xFFE04848);
  static const Color errorSoft = Color(0xFFFDE9E9);

  static const Color shimmerBase = Color(0xFFE8E2D8);
  static const Color shimmerHighlight = Color(0xFFF8F4EC);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0C1733), Color(0xFF16306E), Color(0xFF2450C8)],
  );

  /// Primary call-to-action fill (buttons, selected chips, cart bar).
  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF1B45D1), Color(0xFF3F6EF7)],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentDeep],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF0E1530), Color(0xFF1B2856)],
  );

  /// Scrim laid over cover photos so white text stays legible.
  static const LinearGradient photoScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x66061238), Color(0xCC07133D), Color(0xF2050E2E)],
    stops: [0, 0.55, 1],
  );

  static const List<BoxShadow> softShadow = [
    BoxShadow(color: Color(0x0F141C3A), blurRadius: 18, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x0A141C3A), blurRadius: 4, offset: Offset(0, 1)),
  ];

  static List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.35),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  /// Tints used for product artwork placeholders, keyed by category id.
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
