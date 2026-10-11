import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zood_pay_at_table/core/localization/l10n.dart';
import 'package:zood_pay_at_table/core/theme/app_theme.dart';
import 'package:zood_pay_at_table/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:zood_pay_at_table/features/menu/domain/entities/product.dart';
import 'package:zood_pay_at_table/features/menu/presentation/screens/product_details_dialog.dart';

import '../../../helpers/fixtures.dart';

void main() {
  late CartCubit cart;

  setUp(() => cart = CartCubit());
  tearDown(() => cart.close());

  Future<void> openSheet(
    WidgetTester tester,
    Product product, {
    Locale locale = const Locale('en'),
    double height = 780,
  }) async {
    tester.view
      ..physicalSize = Size(360, height)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      BlocProvider.value(
        value: cart,
        child: MaterialApp(
          locale: locale,
          theme: AppTheme.light(),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => showProductDetails(
                    context,
                    product: product,
                    currency: 'SAR',
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('a required modifier blocks adding until it is chosen', (
    tester,
  ) async {
    await openSheet(tester, mintLemonade);

    expect(find.text('Choose Sugar'), findsOneWidget);
    await tester.tap(find.text('Choose Sugar'));
    await tester.pumpAndSettle();
    expect(cart.state.isEmpty, isTrue);

    await tester.tap(find.text('Less sugar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to order'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final item = cart.state.items.single;
    expect(item.selectedOptions.single.option, lessSugar);
  });

  testWidgets('defaults, option prices and steppers feed the cart line', (
    tester,
  ) async {
    await openSheet(tester, karakTea, height: 1600);

    expect(find.text('+ SAR\u00A05.00'), findsOneWidget);
    await tester.tap(find.text('Large'));
    await tester.pump();
    final vanillaRow = find.ancestor(
      of: find.text('Vanilla'),
      matching: find.byType(Row),
    );
    final plus = find.descendant(
      of: vanillaRow.first,
      matching: find.byIcon(Icons.add_rounded),
    );
    await tester.tap(plus);
    await tester.pump();
    await tester.tap(plus);
    await tester.pump();

    await tester.tap(find.text('Add to order'));
    await tester.pumpAndSettle();

    final item = cart.state.items.single;
    expect(item.selectedOptions.map((o) => (o.option.id, o.quantity)), [
      ('opt_large', 1),
      ('opt_vanilla', 2),
    ]);
    // 8 + Large 5 + one charged vanilla (first unit free).
    expect(item.unitPrice, 15.0);
  });

  for (final locale in const [Locale('en'), Locale('ar')]) {
    testWidgets('lays out on a small phone in ${locale.languageCode}', (
      tester,
    ) async {
      await openSheet(tester, karakTea, locale: locale);
      expect(tester.takeException(), isNull);
    });
  }
}
