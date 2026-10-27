import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AppRoutes/Base/DeepLinkService.dart';
import 'AppRoutes/GoRouterApp.dart';
import 'Bloc/AppCubit.dart';
import 'Bloc/LanguageCubit.dart';
import 'Bloc/observer_bloc.dart';
import 'Helper/Configs/kcore.dart';
import 'Helper/L10n.dart';
import 'Helper/connection/cash/CashLocal.dart';
import 'Styles/AppTheme.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// The app's single router. Tests may replace it before pumping [MyApp].
GoRouter routerMain = GoRouterApp.router();

Future<void> main() async {
  // QR links are plain paths (`/pay-at-table/<qr_id>/menu`), not `#/` hashes.
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) Bloc.observer = MyBlocObserver();

  final prefs = await CashLocal.init();
  await initConfig();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.prefs, this.appCubit, this.languageCubit});

  final SharedPreferences? prefs;

  /// Injected by tests; created here otherwise.
  final AppCubit? appCubit;
  final LanguageCubit? languageCubit;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final DeepLinkService _deepLinks;

  @override
  void initState() {
    super.initState();
    _deepLinks = DeepLinkService(routerMain)..start();
  }

  @override
  void dispose() {
    _deepLinks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appCubit = widget.appCubit;
    final languageCubit = widget.languageCubit;
    return MultiBlocProvider(
      providers: [
        appCubit != null
            ? BlocProvider.value(value: appCubit)
            : BlocProvider(create: (_) => AppCubit()),
        languageCubit != null
            ? BlocProvider.value(value: languageCubit)
            : BlocProvider(
                create: (_) => LanguageCubit(prefs: widget.prefs),
              ),
      ],
      child: BlocConsumer<LanguageCubit, Locale>(
        listener: (context, _) => AppCubit.get(context).onLanguageChanged(),
        builder: (context, locale) => MaterialApp.router(
          onGenerateTitle: (context) => S.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          locale: locale,
          supportedLocales: LanguageCubit.supportedLocales,
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
}
