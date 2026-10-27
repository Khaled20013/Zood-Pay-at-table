import 'package:equatable/equatable.dart';

import '../../Helper/LocalizedText.dart';
import '../../Helper/path_selector_base.dart';

/// What the success screen shows, taken from the `POST /orders` response.
class OrderReceiptModel extends Equatable {
  const OrderReceiptModel({
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

  /// `data` of the `POST /orders` response. The fallbacks fill in what the
  /// server leaves out.
  factory OrderReceiptModel.fromJson(
    Map<String, dynamic>? json, {
    required String languageCode,
    required String currency,
    required String fallbackBranchName,
    required String fallbackTableName,
    String cardLast4 = '',
  }) {
    final paidAt = DateTime.tryParse(jsonString(json?.select('paid_at')));
    return OrderReceiptModel(
      orderId: jsonString(json?.select('id')),
      orderNumber: jsonString(json?.select('number')),
      reference: jsonString(json?.select('reference')),
      subtotal: jsonDouble(json?.select('subtotal_price')),
      taxes: jsonDouble(json?.select('total_taxes')),
      total: jsonDouble(json?.select('total_price')),
      currency: currency,
      branchName:
          localizedNameAt(json, 'branch', languageCode) ?? fallbackBranchName,
      tableName:
          localizedNameAt(json, 'table', languageCode) ?? fallbackTableName,
      paidAt: (paidAt ?? DateTime.now()).toLocal(),
      cardLast4: cardLast4,
    );
  }

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
