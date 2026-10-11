import '../../../cart/domain/entities/cart_item.dart';
import '../../../table_session/domain/entities/table_session.dart';
import '../entities/card_details.dart';
import '../entities/order_receipt.dart';

abstract interface class OrderRepository {
  /// Charges [card] and creates the order. Retrying with the same
  /// [clientOrderId] never charges twice.
  Future<OrderReceipt> placeOrder({
    required TableSession session,
    required List<CartItem> items,
    required CardDetails card,
    required String clientOrderId,
    String customerNotes = '',
  });
}
