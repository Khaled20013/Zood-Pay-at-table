import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/status_view.dart';
import '../../domain/entities/table_session.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../cubit/table_session_cubit.dart';

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
  final Widget Function(BuildContext context, TableSession session) builder;

  @override
  State<TableSessionGate> createState() => _TableSessionGateState();
}

class _TableSessionGateState extends State<TableSessionGate> {
  @override
  void initState() {
    super.initState();
    final sessions = context.read<TableSessionCubit>()..resolve(widget.qrId);
    final session = sessions.state.session;
    if (session != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<CartCubit>().bindSession(session.qrId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TableSessionCubit, TableSessionState>(
      listenWhen: (a, b) => a.session != b.session && b.session != null,
      listener: (context, state) =>
          context.read<CartCubit>().bindSession(state.session!.qrId),
      builder: (context, state) {
        final session = state.session;
        if (state.isLoaded && session != null) {
          return widget.builder(context, session);
        }
        if (state.status == TableSessionStatus.failure) {
          return Scaffold(body: TableErrorView(error: state.error));
        }
        return Scaffold(
          body: LoadingIndicator(message: context.l10n.findingTable),
        );
      },
    );
  }
}

/// `404` / `410` QRs show their message with no retry; anything else
/// offers **Try again**.
class TableErrorView extends StatelessWidget {
  const TableErrorView({super.key, required this.error});

  final AppException? error;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canRetry = error?.canRetry ?? true;
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
      actionLabel: canRetry ? l10n.tryAgain : l10n.scanAgain,
      onAction: canRetry
          ? () => context.read<TableSessionCubit>().retry()
          : () => context.go(AppRoutes.scan),
    );
  }
}
