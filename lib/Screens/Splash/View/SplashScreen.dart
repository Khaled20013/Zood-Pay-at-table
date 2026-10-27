import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:zood_pay_at_table/Helper/L10n.dart';
import 'package:zood_pay_at_table/Styles/AppColors.dart';
import 'package:zood_pay_at_table/Widgets/Reveal.dart';

import '../Controller/SplashController.dart';

/// Branded intro: the Zood mark lands like a plate on the table, a QR frame
/// scans it, then the scan → order → pay journey plays before the landing
/// page fades in.
///
/// A deep link arriving mid-animation replaces this route, which disposes
/// the controller and cancels the hand-off to the landing page.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String routeName = "/splash";

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _duration = Duration(milliseconds: 3200);
  static const Duration _reducedMotionHold = Duration(milliseconds: 900);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
  );
  Timer? _hold;
  bool _started = false;
  late SplashController _screenController;

  @override
  void initState() {
    super.initState();
    _screenController = SplashController(refresh);
    _screenController.onInit();
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      _hold = Timer(_reducedMotionHold, _finish);
    } else {
      // TickerFuture never completes if the ticker is canceled by dispose.
      _controller.forward().whenComplete(_finish);
    }
  }

  void _finish() {
    if (mounted) _screenController.finish();
  }

  @override
  void dispose() {
    _hold?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final textTheme = Theme.of(context).textTheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _Backdrop(animation: _controller),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: 340,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _Emblem(animation: _controller),
                            const SizedBox(height: 20),
                            Reveal(
                              animation: _controller,
                              begin: 0.56,
                              end: 0.76,
                              child: Text(
                                l10n.appTitle,
                                textAlign: TextAlign.center,
                                style: textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Reveal(
                              animation: _controller,
                              begin: 0.62,
                              end: 0.82,
                              child: Text(
                                l10n.scanCardTitle,
                                textAlign: TextAlign.center,
                                style: textTheme.titleMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.78),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 36),
                            _Journey(animation: _controller),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: Reveal(
                      animation: _controller,
                      begin: 0.8,
                      end: 0.98,
                      offset: const Offset(0, 0.6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/zood_mark.png',
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              l10n.poweredByZoodPos,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

double _interval(double t, double begin, double end) =>
    ((t - begin) / (end - begin)).clamp(0.0, 1.0);

class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final fade = animation.drive(
      CurveTween(curve: const Interval(0, 0.5, curve: Curves.easeOut)),
    );
    return FadeTransition(
      opacity: fade,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.3),
                radius: 0.8,
                colors: [
                  AppColors.primaryBright.withValues(alpha: 0.35),
                  AppColors.primaryBright.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            end: -70,
            bottom: -50,
            child: Icon(
              Icons.qr_code_2_rounded,
              size: 300,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          PositionedDirectional(
            start: -40,
            top: 60,
            child: Icon(
              Icons.restaurant_rounded,
              size: 160,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
        ],
      ),
    );
  }
}

/// The plate-shaped mark, the ripples it sends out and the QR frame that
/// scans it.
class _Emblem extends StatelessWidget {
  const _Emblem({required this.animation});

  static const double _size = 260;
  static const double _plate = 132;
  static const double _frame = 184;

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: _size,
      child: AnimatedBuilder(
        animation: animation,
        child: const _Plate(size: _plate),
        builder: (context, plate) {
          final t = animation.value;
          final land = Curves.easeOutBack.transform(_interval(t, 0, 0.3));
          final spin = Curves.easeOutCubic.transform(_interval(t, 0, 0.3));
          final pulse = math.sin(math.pi * _interval(t, 0.6, 0.7)) * 0.08;
          final frameIn = Curves.easeOutCubic.transform(
            _interval(t, 0.28, 0.42),
          );
          final frameOut = _interval(t, 0.62, 0.72);
          final scan = Curves.easeInOutSine.transform(_interval(t, 0.38, 0.62));
          final scanOpacity = (math.sin(math.pi * scan) * 2).clamp(0.0, 1.0);

          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _RipplePainter(t, innerRadius: _plate / 2),
                ),
              ),
              Opacity(
                opacity: frameIn * (1 - frameOut),
                child: Transform.scale(
                  scale: lerpDouble(1.35, 1, frameIn)! + frameOut * 0.12,
                  child: const SizedBox.square(
                    dimension: _frame,
                    child: CustomPaint(
                      painter: _FramePainter(AppColors.accent),
                    ),
                  ),
                ),
              ),
              Transform.rotate(
                angle: (1 - spin) * -0.6,
                child: Transform.scale(scale: land + pulse, child: plate),
              ),
              if (scanOpacity > 0)
                Positioned(
                  top:
                      (_size - _frame) / 2 +
                      12 +
                      scan * (_frame - 24) -
                      _ScanLine.trail,
                  child: Opacity(
                    opacity: scanOpacity,
                    child: const _ScanLine(width: _frame - 28),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Plate extends StatelessWidget {
  const _Plate({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(9),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x4D060F33),
            blurRadius: 32,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Center(
          child: Image.asset(
            'assets/images/zood_mark.png',
            width: size * 0.56,
            height: size * 0.56,
          ),
        ),
      ),
    );
  }
}

class _ScanLine extends StatelessWidget {
  const _ScanLine({required this.width});

  static const double trail = 40;

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          Container(
            height: trail,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.accent.withValues(alpha: 0),
                  AppColors.accent.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(2),
              boxShadow: AppColors.glow(AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  _RipplePainter(this.t, {required this.innerRadius});

  /// Two waves while the plate lands, then a light-blue "scanned" ping.
  static const List<(double, double, Color)> _waves = [
    (0.14, 0.58, Colors.white),
    (0.24, 0.68, Colors.white),
    (0.64, 1.0, Color(0xFF9DB8FF)),
  ];

  final double t;
  final double innerRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outer = size.shortestSide / 2;
    final paint = Paint()..style = PaintingStyle.stroke;
    for (final (begin, end, color) in _waves) {
      final p = _interval(t, begin, end);
      if (p <= 0 || p >= 1) continue;
      paint
        ..color = color.withValues(alpha: 0.45 * (1 - p))
        ..strokeWidth = lerpDouble(3, 1, p)!;
      final radius = lerpDouble(
        innerRadius,
        outer,
        Curves.easeOutCubic.transform(p),
      )!;
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_RipplePainter old) =>
      old.t != t || old.innerRadius != innerRadius;
}

/// Four rounded corner brackets, like a camera's QR viewfinder.
class _FramePainter extends CustomPainter {
  const _FramePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const arm = 32.0;
    const r = Radius.circular(14);
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(0, arm)
      ..lineTo(0, r.y)
      ..arcToPoint(Offset(r.x, 0), radius: r)
      ..lineTo(arm, 0)
      ..moveTo(w - arm, 0)
      ..lineTo(w - r.x, 0)
      ..arcToPoint(Offset(w, r.y), radius: r)
      ..lineTo(w, arm)
      ..moveTo(w, h - arm)
      ..lineTo(w, h - r.y)
      ..arcToPoint(Offset(w - r.x, h), radius: r)
      ..lineTo(w - arm, h)
      ..moveTo(arm, h)
      ..lineTo(r.x, h)
      ..arcToPoint(Offset(0, h - r.y), radius: r)
      ..lineTo(0, h - arm);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_FramePainter old) => old.color != color;
}

class _Journey extends StatelessWidget {
  const _Journey({required this.animation});

  static const double _start = 0.66;
  static const double _stagger = 0.08;

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final steps = [
      (Icons.qr_code_scanner_rounded, l10n.splashStepScan),
      (Icons.restaurant_menu_rounded, l10n.splashStepOrder),
      (Icons.credit_card_rounded, l10n.splashStepPay),
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0)
            _Connector(
              animation: animation,
              begin: _start + _stagger * (i - 1) + 0.04,
              end: _start + _stagger * i + 0.02,
            ),
          _JourneyStep(
            animation: animation,
            begin: _start + _stagger * i,
            icon: steps[i].$1,
            label: steps[i].$2,
          ),
        ],
      ],
    );
  }
}

class _JourneyStep extends StatelessWidget {
  const _JourneyStep({
    required this.animation,
    required this.begin,
    required this.icon,
    required this.label,
  });

  final Animation<double> animation;
  final double begin;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final pop = animation.drive(
      CurveTween(
        curve: Interval(begin, begin + 0.14, curve: Curves.easeOutBack),
      ),
    );
    final fade = animation.drive(
      CurveTween(curve: Interval(begin, begin + 0.08)),
    );
    return SizedBox(
      width: 68,
      child: FadeTransition(
        opacity: fade,
        child: Column(
          children: [
            ScaleTransition(
              scale: pop,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({
    required this.animation,
    required this.begin,
    required this.end,
  });

  final Animation<double> animation;
  final double begin;
  final double end;

  @override
  Widget build(BuildContext context) {
    final fill = animation.drive(
      CurveTween(curve: Interval(begin, end, curve: Curves.easeInOut)),
    );
    final fade = animation.drive(
      CurveTween(curve: Interval(begin - 0.04, begin)),
    );
    final track = Container(
      width: 28,
      height: 2,
      margin: const EdgeInsets.only(top: 22),
      alignment: AlignmentDirectional.centerStart,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(1),
      ),
      child: AnimatedBuilder(
        animation: fill,
        builder: (context, _) => FractionallySizedBox(
          widthFactor: fill.value,
          heightFactor: 1,
          child: const DecoratedBox(
            decoration: BoxDecoration(color: AppColors.accent),
          ),
        ),
      ),
    );
    return FadeTransition(opacity: fade, child: track);
  }
}
