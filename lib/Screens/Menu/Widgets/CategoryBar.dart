import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:zood_pay_at_table/Helper/L10n.dart';
import 'package:zood_pay_at_table/Styles/AppColors.dart';
import 'package:zood_pay_at_table/Models/Menu/MenuModel.dart';
import 'package:zood_pay_at_table/Screens/Menu/Widgets/MenuVisuals.dart';

class CategoryBar extends StatefulWidget {
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
  State<CategoryBar> createState() => _CategoryBarState();
}

class _CategoryBarState extends State<CategoryBar> {
  final ScrollController _scroll = ScrollController();
  final Map<String, GlobalKey> _chipKeys = {};

  GlobalKey _keyFor(String category) =>
      _chipKeys.putIfAbsent(category, GlobalKey.new);

  @override
  void didUpdateWidget(CategoryBar old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _revealSelected());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Scrolls only this bar; `Scrollable.ensureVisible` would also move the
  /// menu list the bar is pinned in.
  void _revealSelected() {
    if (!mounted || !_scroll.hasClients) return;
    final chip = _chipKeys[widget.selected]?.currentContext?.findRenderObject();
    if (chip == null || !chip.attached) return;
    final position = _scroll.position;
    final viewport = RenderAbstractViewport.of(chip);
    // Leave a chip that is already in view alone, so the bar doesn't sway
    // on every section change while the menu scrolls.
    final a = viewport.getOffsetToReveal(chip, 0).offset;
    final b = viewport.getOffsetToReveal(chip, 1).offset;
    const margin = 16.0;
    if (position.pixels >= (a < b ? a : b) - margin &&
        position.pixels <= (a < b ? b : a) + margin) {
      return;
    }
    final target = viewport
        .getOffsetToReveal(chip, 0.5)
        .offset
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    if ((target - position.pixels).abs() < 1) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _scroll.jumpTo(target);
    } else {
      _scroll.animateTo(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: CategoryBar.height,
      child: ListView.separated(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        clipBehavior: Clip.none,
        itemCount: widget.categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          final isSelected = category == widget.selected;
          final isAll = category == MenuModel.allCategory;
          final visual = isAll
              ? const MenuVisual(
                  Icons.restaurant_menu_rounded,
                  AppColors.primarySoft,
                  AppColors.primary,
                )
              : MenuVisuals.forCategory(
                  category,
                  id: widget.categoryIdOf?.call(category),
                );
          return Semantics(
            key: _keyFor(category),
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
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onSelected(category);
                  },
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
                                : visual.soft,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            visual.icon,
                            size: 16,
                            color: isSelected ? Colors.white : visual.tint,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isAll ? S.of(context).allCategory : category,
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
                            '${widget.countFor(category)}',
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
