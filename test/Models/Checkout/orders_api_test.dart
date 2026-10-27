import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:zood_pay_at_table/Constants.dart' as constants;
import 'package:zood_pay_at_table/Helper/ApiServices/Base/DemoDataPolicy.dart';
import 'package:zood_pay_at_table/Helper/ApiServices/Base/KApiResponse.dart';
import 'package:zood_pay_at_table/Helper/Configs/CashierPusherContract.dart';
import 'package:zood_pay_at_table/Helper/Errors/AppException.dart';
import 'package:zood_pay_at_table/Models/Cart/CartItemModel.dart';
import 'package:zood_pay_at_table/Models/Checkout/CardDetailsModel.dart';
import 'package:zood_pay_at_table/Models/Checkout/OrderReceiptModel.dart';
import 'package:zood_pay_at_table/Models/Checkout/OrderRequestModel.dart';
import 'package:zood_pay_at_table/Models/Checkout/OrdersApi.dart';
import 'package:zood_pay_at_table/Models/Menu/ModifierSelectionModel.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mock_http.dart';

void main() {
  tearDown(() {
    MockApi.reset();
    constants.lang = 'en';
  });

  const card = CardDetailsModel(
    holderName: 'AHMED ALI',
    number: '4111111111111111',
    expiryMonth: '08',
    expiryYear: '2028',
    cvc: '123',
  );

  const items = [
    CartItemModel(
      id: 'line_0',
      product: karakTea,
      quantity: 2,
      notes: 'extra hot',
      selectedOptions: [
        SelectedOptionModel(modifierId: 'mod_size', option: large, quantity: 1),
        SelectedOptionModel(
          modifierId: 'mod_syrup',
          option: vanilla,
          quantity: 2,
        ),
      ],
    ),
  ];

  const successBody = {
    'message': 'Order placed successfully',
    'data': {
      'id': 'ord-uuid',
      'number': 23,
      'reference': '#R000123',
      'subtotal_price': 610,
      'total_taxes': 91.5,
      'total_price': 701.5,
      'branch': {'name': 'Olaya', 'name_localized': 'العليا'},
      'table': {'name': 'T5', 'name_localized': null},
      'paid_at': '2026-10-07T14:06:24.000000Z',
    },
  };

  Future<KApiResponse> place({CardDetailsModel cardDetails = card}) =>
      OrdersApi.create(
        session: tableSession,
        items: items,
        card: cardDetails,
        clientOrderId: 'client-1',
        customerNotes: '  window seat ',
      );

  group('OrdersApi (API)', () {
    test('posts the contract body: no prices, options per unit', () async {
      final api = MockApi((_) async => jsonResponse(201, successBody));
      await place();

      final request = api.requests.single;
      expect(request.method, 'POST');
      expect(request.url.path, '/api/v1/public/pay-at-table/orders');
      expect(
        request.headers.keys.map((k) => k.toLowerCase()),
        isNot(contains('authorization')),
      );
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['qr_id'], demoQrId);
      expect(body['client_order_id'], 'client-1');
      expect(body['customer_notes'], 'window seat');
      expect(body['products'], [
        {
          'product_id': 'prd_karak_tea',
          'quantity': 2,
          'notes': 'extra hot',
          'options': [
            {'modifier_option_id': 'opt_large', 'quantity': 1},
            {'modifier_option_id': 'opt_vanilla', 'quantity': 2},
          ],
        },
      ]);
      expect(body['card'], {
        'holder_name': 'AHMED ALI',
        'number': '4111111111111111',
        'expiry_month': '08',
        'expiry_year': '2028',
        'cvc': '123',
      });
      // Same Multipeer shape as Self Order `kiosk_kds_message`.
      final kds = body[CashierPusherContract.patKdsMessageKey] as String;
      expect(kds, startsWith('------0--[['));
      expect(kds, contains('"ProductName":"Karak Tea"'));
      expect(kds, contains('"qtyAddded":2'));
      expect(kds, contains('"Modifiers":",1 X Large,1 X Vanilla,1 X Vanilla"'));
      expect(kds, contains('"NotesProduct":"extra hot"'));
      expect(kds, endsWith('--NO--0--PayAtTable--0--client-1'));
    });

    test('omits pat_kds_message from JSON when null', () {
      const request = OrderRequestModel(
        qrId: demoQrId,
        clientOrderId: 'client-1',
        customerNotes: '',
        products: [],
        card: OrderCardModel(
          holderName: 'A',
          number: '4111111111111111',
          expiryMonth: '08',
          expiryYear: '2028',
          cvc: '123',
        ),
      );
      expect(request.toJson().containsKey('pat_kds_message'), isFalse);
    });

    test('maps the response to the receipt (200 = already paid)', () async {
      MockApi((_) async => jsonResponse(200, successBody));
      constants.lang = 'ar';
      final receipt = (await place()).data as OrderReceiptModel;
      expect(receipt.orderNumber, '23');
      expect(receipt.reference, '#R000123');
      expect(receipt.subtotal, 610);
      expect(receipt.taxes, 91.5);
      expect(receipt.total, 701.5);
      expect(receipt.branchName, 'العليا');
      expect(receipt.tableName, 'T5');
      expect(receipt.cardLast4, '1111');
    });

    for (final (status, matcher) in [
      (402, isA<CardDeclinedException>()),
      (422, isA<OrderRejectedException>()),
      (404, isA<TableUnavailableException>()),
      (410, isA<TableUnavailableException>()),
      (429, isA<TooManyAttemptsException>()),
      (500, isA<UnexpectedException>()),
    ]) {
      test('$status maps to ${matcher.runtimeType}', () async {
        MockApi((_) async => errorResponse(status, 'Server says no'));
        final response = await place();
        expect(response.data, isNull);
        expect(response.error, matcher);
      });
    }

    test('402 and 422 keep the server message', () async {
      MockApi((_) async => errorResponse(402, 'Insufficient funds.'));
      expect(
        (await place()).error,
        isA<CardDeclinedException>().having(
          (e) => e.serverMessage,
          'message',
          'Insufficient funds.',
        ),
      );
    });

    test('a network error never falls back to a fake order', () async {
      MockApi((_) async => throw Exception('offline'));
      DemoDataPolicy.fallbackToDummyOnNetworkError = true;
      final response = await place();
      expect(response.data, isNull);
      expect(response.error, isA<NetworkException>());
    });
  });

  group('OrdersApi (dummy data)', () {
    setUp(useDummyData);

    test('returns a receipt with VAT on top', () async {
      final receipt = (await place()).data as OrderReceiptModel;
      expect(receipt.subtotal, 30.0);
      expect(receipt.taxes, 4.5);
      expect(receipt.total, 34.5);
      expect(receipt.reference, startsWith('#R'));
    });

    test('declines the test card 4000 0000 0000 0002', () async {
      final response = await place(
        cardDetails: CardDetailsModel.fromInput(
          holderName: 'A',
          number: '4000 0000 0000 0002',
          expiry: '08/28',
          cvc: '123',
        ),
      );
      expect(response.error, isA<CardDeclinedException>());
    });
  });
}
