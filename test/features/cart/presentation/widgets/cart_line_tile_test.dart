import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zood_pay_at_table/core/localization/l10n.dart';
import 'package:zood_pay_at_table/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:zood_pay_at_table/features/cart/presentation/widgets/cart_bottom_sheet.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  late CartCubit cart;

  setUp(() {
    cart = CartCubit()
      ..bindSession(demoQrId)
      ..addProduct(karakTea);
  });

  tearDown(() => cart.close());

  Future<void> pumpTile(WidgetTester tester, {Locale? locale}) {
    return tester.pumpWidget(
      BlocProvider.value(
        value: cart,
        child: MaterialApp(
          locale: locale ?? const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: BlocBuilder<CartCubit, CartState>(
              builder: (context, state) =>
                  CartLineTile(item: state.items.single, currency: 'SAR'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('saving a note closes the dialog and updates the line', (
    tester,
  ) async {
    await pumpTile(tester);

    await tester.tap(find.text('Add note'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  No sugar please ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(AlertDialog), findsNothing);
    expect(cart.state.items.single.notes, 'No sugar please');
    expect(find.text('No sugar please'), findsOneWidget);
  });

  testWidgets('cancel keeps the existing note', (tester) async {
    cart.updateNotes(cart.state.items.single.id, 'Extra hot');
    await pumpTile(tester);

    await tester.tap(find.text('Extra hot'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'changed');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(cart.state.items.single.notes, 'Extra hot');
  });

  testWidgets('note dialog works in Arabic, right-to-left', (tester) async {
    await pumpTile(tester, locale: const Locale('ar'));

    await tester.tap(find.text('أضف ملاحظة'));
    await tester.pumpAndSettle();
    expect(
      Directionality.of(tester.element(find.byType(TextField))),
      TextDirection.rtl,
    );
    await tester.enterText(find.byType(TextField), 'بدون سكر');
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(cart.state.items.single.notes, 'بدون سكر');
  });
}
