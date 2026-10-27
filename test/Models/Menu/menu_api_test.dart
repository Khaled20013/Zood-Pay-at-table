import 'package:flutter_test/flutter_test.dart';
import 'package:zood_pay_at_table/Constants.dart' as constants;
import 'package:zood_pay_at_table/Models/Menu/MenuApi.dart';
import 'package:zood_pay_at_table/Models/Menu/ProductModel.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mock_http.dart';

void main() {
  tearDown(() {
    MockApi.reset();
    constants.lang = 'en';
  });

  Future<List<ProductModel>> menu() async =>
      (await MenuApi.getAll(session: tableSession)).data as List<ProductModel>;

  group('MenuApi (dummy data)', () {
    setUp(useDummyData);

    test('groups products by category index, then "Other items"', () async {
      final products = await menu();
      expect(products.map((p) => p.category).toSet().toList(), [
        'Hot Beverages',
        'Cold Beverages',
        'Desserts',
        'Other items',
      ]);
      expect(products.last.categoryId, ProductModel.otherCategoryId);
    });

    test(
      'joins modifiers, drops excluded options and keeps the rules',
      () async {
        final products = await menu();
        final karak = products.firstWhere((p) => p.id == 'prd_karak_tea');
        expect(karak.modifiers.map((m) => m.modifierId), [
          'mod_size',
          'mod_sugar',
          'mod_extras',
        ]);
        final size = karak.modifiers.first;
        expect(size.isRequired, isTrue);
        expect(size.isSingleChoice, isTrue);
        expect(size.defaultOptionIds, ['opt_small']);
        final extras = karak.modifierById('mod_extras')!;
        expect(extras.options.map((o) => o.id), [
          'opt_cardamom',
          'opt_saffron',
        ]);
        expect(extras.maximumOptions, 2);
      },
    );

    test('serves the same menu in Arabic with matching ids', () async {
      final english = await menu();
      constants.lang = 'ar';
      final arabic = await menu();
      expect(arabic.map((p) => p.id), english.map((p) => p.id));
      final karak = arabic.firstWhere((p) => p.id == 'prd_karak_tea');
      expect(karak.name, 'شاي كرك');
      expect(karak.category, 'مشروبات ساخنة');
      expect(karak.modifiers.first.name, 'الحجم');
      expect(arabic.last.category, 'أصناف أخرى');
    });
  });

  group('MenuApi (API)', () {
    test('sends business_reference to all three endpoints', () async {
      final api = MockApi((_) async => jsonResponse(200, {'data': []}));
      expect(await menu(), isEmpty);
      expect(api.requests.map((r) => r.url.path).toSet(), {
        '/api/v1/public/pay-at-table/categories',
        '/api/v1/public/pay-at-table/products',
        '/api/v1/public/pay-at-table/modifiers',
      });
      expect(
        api.requests.map((r) => r.url.queryParameters['business_reference']),
        everyElement('100245'),
      );
    });

    test('fails when any of the three calls fails', () async {
      MockApi(
        (r) async => r.url.path.endsWith('/modifiers')
            ? errorResponse(500, 'Boom')
            : jsonResponse(200, {'data': []}),
      );
      final response = await MenuApi.getAll(session: tableSession);
      expect(response.data, isNull);
      expect(response.error, isNotNull);
    });
  });

  group('ProductModel.fromMenuJson', () {
    test('hides a modifier whose options are all excluded', () {
      final products = ProductModel.fromMenuJson(
        categories: const {'data': []},
        products: const {
          'data': [
            {
              'id': 'p1',
              'name': 'Tea',
              'price': 5,
              'category_id': null,
              'modifiers': [
                {
                  'modifier_id': 'm1',
                  'minimum_options': 1,
                  'maximum_options': 1,
                  'excluded_options_ids': ['o1'],
                  'index': 0,
                },
              ],
            },
          ],
        },
        modifiers: const {
          'data': [
            {
              'id': 'm1',
              'name': 'Size',
              'options': [
                {'id': 'o1', 'name': 'Small', 'price': 0},
              ],
            },
          ],
        },
        languageCode: 'en',
      );
      expect(products.single.modifiers, isEmpty);
    });
  });
}
