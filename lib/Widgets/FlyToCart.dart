import 'package:flutter/material.dart';

import 'package:zood_pay_at_table/Styles/AppColors.dart';

/// Flies a small bubble from [from] to the [target] widget along an arc,
/// confirming a quick add without a toast. No-op with reduced motion.
abstract final class FlyToCart {
  static void run(
    BuildContext context, {
    required Rect from,
    required GlobalKey target,
    required IconData icon,
  }) {
    if (MediaQuery.disableAnimationsOf(context)) return;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    final overlayBox = overlay?.context.findRenderObject() as RenderBox?;
    if (overlay == null || overlayBox == null) return;

    final start = overlayBox.globalToLocal(from.center);
    final fallback = Offset(
      overlayBox.size.width / 2,
      overlayBox.size.height - 48,
    );

    /// Read every frame: the cart bar may still be sliding in.
    Offset end() {
      final box = target.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached || !box.hasSize) return fallback;
      return overlayBox.globalToLocal(
        box.localToGlobal(box.size.center(Offset.zero)),
      );
    }

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _FlyingBubble(
        start: start,
        end: end,
        icon: icon,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class _FlyingBubble extends StatefulWidget {
  const _FlyingBubble({
    required this.start,
    required this.end,
    required this.icon,
    required this.onDone,
  });

  final Offset start;
  final Offset Function() end;
  final IconData icon;
  final VoidCallback onDone;

  @override
  State<_FlyingBubble> createState() => _FlyingBubbleState();
}

class _FlyingBubbleState extends State<_FlyingBubble>
    with SingleTickerProviderStateMixin {
  static const double _size = 34;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  )..forward().whenComplete(widget.onDone);

  late final Animation<double> _t = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCubic,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Quadratic Bézier whose control point sits above both ends.
  Offset _pointAt(double t) {
    final a = widget.start;
    final b = widget.end();
    final control = Offset(
      (a.dx + b.dx) / 2,
      (a.dy < b.dy ? a.dy : b.dy) - 120,
    );
    final u = 1 - t;
    return a * (u * u) + control * (2 * u * t) + b * (t * t);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _t,
          builder: (context, child) {
            final t = _t.value;
            final p = _pointAt(t);
            final scale = t < 0.15
                ? 0.6 + t / 0.15 * 0.5
                : 1.1 - (t - 0.15) * 0.7;
            return Stack(
              children: [
                Positioned(
                  left: p.dx - _size / 2,
                  top: p.dy - _size / 2,
                  child: Opacity(
                    opacity: t > 0.9 ? (1 - t) / 0.1 : 1,
                    child: Transform.scale(scale: scale, child: child),
                  ),
                ),
              ],
            );
          },
          child: Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              gradient: AppColors.warmGradient,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: AppColors.glow(AppColors.accentDeep),
            ),
            child: Icon(widget.icon, size: 17, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
