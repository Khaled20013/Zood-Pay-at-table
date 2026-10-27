import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:zood_pay_at_table/Bloc/AppCubit.dart';
import 'package:zood_pay_at_table/Bloc/states.dart';
import 'package:zood_pay_at_table/Helper/ApiServices/Base/DemoDataPolicy.dart';
import 'package:zood_pay_at_table/Helper/Errors/AppException.dart';
import 'package:zood_pay_at_table/Helper/L10n.dart';
import 'package:zood_pay_at_table/Styles/AppColors.dart';
import 'package:zood_pay_at_table/Styles/AppTheme.dart';
import 'package:zood_pay_at_table/Helper/CurrencyFormatter.dart';
import 'package:zood_pay_at_table/Widgets/AnimatedAmount.dart';
import 'package:zood_pay_at_table/Widgets/CustomButton.dart';
import 'package:zood_pay_at_table/Widgets/StatusView.dart';
import 'package:zood_pay_at_table/Screens/Cart/Widgets/CartBottomSheet.dart';
import 'package:zood_pay_at_table/Models/Cart/CartModel.dart';
import 'package:zood_pay_at_table/Models/Checkout/OrdersApi.dart';
import 'package:zood_pay_at_table/Models/TableSession/TableSessionModel.dart';
import 'package:zood_pay_at_table/Screens/TableSession/Widgets/ScanTableButton.dart';
import 'package:zood_pay_at_table/Screens/TableSession/Widgets/TableHeader.dart';
import 'package:zood_pay_at_table/Screens/TableSession/Widgets/TableSessionGate.dart';
import 'package:zood_pay_at_table/Screens/Checkout/Widgets/CardForm.dart';
import 'package:zood_pay_at_table/Screens/Checkout/Widgets/CreditCardPreview.dart';

import '../Controller/CartSummaryController.dart';

class CartSummaryScreen extends StatelessWidget {
  const CartSummaryScreen({super.key, required this.qrId});
  static const String routeName = "/CartSummaryScreen";
  static const String path = "cart";

  final String qrId;

  @override
  Widget build(BuildContext context) {
    return TableSessionGate(
      qrId: qrId,
      builder: (context, session) => _CheckoutView(session: session),
    );
  }
}

class _CheckoutView extends StatefulWidget {
  const _CheckoutView({required this.session});

  final TableSessionModel session;

  @override
  State<_CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<_CheckoutView> {
  final _formKey = GlobalKey<FormState>();
  final _card = CardFormControllers();
  late CartSummaryController _controller;

  TableSessionModel get _session => widget.session;

  @override
  void initState() {
    super.initState();
    _controller = CartSummaryController(
      refresh,
      appCubit: AppCubit.get(context),
      session: _session,
    );
    _controller.onInit();
    _card.fillDebugTestCard();
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _card.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final error = await _controller.pay(_card.toCard());
    if (error == null || !mounted) return;
    if (error is CardDeclinedException) _card.cvc.clear();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(S.of(context).errorText(error)),
          backgroundColor: AppColors.ink,
          duration: const Duration(seconds: 6),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final processing = _controller.isProcessing;
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: _controller.backToMenu),
          title: Text(l10n.reviewAndPay),
          actions: const [
            Padding(
              padding: EdgeInsetsDirectional.only(end: 12),
              child: ScanTableButton(size: 40),
            ),
          ],
        ),
        body: BlocBuilder<AppCubit, AppStates>(
          buildWhen: (_, state) => state is CartAppStates,
          builder: (context, _) {
            final cart = AppCubit.get(context).cart;
            if (cart.isEmpty) {
              return StatusView(
                icon: Icons.shopping_bag_outlined,
                title: l10n.cartEmptyTitle,
                message: l10n.checkoutEmptyMessage,
                actionLabel: l10n.browseMenu,
                onAction: _controller.browseMenu,
              );
            }
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
                          controller: _controller.notesController,
                          enabled: !processing,
                          maxLines: 2,
                          maxLength: OrdersApi.maxNotesLength,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(
                              OrdersApi.maxNotesLength,
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
                            if (DemoDataPolicy.useDummyData) ...[
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
        bottomNavigationBar: BlocBuilder<AppCubit, AppStates>(
          buildWhen: (_, state) => state is CartAppStates,
          builder: (context, _) {
            final cart = AppCubit.get(context).cart;
            return cart.isEmpty
                ? const SizedBox.shrink()
                : _PayBar(
                    session: _session,
                    cart: cart,
                    processing: processing,
                    onPay: _pay,
                  );
          },
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

  final CartModel cart;
  final TableSessionModel session;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    String money(double v) =>
        CurrencyFormatter.format(v, currency: session.currency);
    final l10n = S.of(context);
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
    required this.processing,
    required this.onPay,
  });

  final TableSessionModel session;
  final CartModel cart;
  final bool processing;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
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
              label: processing ? S.of(context).processing : S.of(context).payNow,
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

  final TableSessionModel session;
  final CartModel cart;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = S.of(context);
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
