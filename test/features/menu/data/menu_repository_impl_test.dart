import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zood_pay_at_table/core/network/demo_data_policy.dart';
import 'package:zood_pay_at_table/features/menu/data/datasources/menu_api.dart';
import 'package:zood_pay_at_table/features/menu/data/models/menu_mapper.dart';
import 'package:zood_pay_at_table/features/menu/data/models/product_model.dart';
import 'package:zood_pay_at_table/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:zood_pay_at_table/features/menu/domain/entities/product.dart';

import '../../../helpers/fake_http.dart';
import '../../../helpers/fixtures.dart';

void main() {
  MenuRepositoryImpl dummyRepo({String languageCode = 'en'}) =>
      MenuRepositoryImpl(
        api: MenuApi(Dio()),
        policy: const DemoDataPolicy(
          useDummyData: true,
          simulatedLatency: Duration.zero,
        ),
        languageCode: () => languageCode,
      );

  group('MenuRepositoryImpl (dummy data)', () {
    test('groups products by category index, then "Other items"', () async {
      final products = await dummyRepo().getMenu(tableSession);
      expect(products.map((p) => p.category).toSet().toList(), [
        'Hot Beverages',
        'Cold Beverages',
        'Desserts',
        'Other items',
      ]);
      expect(products.last.categoryId, Product.otherCategoryId);
    });

    test(
      'joins modifiers, drops excluded options and keeps the rules',
      () async {
        final products = await dummyRepo().getMenu(tableSession);
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
      final arabic = await dummyRepo(languageCode: 'ar').getMenu(tableSession);
      final english = await dummyRepo().getMenu(tableSession);
      expect(arabic.map((p) => p.id), english.map((p) => p.id));
      final karak = arabic.firstWhere((p) => p.id == 'prd_karak_tea');
      expect(karak.name, 'شاي كرك');
      expect(karak.category, 'مشروبات ساخنة');
      expect(karak.modifiers.first.name, 'الحجم');
      expect(arabic.last.category, 'أصناف أخرى');
    });
  });

  group('MenuRepositoryImpl (API)', () {
    test('sends business_reference to all three endpoints', () async {
      final adapter = FakeHttpAdapter((_) => jsonResponse(200, {'data': []}));
      final repo = MenuRepositoryImpl(
        api: MenuApi(fakeDio(adapter)),
        policy: const DemoDataPolicy(useDummyData: false),
      );
      final products = await repo.getMenu(tableSession);
      expect(products, isEmpty);
      expect(adapter.requests.map((r) => r.uri.path).toSet(), {
        '/api/v1/public/pay-at-table/categories',
        '/api/v1/public/pay-at-table/products',
        '/api/v1/public/pay-at-table/modifiers',
      });
      expect(
        adapter.requests.map((r) => r.queryParameters['business_reference']),
        everyElement('100245'),
      );
    });
  });

  group('MenuMapper', () {
    test('hides a modifier whose options are all excluded', () {
      final products = MenuMapper.toProducts(
        categories: const [],
        products: [
          ProductModel.fromJson({
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
          }),
        ],
        modifiers: [
          ModifierModel.fromJson({
            'id': 'm1',
            'name': 'Size',
            'options': [
              {'id': 'o1', 'name': 'Small', 'price': 0},
            ],
          }),
        ],
        languageCode: 'en',
      );
      expect(products.single.modifiers, isEmpty);
    });
  });
}
