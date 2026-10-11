import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF1F4EE5);
  static const Color primaryDark = Color(0xFF1535A8);
  static const Color primaryBright = Color(0xFF4A7BFF);
  static const Color primarySoft = Color(0xFFE4EBFD);
  static const Color accent = Color(0xFFFFA62B);
  static const Color accentDeep = Color(0xFFF2711C);
  static const Color accentSoft = Color(0xFFFFF0DB);

  static const Color background = Color(0xFFF6F8FC);
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFEEF1F7);
  static const Color border = Color(0xFFE2E7F0);

  static const Color ink = Color(0xFF111A33);
  static const Color inkMuted = Color(0xFF5A6480);
  static const Color inkSubtle = Color(0xFF8D96AD);

  static const Color success = Color(0xFF1BA160);
  static const Color error = Color(0xFFE04848);
  static const Color errorSoft = Color(0xFFFDE9E9);

  static const Color shimmerBase = Color(0xFFE6EBF4);
  static const Color shimmerHighlight = Color(0xFFF7F9FD);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B1E66), Color(0xFF1A3FC4), Color(0xFF3D6DFF)],
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
