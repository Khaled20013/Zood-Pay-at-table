import 'dart:convert';

import 'package:zood_pay_at_table/Models/Cart/CartItemModel.dart';

/// Multipeer kitchen wire for Zood KDS — same shape as Self Order
/// `KdsMessage.build` / Cashier `helloSendDataForSingleNew`:
///
/// `------orderNumber--products--notes--void--orderType--device--cashierId--uniqueId`
///
/// The KDS splits on `--`, strips `Optional`/`AnyHashable`/parentheses, turns
/// `[`/`]` into `{`/`}` and parses the products as JSON.
class PatKdsMessage {
  PatKdsMessage._();

  /// Same as Self Order `AppConstants.defaultPrepMinutes`.
  static const defaultPrepMinutes = 10;

  /// Device label on the wire (Self Order uses `"SelfOrder"`).
  static const deviceLabel = 'PayAtTable';

  /// Ticket # is assigned by the server after create. Send this on POST and
  /// let the backend rewrite the leading field when broadcasting Pusher.
  static const provisionalOrderNumber = 0;

  static const _dineIn = '0';
  static const _notVoid = 'NO';

  static String build({
    required int orderNumber,
    required String orderId,
    required List<CartItemModel> items,
    String deviceName = deviceLabel,
    String cashierId = '0',
  }) {
    final products = [
      for (final (index, item) in items.indexed) _product(item, index: index),
    ].join(', ');
    return [
      '------$orderNumber',
      '[$products]',
      '',
      _notVoid,
      _dineIn,
      _field(deviceName, deviceLabel),
      _field(cashierId, '0'),
      _safe(orderId),
    ].join('--');
  }

  /// Two empty fields in a row would form another `------` order marker.
  static String _field(String value, String fallback) {
    final safe = _safe(value);
    return safe.isEmpty ? fallback : safe;
  }

  static String _product(CartItemModel item, {required int index}) {
    final modifiers = [
      for (final o in item.selectedOptions)
        for (var i = 0; i < o.quantity; i++)
          ',1 X ${_safe(o.option.name)}',
    ].join();
    final json = jsonEncode({
      'ProductName': _safe(item.product.name),
      'qtyAddded': item.quantity,
      'itemStatus': '0',
      'NotesProduct': _safe(item.notes),
      'NotesForOrder': '',
      'Modifiers': modifiers,
      'ProductId': _safe(item.product.id),
      'Edited': '0',
      'LocalIdForProduct': '$index',
      'void_Product': _notVoid,
      'categoryId': _safe(item.product.categoryId ?? ''),
      'orderTypePickUp': _dineIn,
      'arabicName': '',
      'IdProductRows': '$index',
      'PrepTime': '${defaultPrepMinutes * 60}',
      'iscombo': '0',
      'ComboGroupCount': 0,
      'CourseName': 'Course 1',
      'courseActivate': '0',
      'couserCount': '1',
      'sendtoKitchenKDS': 'YES',
    });
    // Cashier/KDS expect each product as `[...]` object notation (square
    // brackets around a JSON object body), same as Self Order.
    return '[${json.substring(1, json.length - 1)}]';
  }

  static final _unsafe = RegExp(r'''[\[\]{}()"'\\\r\n\t]''');

  /// A dash at either end would merge with the `--` separator.
  static final _edgeDashes = RegExp(r'^[\s-]+|[\s-]+$');

  static String _safe(String value) => value
      .replaceAll('--', '—')
      .replaceAll('Optional', '')
      .replaceAll('AnyHashable', '')
      .replaceAll(_unsafe, ' ')
      .replaceAll(_edgeDashes, '');
}
