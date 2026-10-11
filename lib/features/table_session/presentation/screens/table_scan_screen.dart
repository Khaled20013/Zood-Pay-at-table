import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/language_toggle.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/table_session.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../menu/presentation/cubit/menu_cubit.dart';
import '../cubit/table_session_cubit.dart';
import '../widgets/table_session_gate.dart';

/// `/pay-at-table/:qrId`: resolves the QR and welcomes the guest to their
/// table. The printed QR link opens `/menu` directly.
class TableScanScreen extends StatefulWidget {
  const TableScanScreen({super.key, required this.qrId});

  final String qrId;

  @override
  State<TableScanScreen> createState() => _TableScanScreenState();
}

class _TableScanScreenState extends State<TableScanScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TableSessionCubit>().resolve(widget.qrId);
  }

  @override
  void didUpdateWidget(covariant TableScanScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.qrId != widget.qrId) {
      context.read<TableSessionCubit>().resolve(widget.qrId);
    }
  }

  void _onSessionReady(BuildContext context, TableSession session) {
    context.read<CartCubit>().bindSession(session.qrId);
    // Warm the menu so it is ready by the time the guest taps through.
    context.read<MenuCubit>().load(session);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: BlocConsumer<TableSessionCubit, TableSessionState>(
          listenWhen: (a, b) => b.isLoaded && a.session != b.session,
          listener: (context, state) =>
              _onSessionReady(context, state.session!),
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              layoutBuilder: (current, previous) => Stack(
                fit: StackFit.expand,
                children: [...previous, ?current],
              ),
              child: switch (state.status) {
                TableSessionStatus.loaded => _WelcomeLayout(
                  key: const ValueKey('loaded'),
                  session: state.session!,
                  onStart: () => context.push(AppRoutes.menu(widget.qrId)),
                ),
                TableSessionStatus.failure => TableErrorView(
                  key: const ValueKey('failure'),
                  error: state.error,
                ),
                _ => const _ScanSkeleton(key: ValueKey('loading')),
              },
            );
          },
        ),
      ),
    );
  }
}

class _WelcomeLayout extends StatelessWidget {
  const _WelcomeLayout({
    super.key,
    required this.session,
    required this.onStart,
  });

  final TableSession session;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        if (wide) {
          return Row(
            children: [
              Expanded(child: _Hero(session: session, expanded: true)),
              SizedBox(
                width: 480,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: _ActionCard(session: session, onStart: onStart),
                  ),
                ),
              ),
            ],
          );
        }
        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                children: [
                  _Hero(session: session),
                  Transform.translate(
                    offset: const Offset(0, -36),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _ActionCard(session: session, onStart: onStart),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.session, this.expanded = false});

  final TableSession session;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      height: expanded ? double.infinity : null,
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: expanded
            ? null
            : const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          PositionedDirectional(
            end: -40,
            top: expanded ? null : -10,
            bottom: expanded ? -40 : null,
            child: Icon(
              Icons.qr_code_2_rounded,
              size: expanded ? 360 : 220,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                24,
                24,
                24,
                expanded ? 48 : 68,
              ),
              child: Column(
                mainAxisAlignment: expanded
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/zood_mark.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.appTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const LanguageToggle(onDark: true),
                    ],
                  ),
                  SizedBox(height: expanded ? 56 : 36),
                  Text(
                    l10n.welcomeTo,
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.branchName,
                    style: textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontSize: expanded ? 44 : 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _HeroChip(
                        icon: Icons.table_restaurant_rounded,
                        label: l10n.tableNumber(session.tableName),
                        highlighted: true,
                      ),
                      _HeroChip(
                        icon: Icons.circle,
                        iconColor: const Color(0xFF7CF0B8),
                        iconSize: 9,
                        label: l10n.sessionOpen,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.icon,
    required this.label,
    this.highlighted = false,
    this.iconColor,
    this.iconSize = 16,
  });

  final IconData icon;
  final String label;
  final bool highlighted;
  final Color? iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final fg = highlighted ? AppColors.primaryDark : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: highlighted
            ? Colors.white
            : Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: iconColor ?? fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: fg, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.session, required this.onStart});

  final TableSession session;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 30,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.scanCardTitle, style: textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(l10n.scanCardSubtitle, style: textTheme.bodyMedium),
          const SizedBox(height: 20),
          _Step(
            index: 1,
            icon: Icons.menu_book_rounded,
            title: l10n.stepBrowseTitle,
            subtitle: l10n.stepBrowseSubtitle,
          ),
          _Step(
            index: 2,
            icon: Icons.room_service_outlined,
            title: l10n.stepKitchenTitle,
            subtitle: l10n.stepKitchenSubtitle,
          ),
          _Step(
            index: 3,
            icon: Icons.verified_user_outlined,
            title: l10n.stepPayTitle,
            subtitle: l10n.stepPaySubtitle,
            isLast: true,
          ),
          const SizedBox(height: 20),
          CustomButton(
            label: l10n.viewMenuAndOrder,
            icon: Icons.restaurant_menu_rounded,
            onPressed: onStart,
          ),
          const SizedBox(height: 16),
          const _PaymentBadges(),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.index,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });

  final int index;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (soft, tint) = switch (index) {
      1 => (AppColors.primarySoft, AppColors.primary),
      2 => (AppColors.accentSoft, AppColors.accentDeep),
      _ => (const Color(0xFFE3ECFF), const Color(0xFF3A63D8)),
    };
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: soft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: tint, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(fontSize: 15),
                ),
                Text(subtitle, style: textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentBadges extends StatelessWidget {
  const _PaymentBadges();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: AppColors.inkMuted,
      fontWeight: FontWeight.w600,
    );
    Widget badge(String label, {IconData? icon}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColors.ink),
            const SizedBox(width: 3),
          ],
          Text(label, style: style),
        ],
      ),
    );

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 6,
        runSpacing: 6,
        children: [
          badge(context.l10n.paymentMethodMada),
          badge('VISA'),
          badge('Mastercard'),
        ],
      ),
    );
  }
}

class _ScanSkeleton extends StatelessWidget {
  const _ScanSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            children: [
              Container(
                constraints: const BoxConstraints(minHeight: 300),
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 70),
                        Opacity(
                          opacity: 0.35,
                          child: ShimmerScope(
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SkeletonBox(width: 90, height: 14),
                                SizedBox(height: 12),
                                SkeletonBox(width: 230, height: 30),
                                SizedBox(height: 18),
                                Row(
                                  children: [
                                    SkeletonBox(
                                      width: 90,
                                      height: 30,
                                      radius: 30,
                                    ),
                                    SizedBox(width: 8),
                                    SkeletonBox(
                                      width: 100,
                                      height: 30,
                                      radius: 30,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              context.l10n.findingTable,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ShimmerScope(
                  child: Container(
                    height: 320,
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBase,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
