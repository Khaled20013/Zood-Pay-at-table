import 'package:flutter/material.dart';

import 'package:zood_pay_at_table/Helper/CurrencyFormatter.dart';

/// A price that counts up or down to its new value instead of jumping.
class AnimatedAmount extends StatelessWidget {
  const AnimatedAmount({
    super.key,
    required this.amount,
    required this.currency,
    this.style,
  });

  final double amount;
  final String currency;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final text = CurrencyFormatter.format(amount, currency: currency);
    if (MediaQuery.disableAnimationsOf(context)) {
      return Text(text, style: style);
    }
    return Semantics(
      label: text,
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: amount),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) => Text(
          CurrencyFormatter.format(value, currency: currency),
          style: (style ?? const TextStyle()).copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
