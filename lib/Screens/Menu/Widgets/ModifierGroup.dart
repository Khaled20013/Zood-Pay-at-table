import 'package:flutter/material.dart';

import 'package:zood_pay_at_table/Helper/L10n.dart';
import 'package:zood_pay_at_table/Styles/AppColors.dart';
import 'package:zood_pay_at_table/Helper/CurrencyFormatter.dart';
import 'package:zood_pay_at_table/Widgets/QuantityStepper.dart';
import 'package:zood_pay_at_table/Models/Menu/ModifierSelectionModel.dart';
import 'package:zood_pay_at_table/Models/Menu/ProductModel.dart';

/// One modifier of the product sheet. Single choice → radios, unique
/// options → checkboxes, otherwise a quantity stepper per option.
class ModifierGroup extends StatelessWidget {
  const ModifierGroup({
    super.key,
    required this.modifier,
    required this.selection,
    required this.currency,
    required this.onChanged,
    this.showError = false,
  });

  final ProductModifierModel modifier;
  final ModifierSelection selection;
  final String currency;
  final ValueChanged<ModifierSelection> onChanged;

  /// Highlights a required modifier the guest tried to skip.
  final bool showError;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = S.of(context);
    final missing = showError && !selection.isSatisfied(modifier);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(modifier.name, style: textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        _rulesText(l10n),
                        style: textTheme.bodySmall?.copyWith(
                          color: missing ? AppColors.error : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _RequirementPill(
                  required: modifier.isRequired,
                  satisfied: selection.isSatisfied(modifier),
                  error: missing,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          if (modifier.isSingleChoice)
            RadioGroup<String>(
              groupValue: _selectedSingleId,
              onChanged: (id) {
                final option = id == null
                    ? modifier.options.firstWhere(
                        (o) => selection.quantityOf(modifier, o) > 0,
                      )
                    : modifier.optionById(id)!;
                onChanged(selection.toggle(modifier, option));
              },
              child: Column(
                children: [
                  for (final option in modifier.options)
                    RadioListTile<String>(
                      value: option.id,
                      toggleable: !modifier.isRequired,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      title: Text(option.name, style: textTheme.bodyLarge),
                      secondary: _PriceLabel(
                        price: option.price,
                        currency: currency,
                      ),
                    ),
                ],
              ),
            )
          else if (modifier.uniqueOptions)
            for (final option in modifier.options)
              CheckboxListTile(
                value: selection.quantityOf(modifier, option) > 0,
                enabled:
                    selection.quantityOf(modifier, option) > 0 ||
                    selection.canIncrease(modifier, option),
                onChanged: (_) => onChanged(selection.toggle(modifier, option)),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                title: Text(option.name, style: textTheme.bodyLarge),
                secondary: _PriceLabel(price: option.price, currency: currency),
              )
          else
            for (final option in modifier.options)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(option.name, style: textTheme.bodyLarge),
                          if (option.price > 0)
                            _PriceLabel(
                              price: option.price,
                              currency: currency,
                            ),
                        ],
                      ),
                    ),
                    QuantityStepper(
                      compact: true,
                      min: 0,
                      max: selection.canIncrease(modifier, option)
                          ? 99
                          : selection.quantityOf(modifier, option),
                      quantity: selection.quantityOf(modifier, option),
                      onIncrement: () =>
                          onChanged(selection.increment(modifier, option)),
                      onDecrement: () =>
                          onChanged(selection.decrement(modifier, option)),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  String? get _selectedSingleId {
    for (final option in modifier.options) {
      if (selection.quantityOf(modifier, option) > 0) return option.id;
    }
    return null;
  }

  String _rulesText(S l10n) {
    final min = modifier.minimumOptions;
    final max = modifier.maximumOptions;
    final rule = switch ((min, max)) {
      (_, 1) => l10n.modifierChooseOne,
      (0, 0) => l10n.modifierChooseAny,
      (0, _) => l10n.modifierChooseUpTo(max),
      (_, 0) => l10n.modifierChooseAtLeast(min),
      _ when min == max => l10n.modifierChooseExactly(min),
      _ => l10n.modifierChooseBetween(min, max),
    };
    if (modifier.freeOptions <= 0) return rule;
    return '$rule · ${l10n.modifierFreeUnits(modifier.freeOptions)}';
  }
}

class _RequirementPill extends StatelessWidget {
  const _RequirementPill({
    required this.required,
    required this.satisfied,
    required this.error,
  });

  final bool required;
  final bool satisfied;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final (bg, fg, label) = switch ((required, satisfied, error)) {
      (false, _, _) => (
        AppColors.surfaceMuted,
        AppColors.inkMuted,
        l10n.optional,
      ),
      (true, true, _) => (AppColors.primarySoft, AppColors.primary, l10n.done),
      (true, false, true) => (
        AppColors.errorSoft,
        AppColors.error,
        l10n.required,
      ),
      (true, false, false) => (
        AppColors.accentSoft,
        AppColors.accentDeep,
        l10n.required,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (required && satisfied) ...[
            Icon(Icons.check_rounded, size: 14, color: fg),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// "+ SAR 5.00"; nothing for free options.
class _PriceLabel extends StatelessWidget {
  const _PriceLabel({required this.price, required this.currency});

  final double price;
  final String currency;

  @override
  Widget build(BuildContext context) {
    if (price <= 0) return const SizedBox.shrink();
    return Text(
      CurrencyFormatter.formatDelta(price, currency: currency),
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
    );
  }
}
