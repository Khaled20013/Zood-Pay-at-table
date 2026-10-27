import 'package:flutter/material.dart';

import 'package:zood_pay_at_table/Helper/L10n.dart';
import 'package:zood_pay_at_table/AppRoutes/TableSessionRoutes.dart';
import 'package:zood_pay_at_table/Styles/AppColors.dart';

/// Opens the camera to switch to another table.
class ScanTableButton extends StatelessWidget {
  const ScanTableButton({super.key, this.size = 42, this.onDark = false});

  final double size;

  /// Glass style for the dark menu hero.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: S.of(context).scanAnotherTable,
      onPressed: () => TableSessionRoutes.openQrScanScreen(),
      icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
      style: IconButton.styleFrom(
        fixedSize: Size.square(size),
        minimumSize: Size.square(size),
        foregroundColor: onDark ? Colors.white : AppColors.primary,
        backgroundColor: onDark
            ? Colors.white.withValues(alpha: 0.16)
            : AppColors.surface,
        side: onDark
            ? BorderSide(color: Colors.white.withValues(alpha: 0.22))
            : const BorderSide(color: AppColors.border),
      ),
    );
  }
}
