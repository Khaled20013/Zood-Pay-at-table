import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zood_pay_at_table/AppRoutes/GoRouterApp.dart';
import 'package:zood_pay_at_table/Bloc/AppCubit.dart';
import 'package:zood_pay_at_table/Bloc/LanguageCubit.dart';
import 'package:zood_pay_at_table/Helper/L10n.dart';
import 'package:zood_pay_at_table/Styles/AppTheme.dart';
import 'package:zood_pay_at_table/main.dart';

/// Pumps the real router (as [routerMain]) and app-wide cubits, without
/// the deep-link plugin [MyApp] starts.
Future<void> pumpTestApp(
  WidgetTester tester, {
  required String initialLocation,
  AppCubit? appCubit,
  LanguageCubit? languageCubit,
  Locale locale = const Locale('en'),
}) async {
  routerMain = GoRouterApp.router(initialLocation: initialLocation);
  addTearDown(routerMain.dispose);
  final app = appCubit ?? AppCubit();
  final language =
      languageCubit ?? LanguageCubit(deviceLocale: const Locale('en'));
  if (appCubit == null) addTearDown(app.close);
  if (languageCubit == null) addTearDown(language.close);

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: app),
        BlocProvider.value(value: language),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light(),
        locale: locale,
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

/// Wraps [child] in a localized [MaterialApp] with the app-wide cubits.
Widget testShell({
  required Widget child,
  AppCubit? appCubit,
  Locale locale = const Locale('en'),
}) {
  final app = MaterialApp(
    theme: AppTheme.light(),
    locale: locale,
    supportedLocales: S.supportedLocales,
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: child,
  );
  return appCubit == null
      ? app
      : BlocProvider.value(value: appCubit, child: app);
}
