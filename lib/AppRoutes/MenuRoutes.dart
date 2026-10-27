import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../Screens/Menu/MenuScreen/View/MenuScreen.dart';
import 'GoRouterApp.dart';

class MenuRoutes {
  static List<RouteBase> routes() {
    List<RouteBase> lst = [];

    lst.add(openMenuScreen(settings: const RouteSettings()));

    return lst;
  }

  //// Menu Screen Routes
  /// `/pay-at-table/<qr_id>/menu`. [replacement] resets the stack to the
  /// table route + menu (e.g. after paying or from the empty checkout).
  static dynamic openMenuScreen({
    RouteSettings? settings,
    String? qrId,
    bool replacement = false,
  }) {
    if (settings != null) {
      return GoRoute(
          name: MenuScreen.routeName,
          path: MenuScreen.path,
          builder: (_, state) =>
              MenuScreen(qrId: state.pathParameters['qrId']!));
    } else {
      return GoRouterApp.navigateTo(
          route: MenuScreen.routeName,
          replacement: replacement,
          pathParameters: {'qrId': qrId!});
    }
  }
}
