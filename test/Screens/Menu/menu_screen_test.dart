import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zood_pay_at_table/Helper/Configs/AppConfig.dart';
import 'package:zood_pay_at_table/Screens/Menu/Widgets/CategoryBar.dart';

import '../../helpers/mock_http.dart';
import '../../helpers/test_app.dart';

void main() {
  setUp(useDummyData);

  Future<void> pumpMenu(WidgetTester tester) async {
    // Wider than a phone: the test font is much wider than Cairo.
    tester.view
      ..physicalSize = const Size(500 * 2, 844 * 2)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await pumpTestApp(
      tester,
      initialLocation: '/pay-at-table/${AppConfig.demoQrId}/menu',
    );
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  CategoryBar bar(WidgetTester tester) =>
      tester.widget<CategoryBar>(find.byType(CategoryBar));

  testWidgets('tapping the last category keeps it selected', (tester) async {
    await pumpMenu(tester);
    final last = bar(tester).categories.last;

    bar(tester).onSelected(last);
    await tester.pumpAndSettle();

    expect(bar(tester).selected, last);

    // Scrolling by hand hands the highlight back to the scroll position.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 3000));
    await tester.pumpAndSettle();
    expect(bar(tester).selected, bar(tester).categories.first);
  });
}
