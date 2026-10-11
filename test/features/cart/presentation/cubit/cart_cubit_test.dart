import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zood_pay_at_table/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:zood_pay_at_table/features/menu/domain/entities/modifier_selection.dart';
import 'package:zood_pay_at_table/features/menu/domain/entities/product.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  late int seq;
  CartCubit buildCubit() => CartCubit(idGenerator: () => 'line_${seq++}');

  setUp(() => seq = 0);

  const largeSize = SelectedOption(
    modifierId: 'mod_size',
    option: large,
    quantity: 1,
  );
  const twoVanilla = SelectedOption(
    modifierId: 'mod_syrup',
    option: vanilla,
    quantity: 2,
  );

  group('CartCubit', () {
    test('starts empty', () {
      final cubit = buildCubit();
      expect(cubit.state.isEmpty, isTrue);
      expect(cubit.state.subtotal, 0);
      expect(cubit.state.totalQuantity, 0);
    });

    blocTest<CartCubit, CartState>(
      'addProduct prices the line with its options (first syrup unit free)',
      build: buildCubit,
      act: (c) => c.addProduct(
        karakTea,
        options: const [largeSize, twoVanilla],
        quantity: 2,
        notes: '  extra hot ',
      ),
      verify: (c) {
        final item = c.state.items.single;
        expect(item.unitPrice, 8 + 5 + 2);
        expect(item.lineTotal, 30.0);
        expect(item.notes, 'extra hot');
        expect(item.optionsSummary, 'Large · Vanilla ×2');
        expect(c.state.totalQuantity, 2);
      },
    );

    blocTest<CartCubit, CartState>(
      'adding the same configuration merges into one line',
      build: buildCubit,
      act: (c) => c
        ..addProduct(karakTea, options: const [largeSize])
        ..addProduct(karakTea, options: const [largeSize], quantity: 2),
      verify: (c) {
        expect(c.state.items, hasLength(1));
        expect(c.state.items.single.quantity, 3);
        expect(c.state.subtotal, 39.0);
      },
    );

    blocTest<CartCubit, CartState>(
      'different options or notes stay as separate lines',
      build: buildCubit,
      act: (c) => c
        ..addProduct(karakTea)
        ..addProduct(karakTea, options: const [largeSize])
        ..addProduct(karakTea, notes: 'No sugar'),
      verify: (c) {
        expect(c.state.items, hasLength(3));
        expect(c.state.quantityOf(karakTea.id), 3);
        expect(c.state.subtotal, 29.0);
      },
    );

    blocTest<CartCubit, CartState>(
      'ignores unavailable products and non-positive quantities',
      build: buildCubit,
      act: (c) => c
        ..addProduct(soldOutCake)
        ..addProduct(karakTea, quantity: 0),
      expect: () => <CartState>[],
    );

    blocTest<CartCubit, CartState>(
      'increment and decrement adjust quantity; decrement at 1 removes',
      build: buildCubit,
      act: (c) {
        c.addProduct(icedSpanishLatte);
        final id = c.state.items.single.id;
        c
          ..increment(id)
          ..increment(id)
          ..decrement(id);
        expect(c.state.items.single.quantity, 2);
        c
          ..decrement(id)
          ..decrement(id);
      },
      verify: (c) => expect(c.state.isEmpty, isTrue),
    );

    blocTest<CartCubit, CartState>(
      'setQuantity clamps to the per-line maximum',
      build: buildCubit,
      act: (c) {
        c.addProduct(icedSpanishLatte);
        c.setQuantity(c.state.items.single.id, 500);
      },
      verify: (c) =>
          expect(c.state.items.single.quantity, CartCubit.maxQuantityPerLine),
    );

    blocTest<CartCubit, CartState>(
      'notes are trimmed and capped at 250 characters',
      build: buildCubit,
      act: (c) => c.addProduct(icedSpanishLatte, notes: 'x' * 300),
      verify: (c) => expect(c.state.items.single.notes.length, 250),
    );

    blocTest<CartCubit, CartState>(
      'updateNotes, removeItem and restoreItem',
      build: buildCubit,
      act: (c) {
        c
          ..addProduct(karakTea)
          ..addProduct(icedSpanishLatte);
        final latte = c.state.items.last;
        c.updateNotes(c.state.items.first.id, ' Less ice please ');
        expect(c.state.items.first.notes, 'Less ice please');

        c.removeItem(latte.id);
        expect(c.state.items, hasLength(1));

        c.restoreItem(latte, 1);
      },
      verify: (c) {
        expect(c.state.items.map((i) => i.product.id), [
          karakTea.id,
          icedSpanishLatte.id,
        ]);
      },
    );

    blocTest<CartCubit, CartState>(
      'VAT is added on top of the subtotal',
      build: buildCubit,
      act: (c) => c.addProduct(icedSpanishLatte, quantity: 2),
      verify: (c) {
        expect(c.state.subtotal, 36.0);
        expect(c.state.vat(0.15), 5.4);
        expect(c.state.total(0.15), 41.4);
      },
    );

    blocTest<CartCubit, CartState>(
      'bindSession clears the cart when switching tables, keeps it otherwise',
      build: buildCubit,
      act: (c) {
        c
          ..bindSession(demoQrId)
          ..addProduct(karakTea)
          ..bindSession(demoQrId);
        expect(c.state.items, hasLength(1));
        c.bindSession('other-table');
      },
      verify: (c) {
        expect(c.state.isEmpty, isTrue);
        expect(c.state.qrId, 'other-table');
      },
    );

    blocTest<CartCubit, CartState>(
      'clear empties items but keeps the table',
      build: buildCubit,
      act: (c) => c
        ..bindSession(demoQrId)
        ..addProduct(karakTea)
        ..clear(),
      verify: (c) {
        expect(c.state.isEmpty, isTrue);
        expect(c.state.qrId, demoQrId);
      },
    );

    test('syncProducts swaps in re-fetched products and options by id', () {
      const arabicLarge = ModifierOption(
        id: 'opt_large',
        name: 'كبير',
        price: 5,
      );
      const arabicKarak = Product(
        id: 'prd_karak_tea',
        name: 'شاي كرك',
        description: 'شاي بالحليب',
        price: 8.0,
        category: 'مشروبات ساخنة',
        modifiers: [
          ProductModifier(
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

      cubit.syncProducts(const [arabicKarak]);

      // The latte and the syrup modifier are gone from the new menu.
      final karakLine = cubit.state.items.single;
      expect(karakLine.id, 'line_0');
      expect(karakLine.product.name, 'شاي كرك');
      expect(karakLine.selectedOptions.single.option, arabicLarge);
      expect(cubit.state.subtotal, 13.0);
    });
  });
}
