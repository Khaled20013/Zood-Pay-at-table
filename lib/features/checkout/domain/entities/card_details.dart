/// Card entered on the checkout screen. Lives only in memory for the single
/// `POST /orders` call: never persisted, logged or put into state that
/// outlives the form.
class CardDetails {
  const CardDetails({
    required this.holderName,
    required this.number,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvc,
  });

  /// Normalises raw input: digits-only number, `"08"` month, `"2028"` year.
  factory CardDetails.fromInput({
    required String holderName,
    required String number,
    required String expiry,
    required String cvc,
  }) {
    final (month, year) = parseExpiry(expiry) ?? ('', '');
    return CardDetails(
      holderName: holderName.trim(),
      number: digitsOnly(number),
      expiryMonth: month,
      expiryYear: year,
      cvc: digitsOnly(cvc),
    );
  }

  final String holderName;
  final String number;
  final String expiryMonth;
  final String expiryYear;
  final String cvc;

  String get last4 =>
      number.length >= 4 ? number.substring(number.length - 4) : number;

  static String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  /// `"08/28"` or `"08/2028"` → `("08", "2028")`.
  static (String, String)? parseExpiry(String value) {
    final match = RegExp(
      r'^\s*(\d{1,2})\s*/\s*(\d{2}|\d{4})\s*$',
    ).firstMatch(value);
    if (match == null) return null;
    final month = int.parse(match.group(1)!);
    if (month < 1 || month > 12) return null;
    final rawYear = match.group(2)!;
    final year = rawYear.length == 2 ? '20$rawYear' : rawYear;
    return (month.toString().padLeft(2, '0'), year);
  }

  static bool isValidNumber(String value) {
    final digits = digitsOnly(value);
    if (digits.length < 12 || digits.length > 19) return false;
    var sum = 0;
    for (var i = 0; i < digits.length; i++) {
      var d = int.parse(digits[digits.length - 1 - i]);
      if (i.isOdd) {
        d *= 2;
        if (d > 9) d -= 9;
      }
      sum += d;
    }
    return sum % 10 == 0;
  }

  /// Valid format and not in the past (the card works through its month).
  static bool isValidExpiry(String value, {DateTime? now}) {
    final parsed = parseExpiry(value);
    if (parsed == null) return false;
    final today = now ?? DateTime.now();
    final month = int.parse(parsed.$1);
    final year = int.parse(parsed.$2);
    return year > today.year || (year == today.year && month >= today.month);
  }

  static bool isValidCvc(String value) =>
      RegExp(r'^\d{3,4}$').hasMatch(value.trim());

  @override
  String toString() => 'CardDetails(••••$last4)';
}
