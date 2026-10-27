import 'package:flutter_test/flutter_test.dart';
import 'package:zood_pay_at_table/Bloc/AppCubit.dart';
import 'package:zood_pay_at_table/Bloc/states.dart';
import 'package:zood_pay_at_table/Helper/ApiServices/Base/KApiResponse.dart';
import 'package:zood_pay_at_table/Helper/Errors/AppException.dart';
import 'package:zood_pay_at_table/Models/Menu/MenuModel.dart';
import 'package:zood_pay_at_table/Models/Menu/ModifierSelectionModel.dart';
import 'package:zood_pay_at_table/Models/Menu/ProductModel.dart';
import 'package:zood_pay_at_table/Models/TableSession/TableSessionModel.dart';
import 'package:zood_pay_at_table/Screens/Menu/MenuScreen/Controller/MenuScreenController.dart';

import '../helpers/fixtures.dart';

KApiResponse ok(Object data) => KApiResponse.successRespone()..data = data;

KApiResponse fail(AppException error) => KApiResponse.failure(error);

void main() {
  late int seq;
  setUp(() => seq = 0);

  AppCubit buildCubit({
    ResolveTableRequest? resolveTableRequest,
    LoadMenuRequest? loadMenuRequest,
  }) => AppCubit(
    resolveTableRequest:
        resolveTableRequest ?? ((_) async => ok(tableSession)),
    loadMenuRequest:
        loadMenuRequest ?? ((_) async => ok(const <ProductModel>[])),
    cartLineId: () => 'line_${seq++}',
  );

  group('AppCubit · table session', () {
    test('starts idle', () {
      final cubit = buildCubit();
      expect(cubit.sessionStatus, TableSessionStatus.initial);
      expect(cubit.session, isNull);
    });

    test('emits loading then loaded when the QR resolves', () async {
      final cubit = buildCubit();
      final states = <AppStates>[];
      final sub = cubit.stream.listen(states.add);
      await cubit.resolveTable(demoQrId);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      final session = states.whereType<TableSessionAppStates>().toList();
      expect(session.map((s) => s.status), [
        TableSessionStatus.loading,
        TableSessionStatus.loaded,
      ]);
      expect(cubit.session!.displayTitle, 'Olaya · T5');
    });

    test('trims the QR id before resolving (ids are case-sensitive)', () async {
      final calls = <String>[];
      final cubit = buildCubit(
        resolveTableRequest: (id) async {
          calls.add(id);
          return ok(tableSession);
        },
      );
      await cubit.resolveTable('  $demoQrId ');
      expect(calls, [demoQrId]);
    });

    test('fails with the exception from the API', () async {
      final cubit = buildCubit(
        resolveTableRequest: (_) async =>
            fail(const QrNotFoundException('Unknown table')),
      );
      await cubit.resolveTable('bad');
      expect(cubit.sessionStatus, TableSessionStatus.failure);
      expect(cubit.sessionQrId, 'bad');
      expect(cubit.sessionError, const QrNotFoundException('Unknown table'));
    });

    test('does not refetch an already-loaded QR', () async {
      var calls = 0;
      final cubit = buildCubit(
        resolveTableRequest: (_) async {
          calls++;
          return ok(tableSession);
        },
      );
      await cubit.resolveTable(demoQrId);
      await cubit.resolveTable(demoQrId);
      expect(calls, 1);
    });

    test('retry re-resolves after a failure', () async {
      var calls = 0;
      final cubit = buildCubit(
        resolveTableRequest: (_) async =>
            calls++ == 0 ? fail(const NetworkException()) : ok(tableSession),
      );
      await cubit.resolveTable(demoQrId);
      expect(cubit.sessionStatus, TableSessionStatus.failure);
      await cubit.retrySession();
      expect(cubit.isSessionLoaded, isTrue);
      expect(cubit.session, tableSession);
    });

    test('a stale response for a previous QR is ignored', () async {
      const other = 'ffffffffffffffffffffffff';
      final cubit = buildCubit(
        resolveTableRequest: (id) => id == demoQrId
            ? Future.delayed(
                const Duration(milliseconds: 30),
                () => ok(tableSession),
              )
            : Future.value(fail(const QrNotFoundException('gone'))),
      );
      final first = cubit.resolveTable(demoQrId);
      await cubit.resolveTable(other);
      await first;
      expect(cubit.sessionQrId, other);
      expect(cubit.sessionStatus, TableSessionStatus.failure);
    });

    test('resolving binds the cart and warms the menu', () async {
      final cubit = buildCubit(
        loadMenuRequest: (_) async => ok(const [karakTea]),
      );
      await cubit.resolveTable(demoQrId);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.cart.qrId, demoQrId);
      expect(cubit.menu.products, [karakTea]);
    });
  });

  group('AppCubit · menu', () {
    test('loads products and derives categories in menu order', () async {
      final cubit = buildCubit(
        loadMenuRequest: (_) async => ok(const [karakTea, icedSpanishLatte]),
      );
      await cubit.loadMenu(tableSession);
      expect(cubit.menu.status, MenuStatus.loaded);
      expect(cubit.menu.categories, [
        MenuModel.allCategory,
        'Hot Beverages',
        'Cold Beverages',
      ]);
    });

    test('filters by category and search query', () async {
      final cubit = buildCubit(
        loadMenuRequest: (_) async => ok(const [karakTea, icedSpanishLatte]),
      );
      await cubit.loadMenu(tableSession);
      expect(
        cubit.menu.visibleProducts(selectedCategory: 'Cold Beverages'),
        [icedSpanishLatte],
      );
      expect(cubit.menu.visibleProducts(query: 'karak'), [karakTea]);
    });

    test('fails with the error when the menu cannot load', () async {
      final cubit = buildCubit(
        loadMenuRequest: (_) async => fail(const NetworkException('offline')),
      );
      final states = <AppStates>[];
      final sub = cubit.stream.listen(states.add);
      await cubit.loadMenu(tableSession);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      expect(states.whereType<MenuAppStates>().map((s) => s.menu), const [
        MenuModel(status: MenuStatus.loading),
        MenuModel(
          status: MenuStatus.failure,
          error: NetworkException('offline'),
        ),
      ]);
    });

    test('refresh keeps the screen filters across languages', () async {
      const hot = ProductModel(
        id: 'prd_karak_tea',
        name: 'Karak Tea',
        description: '',
        price: 8,
        category: 'Hot Beverages',
        categoryId: 'hot_beverages',
      );
      const hotAr = ProductModel(
        id: 'prd_karak_tea',
        name: 'شاي كرك',
        description: '',
        price: 8,
        category: 'مشروبات ساخنة',
        categoryId: 'hot_beverages',
      );
      var products = const [hot];
      final cubit = buildCubit(loadMenuRequest: (_) async => ok(products));
      final controller = MenuScreenController(
        () {},
        appCubit: cubit,
        session: tableSession,
      );
      await cubit.loadMenu(tableSession);
      controller
        ..selectedCategoryId = cubit.menu.categoryIdOf('Hot Beverages')
        ..search('kar');

      products = const [hotAr];
      final refreshed = await cubit.refreshMenu(tableSession);

      expect(refreshed, [hotAr]);
      expect(cubit.menu.status, MenuStatus.loaded);
      expect(controller.selectedCategory, 'مشروبات ساخنة');
      expect(controller.query, 'kar');
      controller.dispose();
    });
  });

  group('AppCubit · cart', () {
    const largeSize = SelectedOptionModel(
      modifierId: 'mod_size',
      option: large,
      quantity: 1,
    );
    const twoVanilla = SelectedOptionModel(
      modifierId: 'mod_syrup',
      option: vanilla,
      quantity: 2,
    );

    test('starts empty', () {
      final cubit = buildCubit();
      expect(cubit.cart.isEmpty, isTrue);
      expect(cubit.cart.subtotal, 0);
      expect(cubit.cart.totalQuantity, 0);
    });

    test('addProduct prices the line with its options (first syrup free)', () {
      final cubit = buildCubit()
        ..addProduct(
          karakTea,
          options: const [largeSize, twoVanilla],
          quantity: 2,
          notes: '  extra hot ',
        );
      final item = cubit.cart.items.single;
      expect(item.unitPrice, 8 + 5 + 2);
      expect(item.lineTotal, 30.0);
      expect(item.notes, 'extra hot');
      expect(item.optionsSummary, 'Large · Vanilla ×2');
      expect(cubit.cart.totalQuantity, 2);
    });

    test('adding the same configuration merges into one line', () {
      final cubit = buildCubit()
        ..addProduct(karakTea, options: const [largeSize])
        ..addProduct(karakTea, options: const [largeSize], quantity: 2);
      expect(cubit.cart.items, hasLength(1));
      expect(cubit.cart.items.single.quantity, 3);
      expect(cubit.cart.subtotal, 39.0);
    });

    test('different options or notes stay as separate lines', () {
      final cubit = buildCubit()
        ..addProduct(karakTea)
        ..addProduct(karakTea, options: const [largeSize])
        ..addProduct(karakTea, notes: 'No sugar');
      expect(cubit.cart.items, hasLength(3));
      expect(cubit.cart.quantityOf(karakTea.id), 3);
      expect(cubit.cart.subtotal, 29.0);
    });

    test('ignores unavailable products and non-positive quantities', () async {
      final cubit = buildCubit();
      final states = <AppStates>[];
      final sub = cubit.stream.listen(states.add);
      cubit
        ..addProduct(soldOutCake)
        ..addProduct(karakTea, quantity: 0);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      expect(states, isEmpty);
    });

    test('increment and decrement adjust quantity; decrement at 1 removes', () {
      final cubit = buildCubit()..addProduct(icedSpanishLatte);
      final id = cubit.cart.items.single.id;
      cubit
        ..incrementCartLine(id)
        ..incrementCartLine(id)
        ..decrementCartLine(id);
      expect(cubit.cart.items.single.quantity, 2);
      cubit
        ..decrementCartLine(id)
        ..decrementCartLine(id);
      expect(cubit.cart.isEmpty, isTrue);
    });

    test('setCartLineQuantity clamps to the per-line maximum', () {
      final cubit = buildCubit()..addProduct(icedSpanishLatte);
      cubit.setCartLineQuantity(cubit.cart.items.single.id, 500);
      expect(cubit.cart.items.single.quantity, AppCubit.maxQuantityPerLine);
    });

    test('notes are trimmed and capped at 250 characters', () {
      final cubit = buildCubit()
        ..addProduct(icedSpanishLatte, notes: 'x' * 300);
      expect(cubit.cart.items.single.notes.length, 250);
    });

    test('update notes, remove and restore a line', () {
      final cubit = buildCubit()
        ..addProduct(karakTea)
        ..addProduct(icedSpanishLatte);
      final latte = cubit.cart.items.last;
      cubit.updateCartLineNotes(cubit.cart.items.first.id, ' Less ice please ');
      expect(cubit.cart.items.first.notes, 'Less ice please');

      cubit.removeCartLine(latte.id);
      expect(cubit.cart.items, hasLength(1));

      cubit.restoreCartLine(latte, 1);
      expect(cubit.cart.items.map((i) => i.product.id), [
        karakTea.id,
        icedSpanishLatte.id,
      ]);
    });

    test('VAT is added on top of the subtotal', () {
      final cubit = buildCubit()..addProduct(icedSpanishLatte, quantity: 2);
      expect(cubit.cart.subtotal, 36.0);
      expect(cubit.cart.vat(0.15), 5.4);
      expect(cubit.cart.total(0.15), 41.4);
    });

    test('bindCart clears the cart when switching tables only', () {
      final cubit = buildCubit()
        ..bindCart(demoQrId)
        ..addProduct(karakTea)
        ..bindCart(demoQrId);
      expect(cubit.cart.items, hasLength(1));
      cubit.bindCart('other-table');
      expect(cubit.cart.isEmpty, isTrue);
      expect(cubit.cart.qrId, 'other-table');
    });

    test('clearCart empties items but keeps the table', () {
      final cubit = buildCubit()
        ..bindCart(demoQrId)
        ..addProduct(karakTea)
        ..clearCart();
      expect(cubit.cart.isEmpty, isTrue);
      expect(cubit.cart.qrId, demoQrId);
    });

    test('CartAppStates carries the previous cart', () async {
      final cubit = buildCubit()..addProduct(karakTea);
      final next = cubit.stream.first;
      cubit.clearCart();
      final state = await next as CartAppStates;
      expect(state.previous.isEmpty, isFalse);
      expect(state.cart.isEmpty, isTrue);
    });

    test('syncCartProducts swaps in re-fetched products and options', () {
      const arabicLarge = ModifierOptionModel(
        id: 'opt_large',
        name: 'كبير',
        price: 5,
      );
      const arabicKarak = ProductModel(
        id: 'prd_karak_tea',
        name: 'شاي كرك',
        description: 'شاي بالحليب',
        price: 8.0,
        category: 'مشروبات ساخنة',
        modifiers: [
          ProductModifierModel(
            modifierId: 'mod_size',
            name: 'الحجم',
            options: [arabicLarge],
            minimumOptions: 1,
            maximumOptions: 1,
          ),
        ],
      );
      final cubit = buildCubit()
        ..addProduct(karakTea, options: const [largeSize, twoVanilla])
        ..addProduct(icedSpanishLatte);

      cubit.syncCartProducts(const [arabicKarak]);

      // The latte and the syrup modifier are gone from the new menu.
      final karakLine = cubit.cart.items.single;
      expect(karakLine.id, 'line_0');
      expect(karakLine.product.name, 'شاي كرك');
      expect(karakLine.selectedOptions.single.option, arabicLarge);
      expect(cubit.cart.subtotal, 13.0);
    });
  });
}
