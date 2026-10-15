import '../../../../core/error/app_exception.dart';
import '../../../../core/network/demo_data_policy.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../table_session/domain/entities/table_session.dart';
import '../../domain/entities/card_details.dart';
import '../../domain/entities/order_receipt.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/dummy_order_data.dart';
import '../datasources/orders_api.dart';
import '../models/order_models.dart';
import '../pat_kds_message.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({
    required OrdersApi api,
    required DemoDataPolicy policy,
    String Function()? languageCode,
  }) : _api = api,
       _policy = policy,
       _languageCode = languageCode ?? _english;

  final OrdersApi _api;
  final DemoDataPolicy _policy;
  final String Function() _languageCode;
  static String _english() => 'en';

  static const int maxNotesLength = 250;

  @override
  Future<OrderReceipt> placeOrder({
    required TableSession session,
    required List<CartItem> items,
    required CardDetails card,
    required String clientOrderId,
    String customerNotes = '',
  }) async {
    final request = OrderRequestModel(
      qrId: session.qrId,
      clientOrderId: clientOrderId,
      customerNotes: _clip(customerNotes),
      products: items.map(OrderProductModel.fromEntity).toList(),
      card: CardModel.fromEntity(card),
      // Same cycle as Self Order `kiosk_kds_message`: client builds the wire,
      // backend relays it on Pusher as `record.pat_kds_message` (rewriting the
      // provisional ticket # when known).
      patKdsMessage: PatKdsMessage.build(
        orderNumber: PatKdsMessage.provisionalOrderNumber,
        orderId: clientOrderId,
        items: items,
      ),
    );
    final response = await _policy.run<OrderResponse>(
      remote: () => _api.placeOrder(request),
      dummy: () =>
          DummyOrderData.placeOrder(session: session, items: items, card: card),
      onStatus: mapOrderStatus,
      // Charging a card must never fall back to a fake success.
      allowDummyFallback: false,
    );
    return response.data.toEntity(
      languageCode: _languageCode(),
      currency: session.currency,
      fallbackBranchName: session.branchName,
      fallbackTableName: session.tableName,
      cardLast4: card.last4,
    );
  }

  /// Status table of the order endpoint. `5xx` and anything unlisted keep
  /// the same `client_order_id` on retry.
  static AppException mapOrderStatus(int status, String? message) =>
      switch (status) {
        402 => CardDeclinedException(message),
        422 => OrderRejectedException(message),
        404 || 410 => TableUnavailableException(message),
        429 => TooManyAttemptsException(message),
        _ => const UnexpectedException(),
      };

  static String _clip(String value) {
    final trimmed = value.trim();
    return trimmed.length > maxNotesLength
        ? trimmed.substring(0, maxNotesLength)
        : trimmed;
  }
}
