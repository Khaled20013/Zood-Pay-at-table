/// Public Pay at Table endpoints: no login, no `Authorization` header.
abstract final class ApiEndpoints {
  static const String qr = 'public/pay-at-table/qr/{qrId}';
  static const String categories = 'public/pay-at-table/categories';
  static const String products = 'public/pay-at-table/products';
  static const String modifiers = 'public/pay-at-table/modifiers';
  static const String orders = 'public/pay-at-table/orders';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
