import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:zood_pay_at_table/AppRoutes/OnboardingRoutes.dart';
import 'package:zood_pay_at_table/AppRoutes/TableSessionRoutes.dart';
import 'package:zood_pay_at_table/Bloc/AppCubit.dart';
import 'package:zood_pay_at_table/Bloc/states.dart';
import 'package:zood_pay_at_table/Helper/Errors/AppException.dart';
import 'package:zood_pay_at_table/Helper/L10n.dart';
import 'package:zood_pay_at_table/Models/TableSession/TableSessionModel.dart';
import 'package:zood_pay_at_table/Widgets/StatusView.dart';
import 'FindingTableLoader.dart';

/// Ensures [qrId] is resolved before building [builder], so the QR link
/// (`/pay-at-table/<qr_id>/menu`) and deep links to `/cart` work without
/// passing through the table welcome screen first.
class TableSessionGate extends StatefulWidget {
  const TableSessionGate({
    super.key,
    required this.qrId,
    required this.builder,
  });

  final String qrId;
  final Widget Function(BuildContext context, TableSessionModel session)
  builder;

  @override
  State<TableSessionGate> createState() => _TableSessionGateState();
}

class _TableSessionGateState extends State<TableSessionGate> {
  @override
  void initState() {
    super.initState();
    AppCubit.get(context).resolveTable(widget.qrId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppStates>(
      buildWhen: (_, state) => state is TableSessionAppStates,
      builder: (context, _) {
        final app = AppCubit.get(context);
        final session = app.session;
        if (app.isSessionLoaded && session != null) {
          return widget.builder(context, session);
        }
        if (app.sessionStatus == TableSessionStatus.failure) {
          return Scaffold(body: TableErrorView(error: app.sessionError));
        }
        return const Scaffold(body: FindingTableLoader());
      },
    );
  }
}

/// `404` / `410` QRs show their message with no retry; anything else
/// offers **Try again**. Both always offer going back to enter another link
/// (on web that is the primary escape when the QR itself is invalid, since
/// the camera scanner is not the main path).
class TableErrorView extends StatelessWidget {
  const TableErrorView({super.key, required this.error});

  final AppException? error;

  void _startOver(BuildContext context) {
    AppCubit.get(context).clearTableSession();
    OnboardingRoutes.openWelcomeScreen(replacement: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final canRetry = error?.canRetry ?? true;
    // Invalid QR: web opens paste-link start; phone can rescan the camera.
    final openLinkAsPrimary = !canRetry && kIsWeb;
    return StatusView(
      isError: error is! ServiceUnavailableException,
      icon: switch (error) {
        ServiceUnavailableException() => Icons.construction_rounded,
        NetworkException() => Icons.wifi_off_rounded,
        _ when !canRetry => Icons.qr_code_2_rounded,
        _ => Icons.error_outline_rounded,
      },
      title: l10n.tableErrorTitle(error),
      message: l10n.tableErrorMessage(error),
      actionLabel: canRetry
          ? l10n.tryAgain
          : openLinkAsPrimary
              ? l10n.useAnotherTableLink
              : l10n.scanAgain,
      actionIcon: canRetry
          ? Icons.refresh_rounded
          : openLinkAsPrimary
              ? Icons.link_rounded
              : Icons.qr_code_scanner_rounded,
      onAction: canRetry
          ? () => AppCubit.get(context).retrySession()
          : openLinkAsPrimary
              ? () => _startOver(context)
              : () => TableSessionRoutes.openQrScanScreen(replacement: true),
      secondaryLabel: openLinkAsPrimary ? null : l10n.useAnotherTableLink,
      secondaryIcon: Icons.link_rounded,
      onSecondary: openLinkAsPrimary ? null : () => _startOver(context),
    );
  }
}
