import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/card_brand.dart';
import '../../domain/entities/card_details.dart';
import 'credit_card_preview.dart';

/// Controllers for the card fields. The owning screen disposes them, so
/// card data never outlives the checkout route.
class CardFormControllers {
  final holderName = TextEditingController();
  final number = TextEditingController();
  final expiry = TextEditingController();
  final cvc = TextEditingController();

  /// The preview flips to the card's back while this has focus.
  final cvcFocus = FocusNode();

  CardDetails toCard() => CardDetails.fromInput(
    holderName: holderName.text,
    number: number.text,
    expiry: expiry.text,
    cvc: cvc.text,
  );

  void dispose() {
    for (final c in [holderName, number, expiry, cvc]) {
      c.clear();
      c.dispose();
    }
    cvcFocus.dispose();
  }
}

class CardForm extends StatelessWidget {
  const CardForm({super.key, required this.controllers, required this.enabled});

  final CardFormControllers controllers;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AutofillGroup(
      child: Column(
        children: [
          _field(
            controller: controllers.number,
            label: l10n.cardNumber,
            hint: '0000 0000 0000 0000',
            icon: Icons.credit_card_rounded,
            suffix: ValueListenableBuilder(
              valueListenable: controllers.number,
              builder: (context, value, _) {
                final brand = CardBrand.of(CardDetails.digitsOnly(value.text));
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: brand == CardBrand.unknown
                      ? const SizedBox.shrink()
                      : Padding(
                          key: ValueKey(brand),
                          padding: const EdgeInsetsDirectional.only(end: 12),
                          child: CardBrandMark(
                            brand: brand,
                            height: 18,
                            onLight: true,
                          ),
                        ),
                );
              },
            ),
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.creditCardNumber],
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(19),
              const _CardNumberFormatter(),
            ],
            validator: (v) => CardDetails.isValidNumber(v ?? '')
                ? null
                : l10n.cardNumberInvalid,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _field(
                  controller: controllers.expiry,
                  label: l10n.cardExpiry,
                  hint: 'MM/YY',
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.creditCardExpirationDate],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    const _ExpiryFormatter(),
                  ],
                  validator: (v) => CardDetails.isValidExpiry(v ?? '')
                      ? null
                      : l10n.cardExpiryInvalid,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _field(
                  controller: controllers.cvc,
                  focusNode: controllers.cvcFocus,
                  label: l10n.cardCvc,
                  hint: '123',
                  keyboardType: TextInputType.number,
                  obscure: true,
                  autofillHints: const [AutofillHints.creditCardSecurityCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (v) => CardDetails.isValidCvc(v ?? '')
                      ? null
                      : l10n.cardCvcInvalid,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _field(
            controller: controllers.holderName,
            label: l10n.cardHolderName,
            hint: 'KHALED HUSSIEN',
            icon: Icons.person_outline_rounded,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.characters,
            autofillHints: const [AutofillHints.creditCardName],
            textInputAction: TextInputAction.done,
            inputFormatters: [LengthLimitingTextInputFormatter(100)],
            validator: (v) => (v ?? '').trim().length >= 2
                ? null
                : l10n.cardHolderNameInvalid,
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required FormFieldValidator<String> validator,
    IconData? icon,
    Widget? suffix,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Iterable<String>? autofillHints,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction textInputAction = TextInputAction.next,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      autofillHints: autofillHints,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      obscureText: obscure,
      autocorrect: false,
      enableSuggestions: false,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      // Card numbers, dates and CVCs read left-to-right in Arabic too.
      textDirection: keyboardType == TextInputType.number
          ? TextDirection.ltr
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon == null
            ? null
            : Icon(icon, color: AppColors.inkMuted, size: 20),
        suffixIcon: suffix,
        suffixIconConstraints: const BoxConstraints(minHeight: 24),
      ),
    );
  }
}

/// `4111111111111111` → `4111 1111 1111 1111`.
class _CardNumberFormatter extends TextInputFormatter {
  const _CardNumberFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text;
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// `0828` → `08/28`.
class _ExpiryFormatter extends TextInputFormatter {
  const _ExpiryFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text;
    final text = digits.length > 2
        ? '${digits.substring(0, 2)}/${digits.substring(2)}'
        : digits;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
