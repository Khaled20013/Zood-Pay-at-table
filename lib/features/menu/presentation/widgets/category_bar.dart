import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/menu_cubit.dart';
import 'product_artwork.dart';

class CategoryBar extends StatelessWidget {
  const CategoryBar({
    super.key,
    required this.categories,
    required this.selected,
    required this.countFor,
    required this.onSelected,
    this.categoryIdOf,
  });

  final List<String> categories;
  final String selected;
  final int Function(String category) countFor;
  final ValueChanged<String> onSelected;

  /// Maps a localized category name to its id for icons and tints.
  final String? Function(String category)? categoryIdOf;

  static const double height = 64;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        clipBehavior: Clip.none,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selected;
          final isAll = category == MenuState.allCategory;
          final icon = isAll
              ? Icons.restaurant_menu_rounded
              : ProductArtwork.iconFor(
                  categoryIdOf?.call(category) ?? category,
                );
          final tint = isAll
              ? AppColors.primary
              : AppColors.tintFor(categoryIdOf?.call(category) ?? category)[1];
          return Semantics(
            selected: isSelected,
            button: true,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.ctaGradient : null,
                color: isSelected ? null : AppColors.surface,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppColors.border,
                ),
                boxShadow: isSelected
                    ? AppColors.glow(AppColors.primary)
                    : AppColors.softShadow,
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: BorderRadius.circular(40),
                  onTap: () => onSelected(category),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(6, 0, 12, 0),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.2)
                                : tint.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            size: 16,
                            color: isSelected ? Colors.white : tint,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isAll ? context.l10n.allCategory : category,
                          style: textTheme.labelLarge?.copyWith(
                            fontSize: 14,
                            color: isSelected ? Colors.white : AppColors.ink,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.22)
                                : AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${countFor(category)}',
                            style: textTheme.labelSmall?.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.inkMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
