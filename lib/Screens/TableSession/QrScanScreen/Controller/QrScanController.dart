import 'dart:async';

import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../AppRoutes/GoRouterApp.dart';
import '../../../../AppRoutes/OnboardingRoutes.dart';
import '../../../Onboarding/WelcomeScreen/Controller/WelcomeController.dart';

class QrScanController {
  final Function() refresh;

  QrScanController(this.refresh);

  final MobileScannerController scanner = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );

  bool _opened = false;

  /// Shown for a moment after reading a QR that isn't a table link.
  bool showInvalid = false;
  Timer? _invalidTimer;

  void update() {
    refresh();
  }

  Future<void> onInit() async {
    update();
  }

  void dispose() {
    _invalidTimer?.cancel();
    scanner.dispose();
  }

  void onDetect(BarcodeCapture capture) {
    if (_opened) return;
    for (final barcode in capture.barcodes) {
      final location = WelcomeController.locationForInput(
        barcode.rawValue ?? '',
      );
      if (location != null) {
        _opened = true;
        HapticFeedback.mediumImpact();
        GoRouterApp.openLocation(location);
        return;
      }
    }
    if (capture.barcodes.isEmpty) return;
    _invalidTimer?.cancel();
    showInvalid = true;
    update();
    _invalidTimer = Timer(const Duration(milliseconds: 2500), () {
      showInvalid = false;
      update();
    });
  }

  void close() {
    if (GoRouterApp.canPop()) {
      GoRouterApp.pop();
    } else {
      OnboardingRoutes.openWelcomeScreen(replacement: true);
    }
  }

  void enterLink() => OnboardingRoutes.openWelcomeScreen(replacement: true);
}
