import 'package:flutter/material.dart';

import 'package:zood_pay_at_table/Helper/L10n.dart';
import 'package:zood_pay_at_table/Styles/AppColors.dart';
import 'package:zood_pay_at_table/Helper/CurrencyFormatter.dart';
import 'package:zood_pay_at_table/Widgets/AutoDirText.dart';
import 'package:zood_pay_at_table/Widgets/CustomButton.dart';
import 'package:zood_pay_at_table/Models/Menu/ProductModel.dart';
import 'package:zood_pay_at_table/Models/Cart/CartItemModel.dart';
import 'package:zood_pay_at_table/Screens/Menu/Widgets/ModifierGroup.dart';
import 'package:zood_pay_at_table/Screens/Menu/Widgets/ProductArtwork.dart';
import 'package:zood_pay_at_table/Widgets/QuantityStepper.dart';
import 'package:zood_pay_at_table/Bloc/AppCubit.dart';

import '../Controller/ProductDetailsController.dart';

/// Bottom sheet on phones, centered dialog on wider screens.
Future<void> showProductDetails(
  BuildContext context, {
  required ProductModel product,
  required String currency,
}) {
  final content = ProductDetailsDialog(product: product, currency: currency);

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

  final ProductModel product;
  final String currency;

  @override
  State<ProductDetailsDialog> createState() => _ProductDetailsDialogState();
}

class _ProductDetailsDialogState extends State<ProductDetailsDialog> {
  late ProductDetailsController _controller;

  ProductModel get _product => widget.product;

  @override
  void initState() {
    super.initState();
    _controller = ProductDetailsController(
      refresh,
      appCubit: AppCubit.get(context),
      product: widget.product,
    );
    _controller.onInit();
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addToCart() {
    if (_controller.addToCart()) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = S.of(context);
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
                    selection: _controller.selection,
                    currency: widget.currency,
                    showError: _controller.showMissing,
                    onChanged: _controller.select,
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
                        controller: _controller.notesController,
                        maxLength: CartItemModel.maxNotesLength,
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
                  quantity: _controller.quantity,
                  onIncrement: _controller.increment,
                  onDecrement: _controller.decrement,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    label: _controller.selection.missing.isEmpty
                        ? l10n.addToOrder
                        : l10n.chooseModifier(
                            _controller.selection.missing.first.name,
                          ),
                    onPressed: _product.isAvailable ? _addToCart : null,
                    trailing: Text(
                      CurrencyFormatter.format(
                        _controller.total,
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
