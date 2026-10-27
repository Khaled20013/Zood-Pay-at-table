import '../../Constants.dart';
import '../../Helper/ApiServices/Apis/ApiBase.dart';
import '../../Helper/ApiServices/Base/ApiEndpoints.dart';
import '../../Helper/ApiServices/Base/ApiRequest.dart';
import '../../Helper/ApiServices/Base/DemoDataPolicy.dart';
import '../../Helper/ApiServices/Base/KApiResponse.dart';
import '../../Helper/Configs/kcore.dart';
import '../../Helper/Errors/AppException.dart';
import '../../Helper/path_selector_base.dart';
import '../Cart/CartItemModel.dart';
import '../CoreBaseModel.dart';
import '../TableSession/TableSessionModel.dart';
import 'CardDetailsModel.dart';
import 'DummyOrderData.dart';
import 'OrderReceiptModel.dart';
import 'OrderRequestModel.dart';
import 'PatKdsMessage.dart';

class OrdersApi extends CoreBaseModel {
  static const int maxNotesLength = 250;

  /// `POST /public/pay-at-table/orders`: charges [card] and creates the
  /// order in one call. Retrying with the same [clientOrderId] never charges
  /// twice. On success `data` is an [OrderReceiptModel].
  static Future<KApiResponse> create({
    required TableSessionModel session,
    required List<CartItemModel> items,
    required CardDetailsModel card,
    required String clientOrderId,
    String customerNotes = '',
  }) async {
    final body = OrderRequestModel(
      qrId: session.qrId,
      clientOrderId: clientOrderId,
      customerNotes: _clip(customerNotes),
      products: items.map(OrderProductModel.fromCartItem).toList(),
      card: OrderCardModel.fromCard(card),
      // Same cycle as Self Order `kiosk_kds_message`: client builds the wire,
      // backend relays it on Pusher as `record.pat_kds_message` (rewriting the
      // provisional ticket # when known).
      patKdsMessage: PatKdsMessage.build(
        orderNumber: PatKdsMessage.provisionalOrderNumber,
        orderId: clientOrderId,
        items: items,
      ),
    );

    final request = ApiRequest()
      ..url = "${config.url}/${ApiEndpoints.orders}"
      ..header = ApiBase().getHeader(hasBody: true)
      ..type = RequestType.post
      ..cashKey = "pat_create_order"
      ..body = body.toJson();

    final response = await DemoDataPolicy.run(
      request: request,
      dummy: () =>
          DummyOrderData.placeOrder(session: session, items: items, card: card),
      onStatus: mapOrderStatus,
      // Charging a card must never fall back to a fake success.
      allowDummyFallback: false,
    );
    if (response.error != null) return response;

    final data = response.responseMap?.select<Map<String, dynamic>>("data");
    if (data == null) return response..error = const UnexpectedException();
    response.data = OrderReceiptModel.fromJson(
      data,
      languageCode: lang,
      currency: session.currency,
      fallbackBranchName: session.branchName,
      fallbackTableName: session.tableName,
      cardLast4: card.last4,
    );
    return response;
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
