import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../localization/l10n.dart';
import 'app_router.dart';
import '../widgets/status_view.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StatusView(
        icon: Icons.link_off_rounded,
        title: context.l10n.notFoundTitle,
        message: context.l10n.notFoundMessage,
        actionLabel: context.l10n.notFoundAction,
        onAction: () => context.go(AppRoutes.landing),
      ),
    );
  }
}
