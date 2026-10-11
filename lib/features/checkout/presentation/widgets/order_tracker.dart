import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/reveal.dart';
import '../../domain/entities/order_receipt.dart';

enum _StepState { done, active, pending }

/// Paid → preparing → served timeline. [entrance] staggers the steps in;
/// [pulse] (repeating 0 → 1) breathes a halo around the active step.
class OrderTracker extends StatelessWidget {
  const OrderTracker({
    super.key,
    required this.receipt,
    required this.entrance,
    required this.pulse,
  });

  final OrderReceipt receipt;
  final Animation<double> entrance;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final steps = [
      (
        _StepState.done,
        Icons.check_rounded,
        l10n.orderStepPaidTitle,
        [
          CurrencyFormatter.format(receipt.total, currency: receipt.currency),
          if (receipt.cardLast4.isNotEmpty)
            l10n.cardEndingIn(receipt.cardLast4),
        ].join(' · '),
      ),
      (
        _StepState.active,
        Icons.soup_kitchen_rounded,
        l10n.orderStepKitchenTitle,
        l10n.orderStepKitchenSubtitle,
      ),
      (
        _StepState.pending,
        Icons.room_service_rounded,
        l10n.orderStepServeTitle,
        l10n.orderStepServeSubtitle(receipt.tableName),
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Reveal(
            animation: entrance,
            begin: 0.62,
            end: 0.82,
            child: Text(
              l10n.orderTrackerTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < steps.length; i++)
            Reveal(
              animation: entrance,
              begin: 0.66 + i * 0.08,
              end: 0.86 + i * 0.05,
              offset: const Offset(0.08, 0),
              child: _TrackerStep(
                state: steps[i].$1,
                icon: steps[i].$2,
                title: steps[i].$3,
                subtitle: steps[i].$4,
                pulse: pulse,
                isLast: i == steps.length - 1,
              ),
            ),
        ],
      ),
    );
  }
}

class _TrackerStep extends StatelessWidget {
  const _TrackerStep({
    required this.state,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.pulse,
    required this.isLast,
  });

  final _StepState state;
  final IconData icon;
  final String title;
  final String subtitle;
  final Animation<double> pulse;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (fill, iconColor) = switch (state) {
      _StepState.done => (AppColors.success, Colors.white),
      _StepState.active => (AppColors.accentSoft, AppColors.accentDeep),
      _StepState.pending => (AppColors.surfaceMuted, AppColors.inkSubtle),
    };
    final lineColor = state == _StepState.done
        ? AppColors.success
        : AppColors.border;

    Widget indicator = Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
      child: Icon(icon, size: 19, color: iconColor),
    );
    if (state == _StepState.active) {
      indicator = Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: pulse,
            builder: (context, _) => Transform.scale(
              scale: 1 + pulse.value * 0.7,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withValues(
                    alpha: 0.35 * (1 - pulse.value),
                  ),
                ),
              ),
            ),
          ),
          indicator,
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              indicator,
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: lineColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      color: state == _StepState.pending
                          ? AppColors.inkMuted
                          : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
