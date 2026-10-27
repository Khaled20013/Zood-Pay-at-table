/// Public Pay at Table endpoints: no login, no `Authorization` header.
/// Relative to `config.url`.
abstract final class ApiEndpoints {
  static String qr(String qrId) => 'public/pay-at-table/qr/$qrId';
  static const String categories = 'public/pay-at-table/categories';
  static const String products = 'public/pay-at-table/products';
  static const String modifiers = 'public/pay-at-table/modifiers';
  static const String orders = 'public/pay-at-table/orders';

  static const Duration timeout = Duration(seconds: 30);
}
