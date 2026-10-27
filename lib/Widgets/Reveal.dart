import 'package:flutter/widgets.dart';

/// Fades and slides [child] in while [animation] runs through
/// [begin]..[end], so several pieces can share one staggered controller.
class Reveal extends StatelessWidget {
  const Reveal({
    super.key,
    required this.animation,
    required this.begin,
    required this.end,
    required this.child,
    this.offset = const Offset(0, 0.25),
    this.curve = Curves.easeOutCubic,
  });

  final Animation<double> animation;
  final double begin;
  final double end;

  /// Starting offset as a fraction of the child's size; `dx` is mirrored in
  /// right-to-left layouts.
  final Offset offset;
  final Curve curve;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final progress = animation.drive(
      CurveTween(curve: Interval(begin, end, curve: curve)),
    );
    return FadeTransition(
      opacity: progress,
      child: SlideTransition(
        textDirection: Directionality.of(context),
        position: progress.drive(Tween(begin: offset, end: Offset.zero)),
        child: child,
      ),
    );
  }
}
