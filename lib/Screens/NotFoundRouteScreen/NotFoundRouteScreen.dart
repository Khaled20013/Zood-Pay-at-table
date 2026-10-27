import 'package:flutter/material.dart';

import '../../AppRoutes/AppRoutes.dart';
import '../../Helper/L10n.dart';
import '../../Widgets/StatusView.dart';

class NotFoundRouteScreen extends StatelessWidget {
  const NotFoundRouteScreen({super.key});

  static const String routeName = "/NotFoundRouteScreen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StatusView(
        icon: Icons.link_off_rounded,
        title: S.of(context).notFoundTitle,
        message: S.of(context).notFoundMessage,
        actionLabel: S.of(context).notFoundAction,
        onAction: () => AppRoutes.openLandingScreen(),
      ),
    );
  }
}
