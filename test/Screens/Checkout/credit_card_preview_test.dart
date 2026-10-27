import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zood_pay_at_table/Helper/L10n.dart';
import 'package:zood_pay_at_table/Models/Checkout/CardBrand.dart';
import 'package:zood_pay_at_table/Screens/Checkout/Widgets/CardForm.dart';
import 'package:zood_pay_at_table/Screens/Checkout/Widgets/CreditCardPreview.dart';

void main() {
  group('CardBrand.of', () {
    test('detects the network from the leading digits', () {
      expect(CardBrand.of('4111111111111111'), CardBrand.visa);
      expect(CardBrand.of('5500000000000004'), CardBrand.mastercard);
      expect(CardBrand.of('2221000000000009'), CardBrand.mastercard);
      expect(CardBrand.of('378282246310005'), CardBrand.amex);
      expect(CardBrand.of('4406470000000000'), CardBrand.mada);
      expect(CardBrand.of('9'), CardBrand.unknown);
      expect(CardBrand.of(''), CardBrand.unknown);
    });
  });

  group('CreditCardPreview', () {
    late CardFormControllers controllers;

    setUp(() => controllers = CardFormControllers());
    tearDown(() => controllers.dispose());

    Future<void> pump(WidgetTester tester, {Locale? locale}) async {
      tester.view
        ..physicalSize = const Size(360, 700)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          locale: locale ?? const Locale('en'),
          supportedLocales: S.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CreditCardPreview(controllers: controllers),
                  const SizedBox(height: 16),
                  CardForm(controllers: controllers, enabled: true),
                ],
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('mirrors what the guest types', (tester) async {
      await pump(tester);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Card number'),
        '4111111111111111',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Name on card'),
        'ahmed ali',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Expiry'),
        '0828',
      );
      await tester.pumpAndSettle();

      Finder onCard(String text) => find.descendant(
        of: find.byType(CreditCardPreview),
        matching: find.text(text),
      );
      expect(onCard('AHMED ALI'), findsOneWidget);
      expect(onCard('08/28'), findsOneWidget);
      // Brand mark on the card and inside the number field.
      expect(find.text('VISA'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('flips to the back while the CVC is focused', (tester) async {
      await pump(tester);
      expect(find.text('CARD HOLDER'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextFormField, 'CVC'));
      await tester.enterText(find.widgetWithText(TextFormField, 'CVC'), '123');
      await tester.pumpAndSettle();
      expect(find.text('CARD HOLDER'), findsNothing);
      expect(find.byKey(const ValueKey('cvc-dots-3')), findsOneWidget);

      controllers.cvcFocus.unfocus();
      await tester.pumpAndSettle();
      expect(find.text('CARD HOLDER'), findsOneWidget);
    });

    testWidgets('lays out on a small phone in Arabic', (tester) async {
      await pump(tester, locale: const Locale('ar'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
