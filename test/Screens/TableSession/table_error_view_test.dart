import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zood_pay_at_table/Bloc/AppCubit.dart';
import 'package:zood_pay_at_table/Helper/Errors/AppException.dart';
import 'package:zood_pay_at_table/Helper/L10n.dart';
import 'package:zood_pay_at_table/Screens/Onboarding/WelcomeScreen/View/WelcomeScreen.dart';
import 'package:zood_pay_at_table/Screens/TableSession/QrScanScreen/View/QrScanScreen.dart';
import 'package:zood_pay_at_table/main.dart';
import 'package:zood_pay_at_table/Screens/TableSession/Widgets/TableSessionGate.dart';

void main() {
  Future<void> pump(WidgetTester tester, AppException error) {
    final appCubit = AppCubit();
    addTearDown(appCubit.close);
    routerMain = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(body: TableErrorView(error: error)),
        ),
        GoRoute(
          name: QrScanScreen.routeName,
          path: QrScanScreen.path,
          builder: (_, _) => const Text('scanner'),
        ),
        GoRoute(
          name: WelcomeScreen.routeName,
          path: WelcomeScreen.path,
          builder: (_, _) => const Text('welcome'),
        ),
      ],
    );
    addTearDown(routerMain.dispose);
    return tester.pumpWidget(
      BlocProvider.value(
        value: appCubit,
        child: MaterialApp.router(
          locale: const Locale('en'),
          supportedLocales: S.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: routerMain,
        ),
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

  testWidgets('any table error can go back to enter another link', (
    tester,
  ) async {
    await pump(tester, const ServiceUnavailableException());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Use another table link'));
    await tester.pumpAndSettle();
    expect(find.text('welcome'), findsOneWidget);
  });

  testWidgets('service unavailable keeps try again as the primary action', (
    tester,
  ) async {
    await pump(tester, const ServiceUnavailableException());
    await tester.pumpAndSettle();

    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Use another table link'), findsOneWidget);
  });
}
