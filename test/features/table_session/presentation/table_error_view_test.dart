import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zood_pay_at_table/core/error/app_exception.dart';
import 'package:zood_pay_at_table/core/localization/l10n.dart';
import 'package:zood_pay_at_table/core/routing/app_router.dart';
import 'package:zood_pay_at_table/features/table_session/presentation/widgets/table_session_gate.dart';

void main() {
  Future<void> pump(WidgetTester tester, AppException error) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(body: TableErrorView(error: error)),
        ),
        GoRoute(
          path: AppRoutes.scan,
          builder: (_, _) => const Text('scanner'),
        ),
      ],
    );
    return tester.pumpWidget(
      MaterialApp.router(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: router,
      ),
    );
  }

  testWidgets('a QR that does not exist offers scanning again', (
    tester,
  ) async {
    await pump(tester, const QrNotFoundException());
    await tester.pumpAndSettle();

    expect(find.text('Try again'), findsNothing);
    await tester.tap(find.text('Scan again'));
    await tester.pumpAndSettle();
    expect(find.text('scanner'), findsOneWidget);
  });

  testWidgets('a network error still offers retry', (tester) async {
    await pump(tester, const NetworkException());
    await tester.pumpAndSettle();

    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Scan again'), findsNothing);
  });
}
