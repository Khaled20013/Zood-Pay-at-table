import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zood_pay_at_table/core/error/app_exception.dart';
import 'package:zood_pay_at_table/features/menu/domain/entities/product.dart';
import 'package:zood_pay_at_table/features/menu/domain/repositories/menu_repository.dart';
import 'package:zood_pay_at_table/features/menu/presentation/cubit/menu_cubit.dart';

import '../../../../helpers/fixtures.dart';

class _MockMenuRepository extends Mock implements MenuRepository {}

void main() {
  late _MockMenuRepository repository;

  setUp(() => repository = _MockMenuRepository());

  group('MenuCubit', () {
    blocTest<MenuCubit, MenuState>(
      'loads products and derives categories in menu order',
      setUp: () => when(
        () => repository.getMenu(tableSession),
      ).thenAnswer((_) async => [karakTea, icedSpanishLatte]),
      build: () => MenuCubit(repository),
      act: (c) => c.load(tableSession),
      verify: (c) {
        expect(c.state.status, MenuStatus.loaded);
        expect(c.state.categories, [
          MenuState.allCategory,
          'Hot Beverages',
          'Cold Beverages',
        ]);
      },
    );

    blocTest<MenuCubit, MenuState>(
      'filters by category and search query',
      setUp: () => when(
        () => repository.getMenu(tableSession),
      ).thenAnswer((_) async => [karakTea, icedSpanishLatte]),
      build: () => MenuCubit(repository),
      act: (c) async {
        await c.load(tableSession);
        c.selectCategory('Cold Beverages');
        expect(c.state.visibleProducts, [icedSpanishLatte]);
        c
          ..selectCategory(MenuState.allCategory)
          ..search('karak');
      },
      verify: (c) => expect(c.state.visibleProducts, [karakTea]),
    );

    blocTest<MenuCubit, MenuState>(
      'emits failure with message when the menu cannot load',
      setUp: () => when(
        () => repository.getMenu(tableSession),
      ).thenThrow(const NetworkException('offline')),
      build: () => MenuCubit(repository),
      act: (c) => c.load(tableSession),
      expect: () => const [
        MenuState(status: MenuStatus.loading),
        MenuState(
          status: MenuStatus.failure,
          error: NetworkException('offline'),
        ),
      ],
    );

    test('refresh keeps the selected category across languages', () async {
      const hot = Product(
        id: 'prd_karak_tea',
        name: 'Karak Tea',
        description: '',
        price: 8,
        category: 'Hot Beverages',
        categoryId: 'hot_beverages',
      );
      const hotAr = Product(
        id: 'prd_karak_tea',
        name: 'شاي كرك',
        description: '',
        price: 8,
        category: 'مشروبات ساخنة',
        categoryId: 'hot_beverages',
      );
      when(
        () => repository.getMenu(tableSession),
      ).thenAnswer((_) async => [hot]);
      final cubit = MenuCubit(repository);
      await cubit.load(tableSession);
      cubit
        ..selectCategory('Hot Beverages')
        ..search('kar');

      when(
        () => repository.getMenu(tableSession),
      ).thenAnswer((_) async => [hotAr]);
      final refreshed = await cubit.refresh(tableSession);

      expect(refreshed, [hotAr]);
      expect(cubit.state.status, MenuStatus.loaded);
      expect(cubit.state.selectedCategory, 'مشروبات ساخنة');
      expect(cubit.state.query, 'kar');
    });
  });
}
