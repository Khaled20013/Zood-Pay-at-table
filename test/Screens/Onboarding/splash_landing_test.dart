import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zood_pay_at_table/AppRoutes/OnboardingRoutes.dart';
import 'package:zood_pay_at_table/Screens/Onboarding/LandingScreen/View/LandingScreen.dart';
import 'package:zood_pay_at_table/Screens/Onboarding/WelcomeScreen/View/WelcomeScreen.dart';
import 'package:zood_pay_at_table/Screens/Splash/View/SplashScreen.dart';

import '../../helpers/test_app.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    String initialLocation = SplashScreen.routeName,
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

    await pumpTestApp(
      tester,
      initialLocation: initialLocation,
      locale: locale,
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
    OnboardingRoutes.openWelcomeScreen(replacement: true);
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
      await pumpApp(tester, initialLocation: LandingScreen.path, locale: locale);
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
