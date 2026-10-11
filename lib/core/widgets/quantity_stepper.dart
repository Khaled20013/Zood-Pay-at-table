import 'package:flutter/material.dart';

import '../localization/l10n.dart';
import '../theme/app_colors.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.compact = false,
    this.min = 1,
    this.max = 99,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool compact;

  /// When [quantity] is at [min] the minus button turns into a trash icon
  /// (cart lines) unless [min] is 1 and removal is not allowed (dialogs).
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 32.0 : 40.0;
    final showTrash = min == 0 && quantity == 1;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(size),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            size: size,
            icon: showTrash
                ? Icons.delete_outline_rounded
                : Icons.remove_rounded,
            tooltip: showTrash
                ? context.l10n.removeItem
                : context.l10n.decreaseQuantity,
            onPressed: quantity > min ? onDecrement : null,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: compact ? 26 : 34),
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: compact ? 14 : 16),
            ),
          ),
          _StepButton(
            size: size,
            icon: Icons.add_rounded,
            tooltip: context.l10n.increaseQuantity,
            onPressed: quantity < max ? onIncrement : null,
            filled: true,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.size,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.filled = false,
  });

  final double size;
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: filled
            ? (enabled ? AppColors.primary : AppColors.border)
            : AppColors.surface,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: size - 6,
            child: Icon(
              icon,
              size: size * 0.5,
              color: filled
                  ? Colors.white
                  : (enabled ? AppColors.ink : AppColors.inkSubtle),
            ),
          ),
        ),
      ),
    );
  }
}
