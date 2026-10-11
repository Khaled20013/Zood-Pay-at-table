import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/config/app_config.dart';
import 'core/localization/l10n.dart';
import 'core/localization/locale_cubit.dart';
import 'core/routing/app_router.dart';
import 'core/routing/deep_link_service.dart';
import 'core/theme/app_theme.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/menu/presentation/cubit/menu_cubit.dart';
import 'features/table_session/presentation/cubit/table_session_cubit.dart';
import 'injection_container.dart';

class ZoodPayAtTableApp extends StatefulWidget {
  const ZoodPayAtTableApp({super.key});

  @override
  State<ZoodPayAtTableApp> createState() => _ZoodPayAtTableAppState();
}

class _ZoodPayAtTableAppState extends State<ZoodPayAtTableApp> {
  late final GoRouter _router = AppRouter.create(
    initialLocation: AppConfig.initialLocation.isEmpty
        ? AppRoutes.splash
        : AppConfig.initialLocation,
  );
  late final DeepLinkService _deepLinks;

  @override
  void initState() {
    super.initState();
    _deepLinks = DeepLinkService(_router)..start();
  }

  @override
  void dispose() {
    _deepLinks.dispose();
    _router.dispose();
    super.dispose();
  }

  /// Names, descriptions and categories come localized from the POS, so the
  /// open session, menu and cart lines are re-fetched in the new language.
  Future<void> _onLocaleChanged(BuildContext context) async {
    final sessionCubit = context.read<TableSessionCubit>();
    final menuCubit = context.read<MenuCubit>();
    final cartCubit = context.read<CartCubit>();

    await sessionCubit.refresh();
    final session = sessionCubit.state.session;
    if (session == null || menuCubit.state.status == MenuStatus.initial) {
      return;
    }
    final products = await menuCubit.refresh(session);
    if (products != null) cartCubit.syncProducts(products);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<LocaleCubit>()),
        BlocProvider.value(value: sl<TableSessionCubit>()),
        BlocProvider.value(value: sl<MenuCubit>()),
        BlocProvider.value(value: sl<CartCubit>()),
      ],
      child: BlocConsumer<LocaleCubit, Locale>(
        listener: (context, _) => _onLocaleChanged(context),
        builder: (context, locale) => MaterialApp.router(
          onGenerateTitle: (context) => context.l10n.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          locale: locale,
          supportedLocales: LocaleCubit.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: _router,
        ),
      ),
    );
  }
}
