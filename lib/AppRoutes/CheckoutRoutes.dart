import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../Models/Checkout/OrderReceiptModel.dart';
import '../Screens/Checkout/CartSummaryScreen/View/CartSummaryScreen.dart';
import '../Screens/Checkout/OrderSuccessScreen/View/OrderSuccessScreen.dart';
import '../Screens/Menu/MenuScreen/View/MenuScreen.dart';
import 'GoRouterApp.dart';

class CheckoutRoutes {
  static List<RouteBase> routes() {
    List<RouteBase> lst = [];

    lst.add(openCartSummaryScreen(settings: const RouteSettings()));
    lst.add(openOrderSuccessScreen(settings: const RouteSettings()));

    return lst;
  }

  /// `/pay-at-table/<qr_id>/cart`
  static dynamic openCartSummaryScreen({RouteSettings? settings, String? qrId}) {
    if (settings != null) {
      return GoRoute(
          name: CartSummaryScreen.routeName,
          path: CartSummaryScreen.path,
          builder: (_, state) =>
              CartSummaryScreen(qrId: state.pathParameters['qrId']!));
    } else {
      return GoRouterApp.navigateTo(
          route: CartSummaryScreen.routeName,
          replacement: false,
          pathParameters: {'qrId': qrId!});
    }
  }

  /// `/pay-at-table/<qr_id>/success`. Without a receipt (e.g. a reload on
  /// the web) it falls back to the menu.
  static dynamic openOrderSuccessScreen({
    RouteSettings? settings,
    String? qrId,
    OrderReceiptModel? receipt,
  }) {
    if (settings != null) {
      return GoRoute(
        name: OrderSuccessScreen.routeName,
        path: OrderSuccessScreen.path,
        redirect: (context, state) => _receiptOf(state) != null
            ? null
            : state.namedLocation(
                MenuScreen.routeName,
                pathParameters: {'qrId': state.pathParameters['qrId']!},
              ),
        pageBuilder: (context, state) => CustomTransitionPage(
          child: OrderSuccessScreen(
            qrId: state.pathParameters['qrId']!,
            receipt: _receiptOf(state)!,
          ),
          transitionsBuilder: (context, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    } else {
      return GoRouterApp.navigateTo(
          route: OrderSuccessScreen.routeName,
          replacement: true,
          pathParameters: {'qrId': qrId!},
          arg: {'receipt': receipt});
    }
  }

  static OrderReceiptModel? _receiptOf(GoRouterState state) {
    final extra = state.extra;
    return extra is Map ? extra['receipt'] as OrderReceiptModel? : null;
  }
}
