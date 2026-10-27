import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:zood_pay_at_table/Helper/L10n.dart';
import 'package:zood_pay_at_table/Styles/AppColors.dart';

/// A phone showing a table's menu, items being added one after another,
/// surrounded by floating "table / kitchen / paid" status chips.
///
/// [loop] is expected to repeat 0 → 1; a stopped animation renders a still.
class LandingIllustration extends StatelessWidget {
  const LandingIllustration({super.key, required this.loop});

  final Animation<double> loop;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Semantics(
      image: true,
      label: l10n.landingIllustrationLabel,
      child: ExcludeSemantics(
        child: SizedBox(
          width: 330,
          height: 370,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              _Disc(size: 300, alpha: 0.07),
              _Disc(size: 210, alpha: 0.07),
              _Floating(
                loop: loop,
                phase: 0,
                child: _Phone(loop: loop),
              ),
              PositionedDirectional(
                top: 34,
                start: 0,
                child: _Floating(
                  loop: loop,
                  phase: 0.3,
                  child: _StatusChip(
                    icon: Icons.table_restaurant_rounded,
                    iconColor: AppColors.primary,
                    label: l10n.tableNumber('7'),
                  ),
                ),
              ),
              PositionedDirectional(
                top: 156,
                end: 0,
                child: _Floating(
                  loop: loop,
                  phase: 0.62,
                  child: _StatusChip(
                    icon: Icons.soup_kitchen_rounded,
                    iconColor: AppColors.accentDeep,
                    label: l10n.landingChipKitchen,
                  ),
                ),
              ),
              PositionedDirectional(
                bottom: 34,
                start: 4,
                child: _Floating(
                  loop: loop,
                  phase: 0.15,
                  child: _StatusChip(
                    icon: Icons.check_circle_rounded,
                    iconColor: AppColors.success,
                    label: l10n.landingChipPaid,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

double _wave(double t, double phase) => math.sin((t + phase) * 2 * math.pi);

class _Disc extends StatelessWidget {
  const _Disc({required this.size, required this.alpha});

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }
}

class _Floating extends StatelessWidget {
  const _Floating({
    required this.loop,
    required this.phase,
    required this.child,
  });

  final Animation<double> loop;
  final double phase;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: loop,
      child: child,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _wave(loop.value, phase) * 7),
        child: child,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 7, 14, 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33060F33),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.ink,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _Phone extends StatelessWidget {
  const _Phone({required this.loop});

  static const List<(IconData, String)> _items = [
    (Icons.local_cafe_rounded, 'hot_beverages'),
    (Icons.local_drink_rounded, 'cold_beverages'),
    (Icons.cake_rounded, 'desserts'),
  ];

  final Animation<double> loop;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 176,
      height: 336,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1226),
        borderRadius: BorderRadius.circular(34),
        boxShadow: const [
          BoxShadow(
            color: Color(0x59060F33),
            blurRadius: 40,
            offset: Offset(0, 22),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: ColoredBox(
          color: AppColors.background,
          child: AnimatedBuilder(
            animation: loop,
            builder: (context, _) {
              final beat = loop.value * _items.length;
              final active = beat.floor() % _items.length;
              final tap = math.sin(math.pi * ((beat % 1) / 0.35).clamp(0, 1));
              return Padding(
                padding: const EdgeInsets.fromLTRB(9, 8, 9, 10),
                child: Column(
                  children: [
                    Container(
                      width: 46,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1226),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _ScreenHeader(),
                    const SizedBox(height: 10),
                    for (var i = 0; i < _items.length; i++) ...[
                      _MenuRow(
                        icon: _items[i].$1,
                        tint: AppColors.tintFor(_items[i].$2),
                        highlight: i == active ? tap : 0,
                      ),
                      const SizedBox(height: 7),
                    ],
                    const Spacer(),
                    _CartBar(count: active + 1, bump: tap),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Image.asset('assets/images/zood_mark.png', width: 26, height: 26),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bar(width: 64, color: Colors.white.withValues(alpha: 0.9)),
                const SizedBox(height: 6),
                _Bar(width: 40, color: Colors.white.withValues(alpha: 0.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.tint,
    required this.highlight,
  });

  final IconData icon;
  final List<Color> tint;

  /// 0 → idle, 1 → the "+" is being tapped.
  final double highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Color.lerp(AppColors.surface, AppColors.primarySoft, highlight),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color.lerp(AppColors.border, AppColors.primary, highlight)!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: tint.first,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 18, color: tint.last),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bar(width: 58, color: AppColors.ink),
                SizedBox(height: 6),
                _Bar(width: 32, color: AppColors.inkSubtle),
              ],
            ),
          ),
          Transform.scale(
            scale: 1 + 0.3 * highlight,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                gradient: AppColors.ctaGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartBar extends StatelessWidget {
  const _CartBar({required this.count, required this.bump});

  final int count;
  final double bump;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1 + 0.04 * bump,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          gradient: AppColors.ctaGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppColors.glow(AppColors.primary),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.shopping_bag_rounded,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Spacer(),
            _Bar(width: 40, color: Colors.white.withValues(alpha: 0.9)),
          ],
        ),
      ),
    );
  }
}

/// Skeleton text line.
class _Bar extends StatelessWidget {
  const _Bar({required this.width, required this.color});

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
