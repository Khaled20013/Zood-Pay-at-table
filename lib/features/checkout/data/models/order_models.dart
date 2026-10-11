import 'package:json_annotation/json_annotation.dart';

import '../../../../core/network/localized_name_model.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../domain/entities/card_details.dart';
import '../../domain/entities/order_receipt.dart';

part 'order_models.g.dart';

/// `POST /public/pay-at-table/orders` body. No prices: the server prices
/// and charges the order.
@JsonSerializable(
  fieldRename: FieldRename.snake,
  createFactory: false,
  explicitToJson: true,
)
class OrderRequestModel {
  const OrderRequestModel({
    required this.qrId,
    required this.clientOrderId,
    required this.customerNotes,
    required this.products,
    required this.card,
  });

  final String qrId;
  final String clientOrderId;
  final String customerNotes;
  final List<OrderProductModel> products;
  final CardModel card;

  Map<String, dynamic> toJson() => _$OrderRequestModelToJson(this);
}

@JsonSerializable(
  fieldRename: FieldRename.snake,
  createFactory: false,
  explicitToJson: true,
)
class OrderProductModel {
  const OrderProductModel({
    required this.productId,
    required this.quantity,
    required this.notes,
    required this.options,
  });

  factory OrderProductModel.fromEntity(CartItem item) => OrderProductModel(
    productId: item.product.id,
    quantity: item.quantity,
    notes: item.notes,
    options: [
      for (final o in item.selectedOptions)
        OrderOptionModel(modifierOptionId: o.option.id, quantity: o.quantity),
    ],
  );

  final String productId;
  final int quantity;
  final String notes;
  final List<OrderOptionModel> options;

  Map<String, dynamic> toJson() => _$OrderProductModelToJson(this);
}

/// [quantity] is per one product unit.
@JsonSerializable(fieldRename: FieldRename.snake, createFactory: false)
class OrderOptionModel {
  const OrderOptionModel({
    required this.modifierOptionId,
    required this.quantity,
  });

  final String modifierOptionId;
  final int quantity;

  Map<String, dynamic> toJson() => _$OrderOptionModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, createFactory: false)
class CardModel {
  const CardModel({
    required this.holderName,
    required this.number,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvc,
  });

  factory CardModel.fromEntity(CardDetails card) => CardModel(
    holderName: card.holderName,
    number: card.number,
    expiryMonth: card.expiryMonth,
    expiryYear: card.expiryYear,
    cvc: card.cvc,
  );

  final String holderName;
  final String number;
  final String expiryMonth;
  final String expiryYear;
  final String cvc;

  Map<String, dynamic> toJson() => _$CardModelToJson(this);

  @override
  String toString() => 'CardModel(hidden)';
}

/// `{ "message": "...", "data": { ... } }`
@JsonSerializable(createToJson: false)
class OrderResponse {
  const OrderResponse({required this.data, this.message});

  factory OrderResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderResponseFromJson(json);

  final String? message;
  final OrderModel data;
}

@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class OrderModel {
  const OrderModel({
    required this.id,
    required this.number,
    required this.reference,
    required this.subtotalPrice,
    required this.totalTaxes,
    required this.totalPrice,
    this.branch,
    this.table,
    this.paidAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  @JsonKey(fromJson: jsonString)
  final String id;
  @JsonKey(fromJson: jsonString)
  final String number;
  @JsonKey(defaultValue: '')
  final String reference;
  @JsonKey(defaultValue: 0)
  final double subtotalPrice;
  @JsonKey(defaultValue: 0)
  final double totalTaxes;
  @JsonKey(defaultValue: 0)
  final double totalPrice;
  final LocalizedNameModel? branch;
  final LocalizedNameModel? table;
  final DateTime? paidAt;

  OrderReceipt toEntity({
    required String languageCode,
    required String currency,
    required String fallbackBranchName,
    required String fallbackTableName,
    String cardLast4 = '',
  }) => OrderReceipt(
    orderId: id,
    orderNumber: number,
    reference: reference,
    subtotal: subtotalPrice,
    taxes: totalTaxes,
    total: totalPrice,
    currency: currency,
    branchName: branch?.resolve(languageCode) ?? fallbackBranchName,
    tableName: table?.resolve(languageCode) ?? fallbackTableName,
    paidAt: (paidAt ?? DateTime.now()).toLocal(),
    cardLast4: cardLast4,
  );
}
