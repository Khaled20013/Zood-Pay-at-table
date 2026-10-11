import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/presentation/screens/landing_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/checkout/domain/entities/order_receipt.dart';
import '../../features/checkout/presentation/screens/cart_summary_screen.dart';
import '../../features/menu/presentation/screens/menu_screen.dart';
import 'not_found_screen.dart';
import '../../features/checkout/presentation/screens/order_success_screen.dart';
import '../../features/table_session/presentation/screens/table_scan_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';

abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String landing = '/';
  static const String welcome = '/start';

  /// The printed QR is `https://control.zood.ai/pay-at-table/<qr_id>/menu`.
  static const String tablePattern = '/pay-at-table/:qrId';

  static String table(String qrId) => '/pay-at-table/$qrId';
  static String menu(String qrId) => '${table(qrId)}/menu';
  static String cart(String qrId) => '${table(qrId)}/cart';
  static String success(String qrId) => '${table(qrId)}/success';
}

abstract final class AppRouter {
  static GoRouter create({String? initialLocation}) {
    return GoRouter(
      initialLocation: initialLocation,
      debugLogDiagnostics: false,
      errorBuilder: (context, state) => const NotFoundScreen(),
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.landing,
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            transitionDuration: const Duration(milliseconds: 600),
            child: const LandingScreen(),
            transitionsBuilder: (context, animation, _, child) =>
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  ),
                  child: child,
                ),
          ),
        ),
        GoRoute(
          path: AppRoutes.welcome,
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.tablePattern,
          builder: (context, state) =>
              TableScanScreen(qrId: state.pathParameters['qrId']!),
          routes: [
            GoRoute(
              path: 'menu',
              builder: (context, state) =>
                  MenuScreen(qrId: state.pathParameters['qrId']!),
            ),
            GoRoute(
              path: 'cart',
              builder: (context, state) =>
                  CartSummaryScreen(qrId: state.pathParameters['qrId']!),
            ),
            GoRoute(
              path: 'success',
              redirect: (context, state) => state.extra is OrderReceipt
                  ? null
                  : AppRoutes.menu(state.pathParameters['qrId']!),
              pageBuilder: (context, state) => CustomTransitionPage(
                child: OrderSuccessScreen(
                  qrId: state.pathParameters['qrId']!,
                  receipt: state.extra! as OrderReceipt,
                ),
                transitionsBuilder: (context, animation, _, child) =>
                    FadeTransition(opacity: animation, child: child),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
