import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:zood_pay_at_table/Helper/L10n.dart';
import 'package:zood_pay_at_table/Styles/AppColors.dart';
import 'package:zood_pay_at_table/Widgets/StatusView.dart';

import '../Controller/QrScanController.dart';

/// `/scan`: reads a table QR with the camera and opens that table's menu.
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});
  static const String routeName = "/QrScanScreen";
  static const String path = "/scan";

  static const double windowSize = 250;

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  late QrScanController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QrScanController(refresh);
    _controller.onInit();
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: _controller.scanner,
              onDetect: _controller.onDetect,
              errorBuilder: (context, error) =>
                  _CameraError(error: error, onEnterLink: _controller.enterLink),
              placeholderBuilder: (context) => const ColoredBox(
                color: Colors.black,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _ViewfinderPainter(QrScanScreen.windowSize),
                ),
              ),
              overlayBuilder: (context, constraints) => const IgnorePointer(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _ViewfinderPainter(QrScanScreen.windowSize),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      _RoundButton(
                        icon: Icons.close_rounded,
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).closeButtonTooltip,
                        onPressed: _controller.close,
                      ),
                      const Spacer(),
                      ValueListenableBuilder<MobileScannerState>(
                        valueListenable: _controller.scanner,
                        builder: (context, state, _) {
                          if (!state.isRunning ||
                              state.torchState == TorchState.unavailable) {
                            return const SizedBox.shrink();
                          }
                          return _RoundButton(
                            icon: state.torchState == TorchState.on
                                ? Icons.flash_on_rounded
                                : Icons.flash_off_rounded,
                            tooltip: l10n.scanTorch,
                            onPressed: _controller.scanner.toggleTorch,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _controller.showInvalid ? l10n.scanInvalidCode : l10n.scanHint,
                          key: ValueKey(_controller.showInvalid),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: _controller.showInvalid
                                    ? const Color(0xFFFFB4A9)
                                    : Colors.white,
                              ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _controller.enterLink,
                        icon: const Icon(Icons.link_rounded),
                        label: Text(l10n.scanEnterLink),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black.withValues(alpha: 0.45),
        fixedSize: const Size.square(44),
      ),
    );
  }
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.error, required this.onEnterLink});

  final MobileScannerException error;
  final VoidCallback onEnterLink;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;
    return ColoredBox(
      color: AppColors.background,
      child: StatusView(
        isError: true,
        icon: Icons.no_photography_outlined,
        title: denied
            ? l10n.scanCameraDeniedTitle
            : l10n.scanCameraUnavailableTitle,
        message: denied
            ? l10n.scanCameraDeniedMessage
            : l10n.scanCameraUnavailableMessage,
        actionLabel: l10n.scanEnterLink,
        onAction: onEnterLink,
      ),
    );
  }
}

/// Dims the preview outside a centered square and draws corner brackets.
class _ViewfinderPainter extends CustomPainter {
  const _ViewfinderPainter(this.window);

  final double window;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: window,
      height: window,
    );
    final hole = RRect.fromRectAndRadius(rect, const Radius.circular(24));
    canvas.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(Offset.zero & size)
        ..addRRect(hole),
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );

    const arm = 34.0;
    const radius = 24.0;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    for (final (corner, dx, dy) in [
      (rect.topLeft, 1.0, 1.0),
      (rect.topRight, -1.0, 1.0),
      (rect.bottomLeft, 1.0, -1.0),
      (rect.bottomRight, -1.0, -1.0),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(corner.dx, corner.dy + dy * arm)
          ..lineTo(corner.dx, corner.dy + dy * radius)
          ..arcToPoint(
            Offset(corner.dx + dx * radius, corner.dy),
            radius: const Radius.circular(radius),
            clockwise: dx * dy > 0,
          )
          ..lineTo(corner.dx + dx * arm, corner.dy),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ViewfinderPainter old) => old.window != window;
}
