import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/animated_amount.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/status_view.dart';
import '../../../../injection_container.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/widgets/cart_bottom_sheet.dart';
import '../../../menu/presentation/cubit/menu_cubit.dart';
import '../../../table_session/domain/entities/table_session.dart';
import '../../../table_session/presentation/widgets/scan_table_button.dart';
import '../../../table_session/presentation/widgets/table_header.dart';
import '../../../table_session/presentation/widgets/table_session_gate.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../cubit/checkout_cubit.dart';
import '../widgets/card_form.dart';
import '../widgets/credit_card_preview.dart';

class CartSummaryScreen extends StatelessWidget {
  const CartSummaryScreen({super.key, required this.qrId});

  final String qrId;

  @override
  Widget build(BuildContext context) {
    return TableSessionGate(
      qrId: qrId,
      builder: (context, session) => BlocProvider(
        create: (_) => sl<CheckoutCubit>(),
        child: _CheckoutView(session: session),
      ),
    );
  }
}

class _CheckoutView extends StatefulWidget {
  const _CheckoutView({required this.session});

  final TableSession session;

  @override
  State<_CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<_CheckoutView> {
  final _formKey = GlobalKey<FormState>();
  final _card = CardFormControllers();
  final _notes = TextEditingController();

  TableSession get _session => widget.session;

  @override
  void initState() {
    super.initState();
    _card.fillDebugTestCard();
  }

  @override
  void dispose() {
    _card.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _backToMenu() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.menu(_session.qrId));
    }
  }

  void _pay(CartState cart) {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<CheckoutCubit>().pay(
      session: _session,
      items: cart.items,
      card: _card.toCard(),
      customerNotes: _notes.text,
    );
  }

  /// `422`: the menu changed (e.g. a product sold out). Reload it and drop
  /// what no longer exists so the guest can fix the order.
  Future<void> _reloadMenu() async {
    final cart = context.read<CartCubit>();
    final products = await context.read<MenuCubit>().refresh(_session);
    if (products != null) cart.syncProducts(products);
  }

  void _onCheckoutChanged(BuildContext context, CheckoutState state) {
    switch (state.status) {
      case CheckoutStatus.success:
        HapticFeedback.mediumImpact();
        context.read<CartCubit>().clear();
        context.go(AppRoutes.success(_session.qrId), extra: state.receipt);
      case CheckoutStatus.failure:
        HapticFeedback.heavyImpact();
        final error = state.error;
        if (error is CardDeclinedException) _card.cvc.clear();
        if (error is OrderRejectedException) _reloadMenu();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(context.l10n.errorText(error)),
              backgroundColor: AppColors.ink,
              duration: const Duration(seconds: 6),
            ),
          );
      case CheckoutStatus.idle || CheckoutStatus.processing:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocListener<CheckoutCubit, CheckoutState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: _onCheckoutChanged,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: _backToMenu),
          title: Text(l10n.reviewAndPay),
          actions: const [
            Padding(
              padding: EdgeInsetsDirectional.only(end: 12),
              child: ScanTableButton(size: 40),
            ),
          ],
        ),
        body: BlocBuilder<CartCubit, CartState>(
          builder: (context, cart) {
            if (cart.isEmpty) {
              return StatusView(
                icon: Icons.shopping_bag_outlined,
                title: l10n.cartEmptyTitle,
                message: l10n.checkoutEmptyMessage,
                actionLabel: l10n.browseMenu,
                onAction: () => context.go(AppRoutes.menu(_session.qrId)),
              );
            }
            final processing = context.select(
              (CheckoutCubit c) => c.state.isProcessing,
            );
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 140),
                    children: [
                      _OrderContext(session: _session, cart: cart),
                      const SizedBox(height: 16),
                      _Section(
                        title: l10n.itemsSection,
                        child: Column(
                          children: [
                            for (final (i, item) in cart.items.indexed) ...[
                              if (i > 0) const Divider(height: 24),
                              CartLineTile(
                                item: item,
                                currency: _session.currency,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _Section(
                        title: l10n.orderNotesSection,
                        child: TextField(
                          controller: _notes,
                          enabled: !processing,
                          maxLines: 2,
                          maxLength: OrderRepositoryImpl.maxNotesLength,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(
                              OrderRepositoryImpl.maxNotesLength,
                            ),
                          ],
                          decoration: InputDecoration(
                            hintText: l10n.orderNotesHint,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _Section(
                        title: l10n.summarySection,
                        child: _Totals(cart: cart, session: _session),
                      ),
                      const SizedBox(height: 16),
                      _Section(
                        title: l10n.cardSection,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CreditCardPreview(controllers: _card),
                            const SizedBox(height: 20),
                            CardForm(controllers: _card, enabled: !processing),
                            const SizedBox(height: 12),
                            _Hint(
                              icon: Icons.lock_outline_rounded,
                              text: l10n.cardSecureNotice,
                            ),
                            if (AppConfig.useDummyData) ...[
                              const SizedBox(height: 6),
                              _Hint(
                                icon: Icons.science_outlined,
                                text: l10n.demoCardHint,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
          builder: (context, cart) => cart.isEmpty
              ? const SizedBox.shrink()
              : _PayBar(session: _session, cart: cart, onPay: () => _pay(cart)),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.inkSubtle),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}

class _Totals extends StatelessWidget {
  const _Totals({required this.cart, required this.session});

  final CartState cart;
  final TableSession session;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    String money(double v) =>
        CurrencyFormatter.format(v, currency: session.currency);
    final l10n = context.l10n;
    return Column(
      children: [
        _row(context, l10n.subtotalExclVat, money(cart.subtotal)),
        const SizedBox(height: 6),
        _row(
          context,
          l10n.vatRate((session.vatRate * 100).round()),
          money(cart.vat(session.vatRate)),
        ),
        const Divider(height: 24),
        Row(
          children: [
            Text(l10n.total, style: textTheme.titleMedium),
            const Spacer(),
            Text(
              money(cart.total(session.vatRate)),
              style: textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(l10n.totalConfirmedByServer, style: textTheme.bodySmall),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, String label, String value) => Row(
    children: [
      Text(label, style: Theme.of(context).textTheme.bodyMedium),
      const Spacer(),
      Text(value, style: Theme.of(context).textTheme.bodyMedium),
    ],
  );
}

class _PayBar extends StatelessWidget {
  const _PayBar({
    required this.session,
    required this.cart,
    required this.onPay,
  });

  final TableSession session;
  final CartState cart;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final processing = context.select(
      (CheckoutCubit c) => c.state.isProcessing,
    );
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 608),
            child: CustomButton(
              label: processing ? context.l10n.processing : context.l10n.payNow,
              icon: Icons.lock_outline_rounded,
              isLoading: processing,
              onPressed: processing ? null : onPay,
              trailing: AnimatedAmount(
                amount: cart.total(session.vatRate),
                currency: session.currency,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact branch / table / item count strip on top of the checkout.
class _OrderContext extends StatelessWidget {
  const _OrderContext({required this.session, required this.cart});

  final TableSession session;
  final CartState cart;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppColors.glow(AppColors.primaryDark),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Image.asset('assets/images/zood_mark.png'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.branchName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${l10n.dineIn} · ${l10n.itemCount(cart.totalQuantity)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TableBadge(tableName: session.tableName),
        ],
      ),
    );
  }
}
