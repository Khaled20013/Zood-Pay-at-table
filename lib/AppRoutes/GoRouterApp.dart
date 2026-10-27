import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../Helper/Configs/AppConfig.dart';
import '../Screens/NotFoundRouteScreen/NotFoundRouteScreen.dart';
import '../Screens/Splash/View/SplashScreen.dart';
import '../main.dart';
import 'AppRoutes.dart';
import 'CheckoutRoutes.dart';
import 'MenuRoutes.dart';
import 'OnboardingRoutes.dart';
import 'TableSessionRoutes.dart';

class GoRouterApp {
  static GoRouter router({String? initialLocation}) {
    List<RouteBase> lst = [];
    List<RouteBase> subList = [];

    // Menu and checkout live under `/pay-at-table/:qrId`, the printed QR link.
    List<RouteBase> tableRoutes = [];
    tableRoutes.addAll(MenuRoutes.routes());
    tableRoutes.addAll(CheckoutRoutes.routes());

    subList.addAll(OnboardingRoutes.routes());
    subList.addAll(TableSessionRoutes.routes(tableRoutes));

    lst.addAll(AppRoutes.routes(subList));

    GoRouter rot = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: initialLocation ??
          (AppConfig.initialLocation.isEmpty
              ? SplashScreen.routeName
              : AppConfig.initialLocation),
      observers: [routeObserver],
      routes: lst,
      errorBuilder: (context, state) => const NotFoundRouteScreen(),
    );
    return rot;
  }

  static Object? queryParameters(
      {required BuildContext context, required GoRouterState state}) {
    var parm = state.uri;
    if (parm.path.contains("share/")) {
      return parm.query;
    }

    Object? extra = state.extra;
    if (extra != null) {
      return extra;
    }

    return null;
  }

  static void navigateTo(
      {required String route,
      bool replacement = false,
      Map<String, String> pathParameters = const {},
      Object? arg}) {
    log("route : $route");
    if (replacement) {
      routerMain.goNamed(route, pathParameters: pathParameters, extra: arg);
    } else {
      routerMain.pushNamed(route, pathParameters: pathParameters, extra: arg);
    }
  }

  /// Opens a location that came from outside the app (a scanned QR, a pasted
  /// table link, an App Link), e.g. `/pay-at-table/<qr_id>/menu`.
  static void openLocation(String location) {
    log("location : $location");
    routerMain.go(location);
  }

  static bool canPop() => routerMain.canPop();

  static void pop<T extends Object?>([T? result]) => routerMain.pop(result);
}
