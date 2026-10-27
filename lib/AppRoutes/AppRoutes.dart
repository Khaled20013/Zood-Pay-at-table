import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../Screens/Onboarding/LandingScreen/View/LandingScreen.dart';
import '../Screens/Splash/View/SplashScreen.dart';
import 'GoRouterApp.dart';

class AppRoutes {
  /// Feature routes stay top level (not children of the landing page) so
  /// `/pay-at-table/...` links don't stack the landing page underneath.
  static List<RouteBase> routes(List<RouteBase>? subList) {
    List<RouteBase> lst = [];
    subList ??= [];

    lst.add(openSplashScreen(settings: const RouteSettings()));
    lst.add(openLandingScreen(settings: const RouteSettings()));
    lst.addAll(subList);

    return lst;
  }


//// Splash Screen Routes
  static dynamic openSplashScreen({RouteSettings? settings}) {
    if (settings != null) {
      return GoRoute(
          name: SplashScreen.routeName,
          path: SplashScreen.routeName,
          builder: (_, _) => const SplashScreen());
    } else {
      return GoRouterApp.navigateTo(
          route: SplashScreen.routeName, replacement: true);
    }
  }


//// Landing Screen Routes
  static dynamic openLandingScreen({RouteSettings? settings}) {
    if (settings != null) {
      return GoRoute(
        name: LandingScreen.routeName,
        path: LandingScreen.path,
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
      );
    } else {
      return GoRouterApp.navigateTo(
          route: LandingScreen.routeName, replacement: true);
    }
  }
}
