import 'package:flutter/material.dart';

import 'package:zood_pay_at_table/Styles/AppColors.dart';
import 'package:zood_pay_at_table/Styles/AppTheme.dart';
import 'package:zood_pay_at_table/Widgets/LoadingIndicator.dart';
import 'package:zood_pay_at_table/Screens/Menu/Widgets/ProductCard.dart';

/// Animated category + product skeleton while the menu endpoints load.
class MenuLoadingSkeleton extends StatefulWidget {
  const MenuLoadingSkeleton({super.key});

  @override
  State<MenuLoadingSkeleton> createState() => _MenuLoadingSkeletonState();
}

class _MenuLoadingSkeletonState extends State<MenuLoadingSkeleton>
    with TickerProviderStateMixin {
  static const _cardCount = 5;

  late final AnimationController _enter;
  late final AnimationController _pulse;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 920),
    )..forward();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glow = CurvedAnimation(parent: _pulse, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _enter.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Animation<double> _slot(int index, int total) {
    final start = (index / (total + 2)).clamp(0.0, 1.0);
    final end = (start + 0.48).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _enter,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final totalSlots = 2 + _cardCount;

    Widget wrap(int index, Widget child) {
      if (reduceMotion) return child;
      final animation = _slot(index, totalSlots);
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      );
    }

    final content = ShimmerScope(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          wrap(0, const _CategoryChipsSkeleton()),
          const SizedBox(height: 18),
          wrap(1, const _SectionTitleSkeleton()),
          const SizedBox(height: 12),
          for (var i = 0; i < _cardCount; i++) ...[
            wrap(2 + i, const ProductCardSkeleton()),
            if (i < _cardCount - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );

    if (reduceMotion) return content;

    return AnimatedBuilder(
      animation: _glow,
      builder: (context, child) {
        final t = _glow.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.035 + 0.045 * t),
                blurRadius: 16 + 12 * t,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        );
      },
      child: content,
    );
  }
}

class _CategoryChipsSkeleton extends StatelessWidget {
  const _CategoryChipsSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          SkeletonBox(width: 72, height: 36, radius: 20),
          SizedBox(width: 8),
          SkeletonBox(width: 118, height: 36, radius: 20),
          SizedBox(width: 8),
          SkeletonBox(width: 96, height: 36, radius: 20),
          SizedBox(width: 8),
          SkeletonBox(width: 88, height: 36, radius: 20),
          SizedBox(width: 8),
          SkeletonBox(width: 104, height: 36, radius: 20),
        ],
      ),
    );
  }
}

class _SectionTitleSkeleton extends StatelessWidget {
  const _SectionTitleSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SkeletonBox(width: 4, height: 18, radius: 2),
        SizedBox(width: 10),
        SkeletonBox(width: 120, height: 16, radius: 6),
        SizedBox(width: 10),
        SkeletonBox(width: 28, height: 16, radius: 8),
      ],
    );
  }
}
