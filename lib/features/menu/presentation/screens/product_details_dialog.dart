import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/auto_dir_text.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/entities/modifier_selection.dart';
import '../../domain/entities/product.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../widgets/modifier_group.dart';
import '../widgets/product_artwork.dart';
import '../../../../core/widgets/quantity_stepper.dart';

/// Bottom sheet on phones, centered dialog on wider screens.
Future<void> showProductDetails(
  BuildContext context, {
  required Product product,
  required String currency,
}) {
  final cart = context.read<CartCubit>();
  final content = BlocProvider.value(
    value: cart,
    child: ProductDetailsDialog(product: product, currency: currency),
  );

  if (MediaQuery.sizeOf(context).width < 640) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      builder: (_) => content,
    );
  }
  return showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 760),
        child: content,
      ),
    ),
  );
}

class ProductDetailsDialog extends StatefulWidget {
  const ProductDetailsDialog({
    super.key,
    required this.product,
    required this.currency,
  });

  final Product product;
  final String currency;

  @override
  State<ProductDetailsDialog> createState() => _ProductDetailsDialogState();
}

class _ProductDetailsDialogState extends State<ProductDetailsDialog> {
  final TextEditingController _notes = TextEditingController();
  late ModifierSelection _selection = ModifierSelection.initial(_product);
  int _quantity = 1;

  /// Set once the guest taps "Add" with a required modifier left empty.
  bool _showMissing = false;

  Product get _product => widget.product;

  double get _total =>
      CurrencyFormatter.roundMoney(_selection.unitPrice * _quantity);

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  void _addToCart() {
    if (!_selection.isValid) {
      setState(() => _showMissing = true);
      return;
    }
    context.read<CartCubit>().addProduct(
      _product,
      options: _selection.selectedOptions,
      quantity: _quantity,
      notes: _notes.text,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 260,
                      width: double.infinity,
                      child: Hero(
                        tag: 'product-art-${_product.id}',
                        child: ProductArtwork(
                          product: _product,
                          radius: 0,
                          iconSize: 72,
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 90,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x00000000), Color(0x8C000000)],
                          ),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      start: 16,
                      bottom: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.ctaGradient,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: AppColors.glow(AppColors.primary),
                        ),
                        child: Text(
                          CurrencyFormatter.format(
                            _product.price,
                            currency: widget.currency,
                          ),
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      top: 12,
                      end: 12,
                      child: IconButton.filledTonal(
                        tooltip: l10n.close,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoDirText(
                        _product.name,
                        style: textTheme.headlineMedium?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AutoDirText(
                        _product.description,
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            CurrencyFormatter.format(
                              _product.price,
                              currency: widget.currency,
                            ),
                            style: textTheme.titleMedium?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          if (_product.calories != null) ...[
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.local_fire_department_outlined,
                              size: 16,
                              color: AppColors.inkSubtle,
                            ),
                            Text(
                              l10n.calories(_product.calories!),
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.inkSubtle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                for (final modifier in _product.modifiers)
                  ModifierGroup(
                    modifier: modifier,
                    selection: _selection,
                    currency: widget.currency,
                    showError: _showMissing,
                    onChanged: (next) => setState(() => _selection = next),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.specialInstructions,
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _notes,
                        maxLength: CartItem.maxNotesLength,
                        maxLines: 2,
                        minLines: 1,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: l10n.specialInstructionsHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                QuantityStepper(
                  quantity: _quantity,
                  onIncrement: () => setState(() => _quantity++),
                  onDecrement: () => setState(() => _quantity--),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    label: _selection.missing.isEmpty
                        ? l10n.addToOrder
                        : l10n.chooseModifier(_selection.missing.first.name),
                    onPressed: _product.isAvailable ? _addToCart : null,
                    trailing: Text(
                      CurrencyFormatter.format(
                        _total,
                        currency: widget.currency,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
