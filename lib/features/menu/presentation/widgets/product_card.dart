import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/product.dart';
import 'product_artwork.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.currency,
    required this.quantityInCart,
    required this.onTap,
    required this.onQuickAdd,
  });

  final Product product;
  final String currency;
  final int quantityInCart;
  final VoidCallback onTap;

  /// Gets the add button's global rect, where a fly-to-cart can start.
  final ValueChanged<Rect> onQuickAdd;

  static const double height = 156;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final inCart = quantityInCart > 0;
    final radius = BorderRadius.circular(AppTheme.radiusLg - 2);

    return _PressScale(
      enabled: product.isAvailable,
      child: Opacity(
        opacity: product.isAvailable ? 1 : 0.55,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: height,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: radius,
            border: Border.all(
              color: inCart ? AppColors.primaryBright : Colors.transparent,
              width: 1.6,
            ),
            boxShadow: inCart
                ? AppColors.glow(AppColors.primaryBright)
                : AppColors.softShadow,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: radius,
              onTap: product.isAvailable ? onTap : null,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          6,
                          4,
                          12,
                          2,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.isPopular)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 6),
                                child: _PopularTag(),
                              ),
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleMedium?.copyWith(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.description,
                              maxLines: product.isPopular ? 2 : 3,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.inkMuted,
                                height: 1.35,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Text(
                                  CurrencyFormatter.format(
                                    product.price,
                                    currency: currency,
                                  ),
                                  style: textTheme.titleMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (product.calories != null) ...[
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.local_fire_department_rounded,
                                    size: 14,
                                    color: AppColors.accentDeep,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    context.l10n.calories(product.calories!),
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
                    ),
                    SizedBox(
                      width: 128,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: Hero(
                              tag: 'product-art-${product.id}',
                              child: ProductArtwork(
                                product: product,
                                radius: 18,
                              ),
                            ),
                          ),
                          if (!product.isAvailable)
                            const PositionedDirectional(
                              start: 8,
                              top: 8,
                              child: _SoldOutTag(),
                            ),
                          PositionedDirectional(
                            end: 6,
                            bottom: 6,
                            child: _AddButton(
                              quantity: quantityInCart,
                              enabled: product.isAvailable,
                              onPressed: onQuickAdd,
                              productName: product.name,
                            ),
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
  }
}

/// Sinks the card slightly while a finger is on it.
class _PressScale extends StatefulWidget {
  const _PressScale({required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _down = false;
  Offset _origin = Offset.zero;

  void _set(bool down) {
    if (_down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: widget.enabled
          ? (e) {
              _origin = e.position;
              _set(true);
            }
          : null,
      // A drag is a scroll, not a press.
      onPointerMove: (e) {
        if ((e.position - _origin).distance > kTouchSlop) _set(false);
      },
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down ? 0.975 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.quantity,
    required this.enabled,
    required this.onPressed,
    required this.productName,
  });

  final int quantity;
  final bool enabled;
  final ValueChanged<Rect> onPressed;
  final String productName;

  void _press(BuildContext context) {
    HapticFeedback.lightImpact();
    final box = context.findRenderObject() as RenderBox?;
    onPressed(
      box == null || !box.hasSize
          ? Rect.zero
          : box.localToGlobal(Offset.zero) & box.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    final inCart = quantity > 0;
    return Tooltip(
      message: context.l10n.addProduct(productName),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          gradient: inCart ? AppColors.ctaGradient : null,
          color: inCart ? null : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: enabled ? () => _press(context) : null,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, a) =>
                  ScaleTransition(scale: a, child: child),
              child: SizedBox(
                key: ValueKey(quantity),
                height: 38,
                width: inCart ? null : 38,
                child: inCart
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 11),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$quantity',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.add_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      )
                    : const Icon(
                        Icons.add_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PopularTag extends StatelessWidget {
  const _PopularTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(6, 2, 8, 2),
      decoration: BoxDecoration(
        gradient: AppColors.warmGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 3),
          Text(
            context.l10n.popular,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoldOutTag extends StatelessWidget {
  const _SoldOutTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        context.l10n.soldOut,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Skeleton matching [ProductCard]'s layout.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ProductCard.height,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg - 2),
        boxShadow: AppColors.softShadow,
      ),
      child: const Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(6, 4, 12, 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 130, height: 16),
                  SizedBox(height: 10),
                  SkeletonBox(height: 10),
                  SizedBox(height: 6),
                  SkeletonBox(width: 160, height: 10),
                  Spacer(),
                  SkeletonBox(width: 80, height: 16),
                ],
              ),
            ),
          ),
          SkeletonBox(width: 128, height: double.infinity, radius: 18),
        ],
      ),
    );
  }
}
