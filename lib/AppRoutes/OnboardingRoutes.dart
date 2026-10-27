import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../Screens/Onboarding/WelcomeScreen/View/WelcomeScreen.dart';
import 'GoRouterApp.dart';

class OnboardingRoutes {
  static List<RouteBase> routes() {
    List<RouteBase> lst = [];

    lst.add(openWelcomeScreen(settings: const RouteSettings()));

    return lst;
  }

  static dynamic openWelcomeScreen({
    RouteSettings? settings,
    bool replacement = false,
  }) {
    if (settings != null) {
      return GoRoute(
          name: WelcomeScreen.routeName,
          path: WelcomeScreen.path,
          builder: (_, _) => const WelcomeScreen());
    } else {
      return GoRouterApp.navigateTo(
          route: WelcomeScreen.routeName, replacement: replacement);
    }
  }
}
