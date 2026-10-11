import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zood_pay_at_table/core/localization/l10n.dart';
import 'package:zood_pay_at_table/core/localization/locale_cubit.dart';
import 'package:zood_pay_at_table/core/routing/app_router.dart';
import 'package:zood_pay_at_table/features/onboarding/presentation/screens/landing_screen.dart';
import 'package:zood_pay_at_table/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:zood_pay_at_table/features/onboarding/presentation/screens/welcome_screen.dart';

void main() {
  late LocaleCubit localeCubit;
  late GoRouter router;

  setUp(() {
    localeCubit = LocaleCubit(deviceLocale: const Locale('en'));
    router = AppRouter.create(initialLocation: AppRoutes.splash);
  });

  tearDown(() {
    router.dispose();
    localeCubit.close();
  });

  Future<void> pumpApp(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
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
      BlocProvider.value(
        value: localeCubit,
        child: MaterialApp.router(
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: router,
        ),
      ),
    );
  }

  testWidgets('splash plays, then hands off to the landing page', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));
    expect(find.byType(LandingScreen), findsNothing);

    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(LandingScreen), findsOneWidget);
  });

  testWidgets('a deep link during the splash wins over the landing page', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.pump(const Duration(milliseconds: 500));
    router.go(AppRoutes.welcome);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(LandingScreen), findsNothing);
  });

  testWidgets('reduced motion skips straight to a short hold', (tester) async {
    await pumpApp(tester, disableAnimations: true);
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byType(LandingScreen), findsOneWidget);
  });

  for (final (locale, startLabel) in const [
    (Locale('en'), 'Start ordering'),
    (Locale('ar'), 'ابدأ الطلب'),
  ]) {
    testWidgets('landing lays out on a small phone in ${locale.languageCode}', (
      tester,
    ) async {
      router.dispose();
      router = AppRouter.create(initialLocation: AppRoutes.landing);
      await pumpApp(tester, locale: locale);
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);

      await tester.tap(find.text(startLabel));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
    });
  }
}
