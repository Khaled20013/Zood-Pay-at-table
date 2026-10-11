import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/status_view.dart';
import '../../domain/entities/modifier_selection.dart';
import '../../domain/entities/product.dart';
import '../../../table_session/domain/entities/table_session.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../cubit/menu_cubit.dart';
import '../../../cart/presentation/widgets/cart_bottom_sheet.dart';
import '../widgets/category_bar.dart';
import '../widgets/product_artwork.dart';
import '../widgets/product_card.dart';
import '../../../table_session/presentation/widgets/table_header.dart';
import '../../../table_session/presentation/widgets/table_session_gate.dart';
import 'product_details_dialog.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key, required this.qrId});

  final String qrId;

  @override
  Widget build(BuildContext context) {
    return TableSessionGate(
      qrId: qrId,
      builder: (context, session) => _MenuView(session: session),
    );
  }
}

class _MenuView extends StatefulWidget {
  const _MenuView({required this.session});

  final TableSession session;

  @override
  State<_MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<_MenuView> {
  static const double _sidePanelBreakpoint = 1000;
  static const double _sidePanelWidth = 380;

  final ScrollController _scroll = ScrollController();
  final TextEditingController _search = TextEditingController();

  TableSession get _session => widget.session;

  @override
  void initState() {
    super.initState();
    context.read<MenuCubit>().load(_session);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  void _goToCheckout() => context.push(AppRoutes.cart(_session.qrId));

  void _openCart() => CartBottomSheet.show(
    context,
    session: _session,
    onCheckout: _goToCheckout,
  );

  void _openProduct(Product product) => showProductDetails(
    context,
    product: product,
    currency: _session.currency,
  );

  /// Adds with the default options; opens the sheet when a required
  /// modifier still needs a choice.
  void _quickAdd(Product product) {
    final selection = ModifierSelection.initial(product);
    if (!selection.isValid) {
      _openProduct(product);
      return;
    }
    context.read<CartCubit>().addProduct(
      product,
      options: selection.selectedOptions,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        menuSnackBar(
          context,
          message: context.l10n.itemAdded(product.name),
          action: product.hasModifiers
              ? SnackBarAction(
                  label: context.l10n.customize,
                  textColor: AppColors.accent,
                  onPressed: () => _openProduct(product),
                )
              : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final showSidePanel = constraints.maxWidth >= _sidePanelBreakpoint;
            if (showSidePanel) {
              return Row(
                children: [
                  Expanded(child: _buildMenu(bottomInset: 32)),
                  _SideCartPanel(
                    width: _sidePanelWidth,
                    session: _session,
                    onCheckout: _goToCheckout,
                  ),
                ],
              );
            }
            return Stack(
              children: [
                Positioned.fill(child: _buildMenu(bottomInset: 120)),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: SafeArea(
                    top: false,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: FloatingCartBar(
                          session: _session,
                          onPressed: _openCart,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenu({required double bottomInset}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gutter = math.max(
          16.0,
          (constraints.maxWidth - AppTheme.maxContentWidth) / 2,
        );
        return BlocBuilder<MenuCubit, MenuState>(
          builder: (context, menu) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<MenuCubit>().retry(),
              child: CustomScrollView(
                controller: _scroll,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverSafeArea(
                    bottom: false,
                    sliver: SliverPadding(
                      padding: EdgeInsets.fromLTRB(gutter, 12, gutter, 12),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          children: [
                            TableHeader(session: _session),
                            const SizedBox(height: 14),
                            _SearchField(
                              controller: _search,
                              onChanged: context.read<MenuCubit>().search,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (menu.status == MenuStatus.loaded &&
                      menu.products.isNotEmpty)
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _CategoryHeaderDelegate(
                        gutter: gutter - 16,
                        child: CategoryBar(
                          categories: menu.categories,
                          selected: menu.selectedCategory,
                          countFor: menu.countFor,
                          categoryIdOf: menu.categoryIdOf,
                          onSelected: (c) {
                            context.read<MenuCubit>().selectCategory(c);
                            if (_scroll.hasClients && _scroll.offset > 140) {
                              _scroll.animateTo(
                                140,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ..._buildContent(menu, gutter),
                  SliverToBoxAdapter(child: SizedBox(height: bottomInset)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildContent(MenuState menu, double gutter) {
    final l10n = context.l10n;
    switch (menu.status) {
      case MenuStatus.initial:
      case MenuStatus.loading:
        return [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 0),
            sliver: SliverToBoxAdapter(
              child: ShimmerScope(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        SkeletonBox(width: 70, height: 38, radius: 40),
                        SizedBox(width: 8),
                        SkeletonBox(width: 140, height: 38, radius: 40),
                        SizedBox(width: 8),
                        SkeletonBox(width: 120, height: 38, radius: 40),
                      ],
                    ),
                    const SizedBox(height: 20),
                    for (var i = 0; i < 4; i++) ...[
                      const ProductCardSkeleton(),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ];
      case MenuStatus.failure:
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: StatusView(
              isError: true,
              icon: Icons.wifi_off_rounded,
              title: l10n.menuLoadFailedTitle,
              message: l10n.errorText(menu.error),
              actionLabel: l10n.tryAgain,
              onAction: () => context.read<MenuCubit>().retry(),
            ),
          ),
        ];
      case MenuStatus.loaded:
        if (menu.products.isEmpty) {
          return [
            SliverFillRemaining(
              hasScrollBody: false,
              child: StatusView(
                icon: Icons.menu_book_outlined,
                title: l10n.menuEmptyTitle,
                message: l10n.menuEmptyMessage,
              ),
            ),
          ];
        }
        final visible = menu.visibleProducts;
        if (visible.isEmpty) {
          return [
            SliverFillRemaining(
              hasScrollBody: false,
              child: StatusView(
                icon: Icons.search_off_rounded,
                title: l10n.noMatchesTitle,
                message: menu.query.isEmpty
                    ? l10n.noItemsInCategory(
                        l10n.categoryLabel(
                          menu.selectedCategory,
                          allSentinel: MenuState.allCategory,
                        ),
                      )
                    : l10n.noItemsMatchQuery(menu.query.trim()),
                actionLabel: l10n.showFullMenu,
                onAction: () {
                  _search.clear();
                  context.read<MenuCubit>()
                    ..search('')
                    ..selectCategory(MenuState.allCategory);
                },
              ),
            ),
          ];
        }
        final groups = <String, List<Product>>{};
        for (final p in visible) {
          (groups[p.category] ??= []).add(p);
        }
        return [
          for (final entry in groups.entries) ...[
            SliverPadding(
              padding: EdgeInsetsDirectional.fromSTEB(
                gutter + 2,
                14,
                gutter,
                10,
              ),
              sliver: SliverToBoxAdapter(
                child: _SectionTitle(
                  title: entry.key,
                  categoryId: menu.categoryIdOf(entry.key),
                  count: entry.value.length,
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: gutter),
              sliver: _ProductGrid(
                products: entry.value,
                currency: _session.currency,
                onTap: _openProduct,
                onQuickAdd: _quickAdd,
              ),
            ),
          ],
        ];
    }
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({
    required this.products,
    required this.currency,
    required this.onTap,
    required this.onQuickAdd,
  });

  final List<Product> products;
  final String currency;
  final ValueChanged<Product> onTap;
  final ValueChanged<Product> onQuickAdd;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      buildWhen: (a, b) => a.items != b.items,
      builder: (context, cart) => SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 540,
          mainAxisExtent: ProductCard.height,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            currency: currency,
            quantityInCart: cart.quantityOf(product.id),
            onTap: () => onTap(product),
            onQuickAdd: () => onQuickAdd(product),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.count,
    this.categoryId,
  });

  final String title;
  final String? categoryId;
  final int count;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final key = categoryId ?? title;
    final [soft, tint] = AppColors.tintFor(key);
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: soft,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(ProductArtwork.iconFor(key), size: 18, color: tint),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: soft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            context.l10n.itemCount(count),
            style: textTheme.labelSmall?.copyWith(
              color: tint,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: AppColors.softShadow,
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: context.l10n.searchHint,
            fillColor: AppColors.surface,
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.primary,
            ),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: context.l10n.clearSearch,
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  _CategoryHeaderDelegate({required this.child, required this.gutter});

  final Widget child;
  final double gutter;

  @override
  double get minExtent => CategoryBar.height;

  @override
  double get maxExtent => CategoryBar.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: overlaps
            ? const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: gutter),
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CategoryHeaderDelegate old) =>
      old.child != child || old.gutter != gutter;
}

class _SideCartPanel extends StatelessWidget {
  const _SideCartPanel({
    required this.width,
    required this.session,
    required this.onCheckout,
  });

  final double width;
  final TableSession session;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: BorderDirectional(start: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  const Icon(Icons.shopping_bag_outlined),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.orderForTable(session.tableName),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            Expanded(
              child: CartContents(session: session, onCheckout: onCheckout),
            ),
          ],
        ),
      ),
    );
  }
}
