import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zood_pay_at_table/core/localization/l10n.dart';
import 'package:zood_pay_at_table/features/checkout/domain/entities/order_receipt.dart';
import 'package:zood_pay_at_table/features/checkout/presentation/screens/order_success_screen.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  final receipt = OrderReceipt(
    orderId: 'ord_1',
    orderNumber: '482',
    reference: '#R000482',
    subtotal: 36,
    taxes: 5.4,
    total: 41.4,
    currency: 'SAR',
    branchName: 'Olaya',
    tableName: 'T5',
    paidAt: DateTime(2026, 10, 11, 0, 30),
    cardLast4: '1111',
  );

  Future<void> pumpScreen(
    WidgetTester tester, {
    required Locale locale,
    bool disableAnimations = false,
  }) async {
    tester.view
      ..physicalSize = const Size(360, 740)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: disableAnimations);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: OrderSuccessScreen(qrId: demoQrId, receipt: receipt),
      ),
    );
  }

  for (final (locale, title, kitchen) in const [
    (Locale('en'), 'Order placed', 'Preparing in the kitchen'),
    (Locale('ar'), 'تم استلام طلبك', 'قيد التحضير في المطبخ'),
  ]) {
    testWidgets('plays and lays out on a small phone in '
        '${locale.languageCode}', (tester) async {
      await pumpScreen(tester, locale: locale);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 2200));

      expect(tester.takeException(), isNull);
      expect(find.text(title), findsOneWidget);
      expect(find.text(kitchen), findsOneWidget);
      expect(find.text('#482'), findsOneWidget);
      expect(find.text('T5'), findsOneWidget);
      expect(find.text('#R000482'), findsOneWidget);
    });
  }

  testWidgets('reduced motion shows the final state on the first frame', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      locale: const Locale('en'),
      disableAnimations: true,
    );
    await tester.pump();

    final title = tester.widget<FadeTransition>(
      find
          .ancestor(
            of: find.text('Order placed'),
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(title.opacity.value, 1);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
