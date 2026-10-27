import 'dart:math';

import 'package:zood_pay_at_table/Helper/Errors/AppException.dart';
import 'package:zood_pay_at_table/Helper/CurrencyFormatter.dart';
import 'package:zood_pay_at_table/Models/Cart/CartItemModel.dart';
import 'package:zood_pay_at_table/Models/TableSession/TableSessionModel.dart';
import 'package:zood_pay_at_table/Models/Checkout/CardDetailsModel.dart';

/// Demo stand-in for `POST /public/pay-at-table/orders`, in the API's JSON
/// shape.
abstract final class DummyOrderData {
  /// Any card ending in `0002` is declined (`402`), like gateway test cards.
  static const String declinedCardNumber = '4000000000000002';

  static final Random _random = Random();

  /// `POST /public/pay-at-table/orders` body.
  static Map<String, dynamic> placeOrder({
    required TableSessionModel session,
    required List<CartItemModel> items,
    required CardDetailsModel card,
  }) {
    if (card.number.endsWith('0002')) {
      throw const CardDeclinedException('Insufficient funds.');
    }
    final subtotal = CurrencyFormatter.roundMoney(
      items.fold<double>(0, (s, i) => s + i.lineTotal),
    );
    final taxes = CurrencyFormatter.roundMoney(subtotal * session.vatRate);
    final number = _random.nextInt(900) + 100;
    return {
      'message': 'Order placed successfully',
      'data': {
        'id': 'demo-${DateTime.now().millisecondsSinceEpoch}',
        'number': number,
        'reference': '#R${number.toString().padLeft(6, '0')}',
        'subtotal_price': subtotal,
        'total_taxes': taxes,
        'total_price': CurrencyFormatter.roundMoney(subtotal + taxes),
        'branch': {'name': session.branchName, 'name_localized': null},
        'table': {'name': session.tableName, 'name_localized': null},
        'paid_at': DateTime.now().toUtc().toIso8601String(),
      },
    };
  }
}
