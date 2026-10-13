import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';
import 'menu_visuals.dart';

/// Product photo, or an illustration guessed from the product and category
/// names when the POS item has no image yet.
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

  static MenuVisual visualFor(Product product) => MenuVisuals.of([
    product.name,
    product.category,
    product.categoryId,
  ], seed: product.categoryId ?? product.category);

  @override
  Widget build(BuildContext context) {
    final visual = visualFor(product);
    final placeholder = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [visual.soft, Color.lerp(visual.soft, visual.tint, 0.22)!],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final side = constraints.biggest.shortestSide;
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              if (side.isFinite && side > 80)
                PositionedDirectional(
                  end: -side * 0.18,
                  top: -side * 0.18,
                  child: Transform.rotate(
                    angle: -0.35,
                    child: Icon(
                      visual.icon,
                      size: side * 0.75,
                      color: visual.tint.withValues(alpha: 0.08),
                    ),
                  ),
                ),
              Center(
                child: Container(
                  padding: EdgeInsets.all(iconSize * 0.32),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(visual.icon, size: iconSize, color: visual.tint),
                ),
              ),
            ],
          );
        },
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
                // Some storage hosts send no CORS headers; let web fall back
                // to an <img> element instead of showing nothing.
                webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
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
