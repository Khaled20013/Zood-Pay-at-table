import 'package:equatable/equatable.dart';

/// What the success screen shows, taken from the `POST /orders` response.
class OrderReceipt extends Equatable {
  const OrderReceipt({
    required this.orderId,
    required this.orderNumber,
    required this.reference,
    required this.subtotal,
    required this.taxes,
    required this.total,
    required this.currency,
    required this.branchName,
    required this.tableName,
    required this.paidAt,
    this.cardLast4 = '',
  });

  final String orderId;

  /// Short number the guest tells the staff, shown as `#23`.
  final String orderNumber;

  /// e.g. `#R000123`.
  final String reference;
  final double subtotal;
  final double taxes;
  final double total;
  final String currency;
  final String branchName;
  final String tableName;
  final DateTime paidAt;
  final String cardLast4;

  @override
  List<Object?> get props => [
    orderId,
    orderNumber,
    reference,
    subtotal,
    taxes,
    total,
    currency,
    branchName,
    tableName,
    paidAt,
    cardLast4,
  ];
}
