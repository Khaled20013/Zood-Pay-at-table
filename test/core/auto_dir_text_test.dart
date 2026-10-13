import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zood_pay_at_table/core/widgets/auto_dir_text.dart';

void main() {
  test('direction follows the first strong character', () {
    expect(contentDirectionOf('Karak Tea.'), TextDirection.ltr);
    expect(contentDirectionOf('شاي كرك'), TextDirection.rtl);
    expect(contentDirectionOf('330 ml water'), TextDirection.ltr);
    expect(contentDirectionOf('123 - 45'), isNull);
  });

  testWidgets('English in an Arabic screen: LTR text, right aligned', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.rtl,
        child: AutoDirText('Saudi Coffee Pot. Serves 2–3.'),
      ),
    );
    final text = tester.widget<Text>(find.byType(Text));
    expect(text.textDirection, TextDirection.ltr);
    expect(text.textAlign, TextAlign.right);
  });

  testWidgets('marks every match of the search query', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AutoDirText('Iced latte, hot LATTE', highlight: 'latte'),
      ),
    );
    final span = tester.widget<Text>(find.byType(Text)).textSpan! as TextSpan;
    final marked = span.children!
        .whereType<TextSpan>()
        .where((s) => s.style?.backgroundColor != null)
        .map((s) => s.text)
        .toList();
    expect(marked, ['latte', 'LATTE']);
    expect(find.text('Iced latte, hot LATTE'), findsOneWidget);
  });
}
