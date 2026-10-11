import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/product.dart';

/// Product photo, or a category-tinted illustration when the POS item has
/// no image yet.
class ProductArtwork extends StatelessWidget {
  const ProductArtwork({
    super.key,
    required this.product,
    this.size,
    this.radius = 14,
    this.iconSize = 40,
  });

  final Product product;
  final double? size;
  final double radius;
  final double iconSize;

  /// [category] is a category id or English name; see
  /// [AppColors.categoryKey].
  static IconData iconFor(String? category) =>
      switch (AppColors.categoryKey(category)) {
        'hot_beverages' => Icons.coffee_rounded,
        'cold_beverages' => Icons.local_drink_rounded,
        'desserts' => Icons.cake_rounded,
        _ => Icons.restaurant_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final categoryKey = product.categoryId ?? product.category;
    final [bg, fg] = AppColors.tintFor(categoryKey);
    final placeholder = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bg, Color.lerp(bg, fg, 0.18)!],
        ),
      ),
      child: Center(
        child: Icon(iconFor(categoryKey), size: iconSize, color: fg),
      ),
    );

    final image = product.imageUrl == null
        ? placeholder
        : Stack(
            fit: StackFit.expand,
            children: [
              placeholder,
              Image.network(
                product.imageUrl!,
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, wasSyncLoaded) =>
                    wasSyncLoaded
                    ? child
                    : AnimatedOpacity(
                        opacity: frame == null ? 0 : 1,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOut,
                        child: child,
                      ),
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ],
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(width: size, height: size, child: image),
    );
  }
}
