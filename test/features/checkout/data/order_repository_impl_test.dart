import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zood_pay_at_table/core/config/cashier_pusher_contract.dart';
import 'package:zood_pay_at_table/core/error/app_exception.dart';
import 'package:zood_pay_at_table/core/network/demo_data_policy.dart';
import 'package:zood_pay_at_table/features/cart/domain/entities/cart_item.dart';
import 'package:zood_pay_at_table/features/checkout/data/datasources/orders_api.dart';
import 'package:zood_pay_at_table/features/checkout/data/models/order_models.dart';
import 'package:zood_pay_at_table/features/checkout/data/repositories/order_repository_impl.dart';
import 'package:zood_pay_at_table/features/checkout/domain/entities/card_details.dart';
import 'package:zood_pay_at_table/features/menu/domain/entities/modifier_selection.dart';

import '../../../helpers/fake_http.dart';
import '../../../helpers/fixtures.dart';

void main() {
  const card = CardDetails(
    holderName: 'AHMED ALI',
    number: '4111111111111111',
    expiryMonth: '08',
    expiryYear: '2028',
    cvc: '123',
  );

  const items = [
    CartItem(
      id: 'line_0',
      product: karakTea,
      quantity: 2,
      notes: 'extra hot',
      selectedOptions: [
        SelectedOption(modifierId: 'mod_size', option: large, quantity: 1),
        SelectedOption(modifierId: 'mod_syrup', option: vanilla, quantity: 2),
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

  OrderRepositoryImpl apiRepo(FakeHttpAdapter adapter, {String lang = 'en'}) =>
      OrderRepositoryImpl(
        api: OrdersApi(fakeDio(adapter)),
        policy: const DemoDataPolicy(useDummyData: false),
        languageCode: () => lang,
      );

  Future<void> place(OrderRepositoryImpl repo) => repo.placeOrder(
    session: tableSession,
    items: items,
    card: card,
    clientOrderId: 'client-1',
    customerNotes: '  window seat ',
  );

  group('OrderRepositoryImpl (API)', () {
    test('posts the contract body: no prices, options per unit', () async {
      final adapter = FakeHttpAdapter((_) => jsonResponse(201, successBody));
      await place(apiRepo(adapter));

      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.uri.path, '/api/v1/public/pay-at-table/orders');
      expect(request.headers.containsKey('Authorization'), isFalse);
      final body = request.data as Map<String, dynamic>;
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
        card: CardModel(
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
      final adapter = FakeHttpAdapter((_) => jsonResponse(200, successBody));
      final receipt = await apiRepo(adapter, lang: 'ar').placeOrder(
        session: tableSession,
        items: items,
        card: card,
        clientOrderId: 'client-1',
      );
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
        final adapter = FakeHttpAdapter(
          (_) => errorResponse(status, 'Server says no'),
        );
        await expectLater(place(apiRepo(adapter)), throwsA(matcher));
      });
    }

    test('402 and 422 keep the server message', () async {
      await expectLater(
        place(
          apiRepo(
            FakeHttpAdapter((_) => errorResponse(402, 'Insufficient funds.')),
          ),
        ),
        throwsA(
          isA<CardDeclinedException>().having(
            (e) => e.serverMessage,
            'message',
            'Insufficient funds.',
          ),
        ),
      );
    });

    test('a network error never falls back to a fake order', () async {
      final repo = OrderRepositoryImpl(
        api: OrdersApi(Dio(BaseOptions(baseUrl: 'http://127.0.0.1:1/'))),
        policy: const DemoDataPolicy(
          useDummyData: false,
          fallbackToDummyOnNetworkError: true,
        ),
      );
      await expectLater(place(repo), throwsA(isA<NetworkException>()));
    });
  });

  group('OrderRepositoryImpl (dummy data)', () {
    final repo = OrderRepositoryImpl(
      api: OrdersApi(Dio()),
      policy: const DemoDataPolicy(
        useDummyData: true,
        simulatedLatency: Duration.zero,
      ),
    );

    test('returns a receipt with VAT on top', () async {
      final receipt = await repo.placeOrder(
        session: tableSession,
        items: items,
        card: card,
        clientOrderId: 'client-1',
      );
      expect(receipt.subtotal, 30.0);
      expect(receipt.taxes, 4.5);
      expect(receipt.total, 34.5);
      expect(receipt.reference, startsWith('#R'));
    });

    test('declines the test card 4000 0000 0000 0002', () {
      expect(
        repo.placeOrder(
          session: tableSession,
          items: items,
          card: CardDetails.fromInput(
            holderName: 'A',
            number: '4000 0000 0000 0002',
            expiry: '08/28',
            cvc: '123',
          ),
          clientOrderId: 'client-1',
        ),
        throwsA(isA<CardDeclinedException>()),
      );
    });
  });
}
