import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../Screens/TableSession/QrScanScreen/View/QrScanScreen.dart';
import '../Screens/TableSession/TableScanScreen/View/TableScanScreen.dart';
import 'GoRouterApp.dart';

class TableSessionRoutes {
  /// [tableRoutes] are nested under `/pay-at-table/:qrId`.
  static List<RouteBase> routes(List<RouteBase> tableRoutes) {
    List<RouteBase> lst = [];

    lst.add(openQrScanScreen(settings: const RouteSettings()));
    lst.add(openTableScanScreen(
        settings: const RouteSettings(), subList: tableRoutes));

    return lst;
  }

  static dynamic openQrScanScreen({
    RouteSettings? settings,
    bool replacement = false,
  }) {
    if (settings != null) {
      return GoRoute(
          name: QrScanScreen.routeName,
          path: QrScanScreen.path,
          builder: (_, _) => const QrScanScreen());
    } else {
      return GoRouterApp.navigateTo(
          route: QrScanScreen.routeName, replacement: replacement);
    }
  }

  /// The printed QR is `https://control.zood.ai/pay-at-table/<qr_id>/menu`.
  static dynamic openTableScanScreen({
    RouteSettings? settings,
    List<RouteBase>? subList,
    String? qrId,
  }) {
    if (settings != null) {
      return GoRoute(
          name: TableScanScreen.routeName,
          path: TableScanScreen.path,
          routes: subList ?? [],
          builder: (_, state) =>
              TableScanScreen(qrId: state.pathParameters['qrId']!));
    } else {
      return GoRouterApp.navigateTo(
          route: TableScanScreen.routeName,
          replacement: true,
          pathParameters: {'qrId': qrId!});
    }
  }
}
