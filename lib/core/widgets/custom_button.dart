import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

enum CustomButtonVariant { primary, secondary, ghost }

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.trailing,
    this.variant = CustomButtonVariant.primary,
    this.isLoading = false,
    this.expand = true,
    this.height = 54,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Rendered at the far end, e.g. a price on "Add to order".
  final Widget? trailing;
  final CustomButtonVariant variant;
  final bool isLoading;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (variant) {
      CustomButtonVariant.primary => (
        AppColors.primary,
        Colors.white,
        Colors.transparent,
      ),
      CustomButtonVariant.secondary => (
        AppColors.surface,
        AppColors.ink,
        AppColors.border,
      ),
      CustomButtonVariant.ghost => (
        Colors.transparent,
        AppColors.primary,
        Colors.transparent,
      ),
    };
    final enabled = onPressed != null && !isLoading;

    final content = isLoading
        ? SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
          )
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: trailing == null
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(label, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 12), trailing!],
            ],
          );

    final isGradient = variant == CustomButtonVariant.primary;
    final radius = BorderRadius.circular(AppTheme.radiusMd);

    final button = TextButton(
      onPressed: enabled ? onPressed : null,
      style: TextButton.styleFrom(
        backgroundColor: isGradient
            ? Colors.transparent
            : (enabled ? bg : bg.withValues(alpha: 0.45)),
        foregroundColor: fg,
        disabledForegroundColor: fg.withValues(alpha: 0.8),
        minimumSize: Size(expand ? double.infinity : 0, height),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        textStyle: Theme.of(context).textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: border),
        ),
      ),
      child: content,
    );

    return Semantics(
      button: true,
      enabled: enabled,
      child: isGradient
          ? AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: enabled || isLoading ? 1 : 0.45,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.ctaGradient,
                  borderRadius: radius,
                  boxShadow: enabled ? AppColors.glow(AppColors.primary) : null,
                ),
                child: button,
              ),
            )
          : button,
    );
  }
}
