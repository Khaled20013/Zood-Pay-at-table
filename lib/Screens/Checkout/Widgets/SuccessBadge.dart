import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'package:zood_pay_at_table/Styles/AppColors.dart';

/// A ring sweeps around, a white plate pops in, a check draws itself, then
/// a ripple and confetti burst out. Driven by [animation] going 0 → 1.
class SuccessBadge extends StatelessWidget {
  const SuccessBadge({super.key, required this.animation, this.size = 116});

  final Animation<double> animation;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) =>
            CustomPaint(painter: _BadgePainter(animation.value)),
      ),
    );
  }
}

double _interval(double t, double begin, double end) =>
    ((t - begin) / (end - begin)).clamp(0.0, 1.0);

class _Confetto {
  const _Confetto({
    required this.angle,
    required this.speed,
    required this.spin,
    required this.color,
    required this.round,
    required this.scale,
  });

  final double angle;

  /// Travel distance as a multiple of the badge radius.
  final double speed;
  final double spin;
  final Color color;
  final bool round;
  final double scale;
}

final List<_Confetto> _confetti = () {
  final random = math.Random(11);
  const colors = [
    AppColors.accent,
    AppColors.accentDeep,
    Color(0xFF9DB8FF),
    Color(0xFF7CF0B8),
    Colors.white,
    Color(0xFFFFD66B),
  ];
  return List.generate(30, (i) {
    return _Confetto(
      angle: (i / 30) * 2 * math.pi + random.nextDouble() * 0.4,
      speed: 1.3 + random.nextDouble() * 1.5,
      spin: (random.nextDouble() - 0.5) * 12,
      color: colors[i % colors.length],
      round: random.nextBool(),
      scale: 0.7 + random.nextDouble() * 0.6,
    );
  });
}();

class _BadgePainter extends CustomPainter {
  _BadgePainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final disc = r - 12;

    _paintConfetti(canvas, center, r);

    final ripple = _interval(t, 0.32, 0.75);
    if (ripple > 0 && ripple < 1) {
      canvas.drawCircle(
        center,
        lerpDouble(disc, r * 1.9, Curves.easeOutCubic.transform(ripple))!,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(
            0xFF7CF0B8,
          ).withValues(alpha: 0.5 * (1 - ripple)),
      );
    }

    final sweep = Curves.easeInOut.transform(_interval(t, 0, 0.25));
    if (sweep > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r - 2),
        -math.pi / 2,
        2 * math.pi * sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(
            alpha: lerpDouble(0.65, 0.3, _interval(t, 0.35, 0.6))!,
          ),
      );
    }

    final pop = Curves.easeOutBack.transform(_interval(t, 0.15, 0.35));
    if (pop > 0) {
      final discPath = Path()
        ..addOval(Rect.fromCircle(center: center, radius: disc * pop));
      canvas.drawShadow(discPath, const Color(0xFF060F33), 10, false);
      canvas.drawPath(discPath, Paint()..color = Colors.white);
    }

    final draw = Curves.easeOutCubic.transform(_interval(t, 0.3, 0.48));
    if (draw > 0) {
      final check = Path()
        ..moveTo(center.dx - disc * 0.42, center.dy + disc * 0.02)
        ..lineTo(center.dx - disc * 0.12, center.dy + disc * 0.32)
        ..lineTo(center.dx + disc * 0.45, center.dy - disc * 0.3);
      final metric = check.computeMetrics().first;
      canvas.drawPath(
        metric.extractPath(0, metric.length * draw),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = disc * 0.17
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = AppColors.primary,
      );
    }
  }

  void _paintConfetti(Canvas canvas, Offset center, double r) {
    final c = _interval(t, 0.32, 0.92);
    if (c <= 0 || c >= 1) return;
    final travel = Curves.easeOutCubic.transform(c);
    final opacity = 1 - _interval(c, 0.55, 1);
    final paint = Paint();
    for (final p in _confetti) {
      final offset =
          center +
          Offset(math.cos(p.angle), math.sin(p.angle)) *
              (p.speed * r * travel) +
          Offset(0, 0.9 * r * c * c);
      paint.color = p.color.withValues(alpha: opacity);
      canvas
        ..save()
        ..translate(offset.dx, offset.dy)
        ..rotate(p.spin * c);
      if (p.round) {
        canvas.drawCircle(Offset.zero, 3.2 * p.scale, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: 9 * p.scale,
              height: 4.5 * p.scale,
            ),
            const Radius.circular(1.5),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BadgePainter old) => old.t != t;
}
