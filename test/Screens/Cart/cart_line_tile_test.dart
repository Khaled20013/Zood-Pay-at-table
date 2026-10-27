import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zood_pay_at_table/Bloc/AppCubit.dart';
import 'package:zood_pay_at_table/Bloc/states.dart';
import 'package:zood_pay_at_table/Helper/L10n.dart';
import 'package:zood_pay_at_table/Screens/Cart/Widgets/CartBottomSheet.dart';

import '../../helpers/fixtures.dart';

void main() {
  late AppCubit cart;

  setUp(() {
    cart = AppCubit()
      ..bindCart(demoQrId)
      ..addProduct(karakTea);
  });

  tearDown(() => cart.close());

  Future<void> pumpTile(WidgetTester tester, {Locale? locale}) {
    return tester.pumpWidget(
      BlocProvider.value(
        value: cart,
        child: MaterialApp(
          locale: locale ?? const Locale('en'),
          supportedLocales: S.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: BlocBuilder<AppCubit, AppStates>(
              builder: (context, _) => CartLineTile(
                item: AppCubit.get(context).cart.items.single,
                currency: 'SAR',
              ),
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
    expect(cart.cart.items.single.notes, 'No sugar please');
    expect(find.text('No sugar please'), findsOneWidget);
  });

  testWidgets('cancel keeps the existing note', (tester) async {
    cart.updateCartLineNotes(cart.cart.items.single.id, 'Extra hot');
    await pumpTile(tester);

    await tester.tap(find.text('Extra hot'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'changed');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(cart.cart.items.single.notes, 'Extra hot');
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
    expect(cart.cart.items.single.notes, 'بدون سكر');
  });
}
