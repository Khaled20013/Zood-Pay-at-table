import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';

/// Full-screen loader while the QR session resolves.
/// Table badge with concentric circles expanding outward.
class FindingTableLoader extends StatefulWidget {
  const FindingTableLoader({super.key, this.message});

  final String? message;

  @override
  State<FindingTableLoader> createState() => _FindingTableLoaderState();
}

class _FindingTableLoaderState extends State<FindingTableLoader>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _float;
  late final AnimationController _dots;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _dots = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    _float.dispose();
    _dots.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final baseMessage = widget.message ?? l10n.findingTable;
    final label = baseMessage.replaceFirst(RegExp(r'[.…]+$'), '').trimRight();

    const badge = _TableBadge(scale: 1);

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox.square(
                  dimension: 200,
                  child: reduceMotion
                      ? badge
                      : AnimatedBuilder(
                          animation: Listenable.merge([_pulse, _float]),
                          builder: (context, child) {
                            final float = Curves.easeInOut.transform(
                              _float.value,
                            );
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                for (var i = 0; i < 4; i++)
                                  _PulseRing(
                                    progress: (_pulse.value + i / 4) % 1,
                                    filled: i.isOdd,
                                  ),
                                Transform.translate(
                                  offset: Offset(0, -6 + 12 * float),
                                  child: Transform.scale(
                                    scale: 0.96 + 0.04 * float,
                                    child: child,
                                  ),
                                ),
                              ],
                            );
                          },
                          child: badge,
                        ),
                ),
                const SizedBox(height: 28),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                if (!reduceMotion) ...[
                  const SizedBox(height: 8),
                  _AnimatedDots(controller: _dots),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  const _PulseRing({required this.progress, required this.filled});

  final double progress;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeOut.transform(progress);
    final size = 72 + 110 * t;
    final opacity = (1 - t) * (filled ? 0.18 : 0.42);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled
            ? AppColors.primary.withValues(alpha: opacity)
            : Colors.transparent,
        border: filled
            ? null
            : Border.all(
                color: AppColors.primaryBright.withValues(alpha: opacity),
                width: 2.2,
              ),
      ),
    );
  }
}

class _TableBadge extends StatelessWidget {
  const _TableBadge({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.ctaGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.32),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(
          Icons.table_restaurant_rounded,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}

class _AnimatedDots extends StatelessWidget {
  const _AnimatedDots({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Opacity(
                  opacity: _dotOpacity(controller.value, i),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBright,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  double _dotOpacity(double value, int index) {
    final phase = (value + index / 3) % 1;
    return 0.25 + 0.75 * (0.5 + 0.5 * math.sin(phase * math.pi * 2));
  }
}
