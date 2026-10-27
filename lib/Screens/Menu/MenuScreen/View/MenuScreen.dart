import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:zood_pay_at_table/Helper/L10n.dart';
import 'package:zood_pay_at_table/Bloc/AppCubit.dart';
import 'package:zood_pay_at_table/Bloc/states.dart';
import 'package:zood_pay_at_table/Styles/AppColors.dart';
import 'package:zood_pay_at_table/Widgets/AppSnackBar.dart';
import 'package:zood_pay_at_table/Widgets/AutoDirText.dart';
import 'package:zood_pay_at_table/Widgets/FlyToCart.dart';
import 'package:zood_pay_at_table/Styles/AppTheme.dart';
import 'package:zood_pay_at_table/Widgets/StatusView.dart';
import 'package:zood_pay_at_table/Models/Menu/MenuModel.dart';
import 'package:zood_pay_at_table/Models/Menu/ProductModel.dart';
import 'package:zood_pay_at_table/Models/TableSession/TableSessionModel.dart';
import 'package:zood_pay_at_table/Screens/Cart/Widgets/CartBottomSheet.dart';
import 'package:zood_pay_at_table/Screens/Menu/Widgets/CategoryBar.dart';
import 'package:zood_pay_at_table/Screens/Menu/Widgets/MenuLoadingSkeleton.dart';
import 'package:zood_pay_at_table/Screens/Menu/Widgets/MenuVisuals.dart';
import 'package:zood_pay_at_table/Screens/Menu/Widgets/ProductArtwork.dart';
import 'package:zood_pay_at_table/Screens/Menu/Widgets/ProductCard.dart';
import 'package:zood_pay_at_table/Screens/TableSession/Widgets/TableHeader.dart';
import 'package:zood_pay_at_table/Screens/TableSession/Widgets/TableSessionGate.dart';
import 'package:zood_pay_at_table/Screens/Menu/ProductDetailsScreen/View/ProductDetailsScreen.dart';

