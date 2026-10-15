/// Backend broadcast after `POST /public/pay-at-table/orders`.
///
/// Cashier listens on a Pay-at-Table channel only; the **`record` must match
/// Kiosk / Self Order Pusher** (`orders/bulk` row). This Flutter app does not
/// subscribe to Pusher.
///
/// ```json
/// {
///   "orders": [{
///     "order_id": "uuid",
///     "created_at": 1791980263,
///     "table_name": "FIRST FLOOR 2",
///     "number": 390,
///     "reference": "#R000390",
///     "record": {
///       "order_id": "uuid",
///       "local_id": "390",
///       "price": "128.80",
///       "subtotal_price": "112.00",
///       "TotalTaxOrder": "16.80",
///       "products": "[{...; each line needs modifier:[{modiId,modiName,modiPrice,quantityAdded:\"1\",...}] ...}]",
///       "AmountBreakUp": "[{...}]",
///       "charges": "[]",
///       "pat_kds_message": "------390--[[...]]----NO--0--PayAtTable--...",
///       "DeviceName": "FIRST FLOOR 2",
///       "paymentStatus": "Complete",
///       "order_type": "0",
///       "sentToKitchen": "Yes"
///     }
///   }]
/// }
/// ```
///
/// Kitchen wire (same cycle as Self Order):
/// 1. PAT Flutter builds `pat_kds_message` and sends it on
///    `POST /public/pay-at-table/orders`.
/// 2. Backend puts it on Pusher `record.pat_kds_message` (rewrite the leading
///    ticket # if the client sent `0`).
/// 3. Cashier prefers `pat_kds_message`, falls back to `kiosk_kds_message`.
abstract final class CashierPusherContract {
  /// Logical channel. Cashier joins `private-pay-at-table-orders.{deviceCode}`.
  static const String channelPrefix = 'pay-at-table-orders.';

  static const String eventName = 'pay-at-table-order';

  /// Preferred KDS Multipeer payload on PAT `record` (same format as kiosk).
  static const String patKdsMessageKey = 'pat_kds_message';

  /// Legacy fallback until backend ships [patKdsMessageKey].
  static const String kioskKdsMessageFallbackKey = 'kiosk_kds_message';

  static String channelFor(String deviceCode) => '$channelPrefix$deviceCode';
}
