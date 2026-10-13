import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zood_pay_at_table/core/config/app_config.dart';
import 'package:zood_pay_at_table/core/localization/l10n.dart';
import 'package:zood_pay_at_table/core/localization/locale_cubit.dart';
import 'package:zood_pay_at_table/core/network/demo_data_policy.dart';
import 'package:zood_pay_at_table/core/routing/app_router.dart';
import 'package:zood_pay_at_table/core/theme/app_theme.dart';
import 'package:zood_pay_at_table/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:zood_pay_at_table/features/menu/presentation/cubit/menu_cubit.dart';
import 'package:zood_pay_at_table/features/menu/presentation/widgets/category_bar.dart';
import 'package:zood_pay_at_table/features/table_session/presentation/cubit/table_session_cubit.dart';
import 'package:zood_pay_at_table/injection_container.dart';

void main() {
  setUp(() async {
    await sl.reset();
    SharedPreferences.setMockInitialValues({});
    configureDependencies(prefs: await SharedPreferences.getInstance());
    sl
      ..unregister<DemoDataPolicy>()
      ..registerLazySingleton<DemoDataPolicy>(
        () => const DemoDataPolicy(useDummyData: true),
      );
  });

  tearDown(() => sl.reset());

  Future<void> pumpMenu(WidgetTester tester) async {
    // Wider than a phone: the test font is much wider than Cairo.
    tester.view
      ..physicalSize = const Size(500 * 2, 844 * 2)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: sl<LocaleCubit>()),
          BlocProvider.value(value: sl<TableSessionCubit>()),
          BlocProvider.value(value: sl<MenuCubit>()),
          BlocProvider.value(value: sl<CartCubit>()),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: AppRouter.create(
            initialLocation: AppRoutes.menu(AppConfig.demoQrId),
          ),
        ),
      ),
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
