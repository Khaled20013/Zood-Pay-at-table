import '../Cart/CartItemModel.dart';
import 'CardDetailsModel.dart';

/// `POST /public/pay-at-table/orders` body. No prices: the server prices
/// and charges the order.
class OrderRequestModel {
  const OrderRequestModel({
    required this.qrId,
    required this.clientOrderId,
    required this.customerNotes,
    required this.products,
    required this.card,
    this.patKdsMessage,
  });

  final String qrId;
  final String clientOrderId;
  final String customerNotes;
  final List<OrderProductModel> products;
  final OrderCardModel card;

  /// Multipeer kitchen wire from `PatKdsMessage` (Self Order parity with
  /// `kiosk_kds_message`). Backend relays it on Pusher `record.pat_kds_message`.
  final String? patKdsMessage;

  Map<String, dynamic> toJson() => {
    'qr_id': qrId,
    'client_order_id': clientOrderId,
    'customer_notes': customerNotes,
    'products': [for (final p in products) p.toJson()],
    'card': card.toJson(),
    'pat_kds_message': ?patKdsMessage,
  };
}

class OrderProductModel {
  const OrderProductModel({
    required this.productId,
    required this.quantity,
    required this.notes,
    required this.options,
  });

  factory OrderProductModel.fromCartItem(CartItemModel item) =>
      OrderProductModel(
        productId: item.product.id,
        quantity: item.quantity,
        notes: item.notes,
        options: [
          for (final o in item.selectedOptions)
            OrderOptionModel(
              modifierOptionId: o.option.id,
              quantity: o.quantity,
            ),
        ],
      );

  final String productId;
  final int quantity;
  final String notes;
  final List<OrderOptionModel> options;

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'quantity': quantity,
    'notes': notes,
    'options': [for (final o in options) o.toJson()],
  };
}

/// [quantity] is per one product unit.
class OrderOptionModel {
  const OrderOptionModel({
    required this.modifierOptionId,
    required this.quantity,
  });

  final String modifierOptionId;
  final int quantity;

  Map<String, dynamic> toJson() => {
    'modifier_option_id': modifierOptionId,
    'quantity': quantity,
  };
}

class OrderCardModel {
  const OrderCardModel({
    required this.holderName,
    required this.number,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvc,
  });

  factory OrderCardModel.fromCard(CardDetailsModel card) => OrderCardModel(
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

  Map<String, dynamic> toJson() => {
    'holder_name': holderName,
    'number': number,
    'expiry_month': expiryMonth,
    'expiry_year': expiryYear,
    'cvc': cvc,
  };

  @override
  String toString() => 'OrderCardModel(hidden)';
}
