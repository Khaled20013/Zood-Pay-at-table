import 'package:intl/intl.dart';

abstract final class CurrencyFormatter {
  static final NumberFormat _amount = NumberFormat('#,##0.00', 'en_US');

  static const Map<String, String> _arabicSymbols = {'SAR': 'ر.س'};

  static bool get _isArabic =>
      (Intl.defaultLocale ?? Intl.getCurrentLocale()).startsWith('ar');

  /// Formats [amount] as `SAR 18.00`, or `18.00 ر.س` when the app is in
  /// Arabic (Western digits, as on Saudi receipts).
  static String format(num amount, {String currency = 'SAR'}) {
    final value = _amount.format(amount);
    if (_isArabic) return '$value\u00A0${_arabicSymbols[currency] ?? currency}';
    return '$currency\u00A0$value';
  }

  /// Formats a modifier delta: `+ SAR 2.00`, or `Free` / `مجانًا` for zero.
  static String formatDelta(num amount, {String currency = 'SAR'}) {
    if (amount == 0) return _isArabic ? 'مجانًا' : 'Free';
    final sign = amount > 0 ? '+' : '−';
    return '$sign ${format(amount.abs(), currency: currency)}';
  }

  /// Avoids binary floating-point drift (e.g. 0.1 + 0.2) on money values.
  static double roundMoney(num amount) => (amount * 100).roundToDouble() / 100;
}
