import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/entities/cart_item.dart';
import '../../../table_session/domain/entities/table_session.dart';
import '../cubit/cart_cubit.dart';
import '../../../menu/presentation/widgets/product_artwork.dart';
import '../../../../core/widgets/quantity_stepper.dart';

/// Floating pill pinned to the bottom of the menu while the cart has items.
class FloatingCartBar extends StatelessWidget {
  const FloatingCartBar({
    super.key,
    required this.session,
    required this.onPressed,
  });

  final TableSession session;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cart) {
        return AnimatedSlide(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          offset: cart.isEmpty ? const Offset(0, 1.6) : Offset.zero,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: cart.isEmpty ? 0 : 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.darkGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x55061033),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  onTap: cart.isEmpty ? null : onPressed,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Row(
                      children: [
                        TweenAnimationBuilder<double>(
                          key: ValueKey(cart.totalQuantity),
                          tween: Tween(begin: 1.35, end: 1),
                          duration: const Duration(milliseconds: 420),
                          curve: Curves.elasticOut,
                          builder: (context, scale, child) =>
                              Transform.scale(scale: scale, child: child),
                          child: Container(
                            width: 42,
                            height: 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: AppColors.warmGradient,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: AppColors.glow(AppColors.accentDeep),
                            ),
                            child: Text(
                              '${cart.totalQuantity}',
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.l10n.viewYourOrder,
                                style: textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${context.l10n.tableNumber(session.tableName)} · ${context.l10n.itemCount(cart.totalQuantity)}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            14,
                            10,
                            8,
                            10,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.ctaGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                CurrencyFormatter.format(
                                  cart.total(session.vatRate),
                                  currency: session.currency,
                                ),
                                style: textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.keyboard_arrow_up_rounded,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

abstract final class CartBottomSheet {
  static Future<void> show(
    BuildContext context, {
    required TableSession session,
    required VoidCallback onCheckout,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        // Own messenger so the "Undo" snackbar shows above the sheet.
        builder: (context, controller) => ScaffoldMessenger(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: CartContents(
              session: session,
              scrollController: controller,
              onCheckout: () {
                Navigator.of(sheetContext).pop();
                onCheckout();
              },
              onEmptied: () => Navigator.of(sheetContext).maybePop(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cart lines + totals + checkout CTA. Rendered inside the mobile bottom
/// sheet and as the persistent side panel on wide layouts.
class CartContents extends StatelessWidget {
  const CartContents({
    super.key,
    required this.session,
    required this.onCheckout,
    this.scrollController,
    this.onEmptied,
    this.showTitle = true,
  });

  final TableSession session;
  final VoidCallback onCheckout;
  final ScrollController? scrollController;
  final VoidCallback? onEmptied;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocConsumer<CartCubit, CartState>(
      listenWhen: (a, b) => !a.isEmpty && b.isEmpty,
      listener: (context, _) => onEmptied?.call(),
      builder: (context, cart) {
        if (cart.isEmpty) return const _EmptyCart();
        return Column(
          children: [
            if (showTitle)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.yourOrder,
                        style: textTheme.titleLarge,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.read<CartCubit>().clear(),
                      child: Text(context.l10n.clearAll),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: cart.items.length,
                separatorBuilder: (_, _) => const Divider(height: 24),
                itemBuilder: (context, index) => CartLineTile(
                  item: cart.items[index],
                  currency: session.currency,
                  onRemoved: (item) => _showUndo(context, item, index),
                ),
              ),
            ),
            _CartTotals(cart: cart, session: session, onCheckout: onCheckout),
          ],
        );
      },
    );
  }

  void _showUndo(BuildContext context, CartItem item, int index) {
    final cubit = context.read<CartCubit>();
    final l10n = context.l10n;
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.itemRemoved(item.product.name)),
          persist: false,
          action: SnackBarAction(
            label: l10n.undo,
            textColor: AppColors.accent,
            onPressed: () => cubit.restoreItem(item, index),
          ),
        ),
      );
  }
}

class CartLineTile extends StatelessWidget {
  const CartLineTile({
    super.key,
    required this.item,
    required this.currency,
    this.onRemoved,
  });

  final CartItem item;
  final String currency;
  final ValueChanged<CartItem>? onRemoved;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cubit = context.read<CartCubit>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProductArtwork(product: item.product, size: 56, iconSize: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.product.name, style: textTheme.titleMedium),
              if (item.selectedOptions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    item.optionsSummary,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                ),
              InkWell(
                onTap: () => _editNotes(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.notes.isEmpty
                            ? Icons.add_comment_outlined
                            : Icons.sticky_note_2_outlined,
                        size: 15,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          item.notes.isEmpty
                              ? context.l10n.addNote
                              : item.notes,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontStyle: item.notes.isEmpty
                                ? FontStyle.normal
                                : FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  QuantityStepper(
                    compact: true,
                    min: 0,
                    quantity: item.quantity,
                    onIncrement: () => cubit.increment(item.id),
                    onDecrement: () {
                      if (item.quantity == 1) onRemoved?.call(item);
                      cubit.decrement(item.id);
                    },
                  ),
                  const Spacer(),
                  Text(
                    CurrencyFormatter.format(
                      item.lineTotal,
                      currency: currency,
                    ),
                    style: textTheme.titleMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _editNotes(BuildContext context) async {
    final cubit = context.read<CartCubit>();
    final notes = await showDialog<String>(
      context: context,
      builder: (context) =>
          _NoteDialog(productName: item.product.name, initialNotes: item.notes),
    );
    if (notes != null) cubit.updateNotes(item.id, notes);
  }
}

/// Owns its [TextEditingController] so it outlives the dialog's exit
/// animation, which keeps rendering the field after `Navigator.pop`.
class _NoteDialog extends StatefulWidget {
  const _NoteDialog({required this.productName, required this.initialNotes});

  final String productName;
  final String initialNotes;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialNotes,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.noteFor(widget.productName)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: CartItem.maxNotesLength,
        maxLines: 3,
        minLines: 2,
        decoration: InputDecoration(hintText: l10n.noteHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

class _CartTotals extends StatelessWidget {
  const _CartTotals({
    required this.cart,
    required this.session,
    required this.onCheckout,
  });

  final CartState cart;
  final TableSession session;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TotalsRow(
              label: context.l10n.subtotal,
              value: CurrencyFormatter.format(
                cart.subtotal,
                currency: session.currency,
              ),
            ),
            const SizedBox(height: 4),
            _TotalsRow(
              label: context.l10n.vatRate((session.vatRate * 100).round()),
              value: CurrencyFormatter.format(
                cart.vat(session.vatRate),
                currency: session.currency,
              ),
            ),
            const SizedBox(height: 12),
            CustomButton(
              label: context.l10n.checkout,
              icon: Icons.lock_outline_rounded,
              onPressed: onCheckout,
              trailing: Text(
                CurrencyFormatter.format(
                  cart.total(session.vatRate),
                  currency: session.currency,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text(value, style: style),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.inkMuted,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(context.l10n.cartEmptyTitle, style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              context.l10n.cartEmptyMessage,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