import '../Controller/MenuScreenController.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key, required this.qrId});
  static const String routeName = "/MenuScreen";
  static const String path = "menu";

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

  final TableSessionModel session;

  @override
  State<_MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<_MenuView> {
  static const double _sidePanelBreakpoint = 1000;
  static const double _sidePanelWidth = 380;

  final ScrollController _scroll = ScrollController();
  final GlobalKey _cartTarget = GlobalKey(debugLabel: 'cart-target');

  /// Section header keys, in menu order, for the category scroll-spy.
  final Map<String, GlobalKey> _sectionKeys = {};
  List<String> _sections = const [];
  final ValueNotifier<String?> _activeSection = ValueNotifier(null);

  /// Set while a chip tap scrolls the menu, so the spy doesn't fight it.
  bool _scrollingToSection = false;

  /// Chip the guest tapped. Stays highlighted until they scroll by hand,
  /// since sections near the end can't scroll up to the bar.
  String? _tappedSection;

  late MenuScreenController _controller;

  TableSessionModel get _session => widget.session;

  @override
  void initState() {
    super.initState();
    _controller = MenuScreenController(
      refresh,
      appCubit: AppCubit.get(context),
      session: _session,
    );
    _controller.onInit();
    _scroll.addListener(_scheduleSync);
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _scroll.dispose();
    _controller.dispose();
    _activeSection.dispose();
    super.dispose();
  }

  GlobalKey _sectionKey(String category) =>
      _sectionKeys.putIfAbsent(category, GlobalKey.new);

  /// Height covered by the pinned category bar at the top of the list.
  double get _pinnedExtent => CategoryBar.height;

  RenderBox? _sectionBox(String category) {
    final box = _sectionKeys[category]?.currentContext?.findRenderObject();
    return box is RenderBox && box.attached ? box : null;
  }

  bool _syncScheduled = false;

  /// Scroll notifications arrive before the new layout, so header positions
  /// are read after the frame.
  void _scheduleSync() {
    if (_syncScheduled) return;
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (mounted) _syncActiveSection();
    });
  }

  /// Highlights the last section whose header has reached the pinned bar.
  void _syncActiveSection() {
    if (_scrollingToSection || _sections.isEmpty || !_scroll.hasClients) {
      return;
    }
    if (_sections.contains(_tappedSection)) {
      _activeSection.value = _tappedSection;
      return;
    }
    final viewport = _scroll.position.context.notificationContext
        ?.findRenderObject();
    if (viewport is! RenderBox) return;
    var active = _sections.first;
    final position = _scroll.position;
    if (position.pixels >= position.maxScrollExtent - 4) {
      active = _sections.last;
    } else {
      for (final section in _sections) {
        final box = _sectionBox(section);
        if (box == null) continue;
        final top = box.localToGlobal(Offset.zero, ancestor: viewport).dy;
        if (top <= _pinnedExtent + 24) active = section;
      }
    }
    _activeSection.value = active;
  }

  Future<void> _scrollToSection(String category) async {
    if (_sectionBox(category) == null || !_scroll.hasClients) return;
    _activeSection.value = category;
    _tappedSection = category;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    _scrollingToSection = true;
    try {
      // The list only estimates the extent of items it hasn't built, so the
      // first pass can stop short; a second pass lands on the real offset.
      for (var pass = 0; pass < 2; pass++) {
        final target = _sectionOffset(category);
        if (target == null || (target - _scroll.offset).abs() < 1) break;
        if (reduceMotion || pass > 0) {
          _scroll.jumpTo(target);
        } else {
          await _scroll.animateTo(
            target,
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeInOutCubic,
          );
        }
        if (!mounted || _tappedSection != category) break;
      }
    } finally {
      _scrollingToSection = false;
    }
  }

  /// Scroll offset that puts [category]'s header just under the bar.
  double? _sectionOffset(String category) {
    final box = _sectionBox(category);
    if (box == null || !_scroll.hasClients) return null;
    final position = _scroll.position;
    return (RenderAbstractViewport.of(box).getOffsetToReveal(box, 0).offset -
            _pinnedExtent -
            4)
        .clamp(position.minScrollExtent, position.maxScrollExtent);
  }

  void _goToCheckout() => _controller.openCheckout();

  void _openCart() => CartBottomSheet.show(
    context,
    session: _session,
    onCheckout: _goToCheckout,
  );

  void _openProduct(ProductModel product) => showProductDetails(
    context,
    product: product,
    currency: _session.currency,
  );

  /// Plain products go straight to the cart; products with options open
  /// the sheet (with their defaults picked) so the guest sees the choice.
  void _quickAdd(ProductModel product, Rect origin) {
    if (!_controller.quickAdd(product)) {
      _openProduct(product);
      return;
    }
    FlyToCart.run(
      context,
      from: origin,
      target: _cartTarget,
      icon: ProductArtwork.visualFor(product).icon,
    );
    // The flight confirms the add; the toast is only for reduced motion.
    if (!MediaQuery.disableAnimationsOf(context)) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        menuSnackBar(context, message: S.of(context).itemAdded(product.name)),
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
                    targetKey: _cartTarget,
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
                          badgeKey: _cartTarget,
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
        return BlocBuilder<AppCubit, AppStates>(
          buildWhen: (_, state) => state is MenuAppStates,
          builder: (context, _) {
            final menu = _controller.menu;
            final groups = _groupVisible(menu);
            _sections = groups.keys.toList(growable: false);
            _scheduleSync();
            // The list starts below the status bar so the category bar pins
            // under it instead of behind it.
            return SafeArea(
              bottom: false,
              child: NotificationListener<UserScrollNotification>(
                onNotification: (n) {
                  if (n.direction != ScrollDirection.idle) {
                    _tappedSection = null;
                  }
                  return false;
                },
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _controller.retry,
                  child: CustomScrollView(
                    controller: _scroll,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(gutter, 12, gutter, 12),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            children: [
                              TableHeader(session: _session),
                              const SizedBox(height: 14),
                              _SearchField(
                                controller: _controller.searchController,
                                onChanged: _controller.search,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (menu.status == MenuStatus.loaded && groups.isNotEmpty)
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _CategoryHeaderDelegate(
                            gutter: gutter - 16,
                            child: ValueListenableBuilder<String?>(
                              valueListenable: _activeSection,
                              builder: (context, active, _) => CategoryBar(
                                categories: _sections,
                                selected: _sections.contains(active)
                                    ? active!
                                    : _sections.first,
                                countFor: (c) => groups[c]?.length ?? 0,
                                categoryIdOf: menu.categoryIdOf,
                                onSelected: _scrollToSection,
                              ),
                            ),
                          ),
                        ),
                      ..._buildContent(menu, gutter, groups),
                      SliverToBoxAdapter(child: SizedBox(height: bottomInset)),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Visible products by category, in menu order (empty unless loaded).
  Map<String, List<ProductModel>> _groupVisible(MenuModel menu) {
    final groups = <String, List<ProductModel>>{};
    if (menu.status != MenuStatus.loaded) return groups;
    for (final p in _controller.visibleProducts) {
      (groups[p.category] ??= []).add(p);
    }
    return groups;
  }

  List<Widget> _buildContent(
    MenuModel menu,
    double gutter,
    Map<String, List<ProductModel>> groups,
  ) {
    final l10n = S.of(context);
    switch (menu.status) {
      case MenuStatus.initial:
      case MenuStatus.loading:
        return [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 0),
            sliver: const SliverToBoxAdapter(child: MenuLoadingSkeleton()),
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
              onAction: _controller.retry,
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
        if (groups.isEmpty) {
          return [
            SliverFillRemaining(
              hasScrollBody: false,
              child: StatusView(
                icon: Icons.search_off_rounded,
                title: l10n.noMatchesTitle,
                message: _controller.query.isEmpty
                    ? l10n.noItemsInCategory(
                        l10n.categoryLabel(
                          _controller.selectedCategory,
                          allSentinel: MenuModel.allCategory,
                        ),
                      )
                    : l10n.noItemsMatchQuery(_controller.query.trim()),
                actionLabel: l10n.showFullMenu,
                onAction: _controller.resetFilters,
              ),
            ),
          ];
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
                  key: _sectionKey(entry.key),
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
                highlight: _controller.query,
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
    this.highlight = '',
  });

  final List<ProductModel> products;
  final String currency;
  final String highlight;
  final ValueChanged<ProductModel> onTap;
  final void Function(ProductModel product, Rect origin) onQuickAdd;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppStates>(
      buildWhen: (_, state) =>
          state is CartAppStates && state.previous.items != state.cart.items,
      builder: (context, _) {
        final cart = AppCubit.get(context).cart;
        return SliverGrid.builder(
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
            highlight: highlight,
            onTap: () => onTap(product),
            onQuickAdd: (origin) => onQuickAdd(product, origin),
          );
        },
      );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    super.key,
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
    final visual = MenuVisuals.forCategory(title, id: categoryId);
    final soft = visual.soft;
    final tint = visual.tint;
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: soft,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(visual.icon, size: 18, color: tint),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: AutoDirText(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleLarge?.copyWith(
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
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
            S.of(context).itemCount(count),
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
            hintText: S.of(context).searchHint,
            fillColor: AppColors.surface,
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.primary,
            ),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: S.of(context).clearSearch,
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
    return ColoredBox(
      color: AppColors.background,
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
    required this.targetKey,
  });

  final double width;
  final TableSessionModel session;
  final VoidCallback onCheckout;

  /// Where quick-added items fly to.
  final GlobalKey targetKey;

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
                  Icon(key: targetKey, Icons.shopping_bag_outlined),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      S.of(context).orderForTable(session.tableName),
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
