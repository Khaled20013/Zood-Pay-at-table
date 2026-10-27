import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Helper/ApiServices/Base/KApiResponse.dart';
import '../Helper/Errors/AppException.dart';
import '../Models/Cart/CartItemModel.dart';
import '../Models/Cart/CartModel.dart';
import '../Models/Menu/MenuApi.dart';
import '../Models/Menu/MenuModel.dart';
import '../Models/Menu/ModifierSelectionModel.dart';
import '../Models/Menu/ProductModel.dart';
import '../Models/TableSession/TableSessionApi.dart';
import '../Models/TableSession/TableSessionModel.dart';
import 'states.dart';

typedef ResolveTableRequest = Future<KApiResponse> Function(String qrId);
typedef LoadMenuRequest =
    Future<KApiResponse> Function(TableSessionModel session);

/// App-scoped state that outlives routes: the open table session, its menu
/// and the cart. Views rebuild on the matching [AppStates] subclass.
class AppCubit extends Cubit<AppStates> {
  AppCubit({
    ResolveTableRequest? resolveTableRequest,
    LoadMenuRequest? loadMenuRequest,
    String Function()? cartLineId,
  }) : _resolveTableRequest =
           resolveTableRequest ??
           ((qrId) => TableSessionApi.getDetails(qrId: qrId)),
       _loadMenuRequest =
           loadMenuRequest ?? ((session) => MenuApi.getAll(session: session)),
       _cartLineId = cartLineId ?? _defaultCartLineId,
       super(InitialAppStates());

  static AppCubit get(BuildContext context) => BlocProvider.of(context);

  final ResolveTableRequest _resolveTableRequest;
  final LoadMenuRequest _loadMenuRequest;
  final String Function() _cartLineId;

  void update() {
    emit(InitialAppStates());
  }

  /// Names, descriptions and categories come localized from the POS, so the
  /// open session, menu and cart lines are re-fetched in the new language.
  Future<void> onLanguageChanged() async {
    await refreshSession();
    final current = session;
    if (current == null || menu.status == MenuStatus.initial) return;
    final products = await refreshMenu(current);
    if (products != null) syncCartProducts(products);
  }

  // =========================================
  // Table session

  TableSessionStatus sessionStatus = TableSessionStatus.initial;
  String? sessionQrId;
  TableSessionModel? session;
  AppException? sessionError;

  bool get isSessionLoading => sessionStatus == TableSessionStatus.loading;
  bool get isSessionLoaded =>
      sessionStatus == TableSessionStatus.loaded && session != null;

  /// Resolves [qrId] once; on success binds the cart to the table and warms
  /// the menu so it is ready by the time the guest taps through.
  Future<void> resolveTable(String qrId) async {
    final id = qrId.trim();
    if (sessionQrId == id && (isSessionLoaded || isSessionLoading)) return;

    _setSession(TableSessionStatus.loading, id);
    final response = await _resolveTableRequest(id);
    if (isClosed || sessionQrId != id) return;
    final resolved = response.data;
    if (resolved is TableSessionModel) {
      _setSession(TableSessionStatus.loaded, id, session: resolved);
      bindCart(resolved.qrId);
      loadMenu(resolved);
    } else {
      _setSession(
        TableSessionStatus.failure,
        id,
        error: response.error ?? const UnexpectedException(),
      );
    }
  }

  /// Re-fetches the loaded session (e.g. after a language change) without
  /// showing a loading state; keeps the current session on failure.
  Future<void> refreshSession() async {
    final qrId = sessionQrId;
    if (qrId == null || !isSessionLoaded) return;
    final response = await _resolveTableRequest(qrId);
    if (isClosed || sessionQrId != qrId) return;
    final resolved = response.data;
    if (resolved is TableSessionModel) {
      _setSession(TableSessionStatus.loaded, qrId, session: resolved);
    }
  }

  Future<void> retrySession() async {
    final qrId = sessionQrId;
    if (qrId == null) return;
    _setSession(TableSessionStatus.initial, null);
    await resolveTable(qrId);
  }

  void _setSession(
    TableSessionStatus status,
    String? qrId, {
    TableSessionModel? session,
    AppException? error,
  }) {
    sessionStatus = status;
    sessionQrId = qrId;
    this.session = session;
    sessionError = error;
    emit(TableSessionAppStates(status, session: session, error: error));
  }

  // =========================================
  // Menu

  MenuModel menu = const MenuModel();
  TableSessionModel? _menuSession;

  Future<void> loadMenu(TableSessionModel session, {bool force = false}) async {
    if (!force &&
        _menuSession == session &&
        (menu.isLoaded || menu.isLoading)) {
      return;
    }
    _menuSession = session;
    _setMenu(menu.copyWith(status: MenuStatus.loading));
    final response = await _loadMenuRequest(session);
    if (isClosed || _menuSession != session) return;
    final products = response.data;
    if (products is List<ProductModel>) {
      _setMenu(MenuModel(status: MenuStatus.loaded, products: products));
    } else {
      _setMenu(
        menu.copyWith(
          status: MenuStatus.failure,
          error: response.error ?? const UnexpectedException(),
        ),
      );
    }
  }

  /// Re-fetches the menu for [session] (e.g. after a language change) while
  /// keeping the current list on screen. Returns the new products, or null
  /// if the refresh failed.
  Future<List<ProductModel>?> refreshMenu(TableSessionModel session) async {
    if (!menu.isLoaded) {
      await loadMenu(session, force: true);
      return menu.isLoaded ? menu.products : null;
    }
    _menuSession = session;
    final response = await _loadMenuRequest(session);
    if (isClosed) return null;
    final products = response.data;
    if (products is! List<ProductModel>) return null;
    _setMenu(MenuModel(status: MenuStatus.loaded, products: products));
    return products;
  }

  Future<void> retryMenu() async {
    final session = _menuSession;
    if (session != null) await loadMenu(session, force: true);
  }

  void _setMenu(MenuModel next) {
    menu = next;
    emit(MenuAppStates(next));
  }

  // =========================================
  // Cart

  static const int maxQuantityPerLine = 99;

  CartModel cart = const CartModel();

  static int _seq = 0;
  static String _defaultCartLineId() =>
      'line_${DateTime.now().microsecondsSinceEpoch}_${_seq++}';

  void bindCart(String qrId) {
    if (cart.qrId == qrId) return;
    _setCart(CartModel(qrId: qrId));
  }

  /// Adds [product]; merges into an existing line with the same options and
  /// notes.
  void addProduct(
    ProductModel product, {
    List<SelectedOptionModel> options = const [],
    int quantity = 1,
    String notes = '',
  }) {
    if (quantity <= 0 || !product.isAvailable) return;

    final candidate = CartItemModel(
      id: _cartLineId(),
      product: product,
      quantity: quantity.clamp(1, maxQuantityPerLine),
      selectedOptions: List.unmodifiable(options),
      notes: _cleanNotes(notes),
    );

    final index = cart.items.indexWhere(
      (i) => i.configurationKey == candidate.configurationKey,
    );
    if (index == -1) {
      _setCart(cart.copyWith(items: [...cart.items, candidate]));
      return;
    }

    final existing = cart.items[index];
    _replaceCartLine(
      index,
      existing.copyWith(
        quantity: (existing.quantity + quantity).clamp(1, maxQuantityPerLine),
      ),
    );
  }

  void incrementCartLine(String itemId) => _updateQuantityBy(itemId, 1);

  /// Removes the line when the quantity would drop below 1.
  void decrementCartLine(String itemId) => _updateQuantityBy(itemId, -1);

  void setCartLineQuantity(String itemId, int quantity) {
    final index = _cartLineIndex(itemId);
    if (index == -1) return;
    if (quantity <= 0) {
      removeCartLine(itemId);
      return;
    }
    _replaceCartLine(
      index,
      cart.items[index].copyWith(
        quantity: quantity.clamp(1, maxQuantityPerLine),
      ),
    );
  }

  void updateCartLineNotes(String itemId, String notes) {
    final index = _cartLineIndex(itemId);
    if (index == -1) return;
    _replaceCartLine(
      index,
      cart.items[index].copyWith(notes: _cleanNotes(notes)),
    );
  }

  void removeCartLine(String itemId) {
    _setCart(
      cart.copyWith(items: cart.items.where((i) => i.id != itemId).toList()),
    );
  }

  /// Re-inserts a line removed by mistake (used by the "Undo" snackbar).
  void restoreCartLine(CartItemModel item, int index) {
    final items = [...cart.items];
    items.insert(index.clamp(0, items.length), item);
    _setCart(cart.copyWith(items: items));
  }

  /// Swaps each line's product and options for the matching ones (by id) in
  /// a freshly loaded menu, e.g. after a language change or a `422`.
  /// Lines whose product is gone are dropped, and so are options that no
  /// longer exist.
  void syncCartProducts(List<ProductModel> products) {
    if (cart.items.isEmpty) return;
    final byId = {for (final p in products) p.id: p};
    final items = [
      for (final item in cart.items)
        if (byId[item.product.id] case final product?)
          item.copyWith(
            product: product,
            selectedOptions: [
              for (final picked in item.selectedOptions)
                if (product
                        .modifierById(picked.modifierId)
                        ?.optionById(picked.option.id)
                    case final option?)
                  picked.copyWith(option: option),
            ],
          ),
    ];
    _setCart(cart.copyWith(items: items));
  }

  void clearCart() => _setCart(CartModel(qrId: cart.qrId));

  void _updateQuantityBy(String itemId, int delta) {
    final index = _cartLineIndex(itemId);
    if (index == -1) return;
    setCartLineQuantity(itemId, cart.items[index].quantity + delta);
  }

  int _cartLineIndex(String itemId) =>
      cart.items.indexWhere((i) => i.id == itemId);

  void _replaceCartLine(int index, CartItemModel item) {
    final items = [...cart.items]..[index] = item;
    _setCart(cart.copyWith(items: items));
  }

  void _setCart(CartModel next) {
    final previous = cart;
    cart = next;
    emit(CartAppStates(previous, next));
  }

  static String _cleanNotes(String notes) {
    final trimmed = notes.trim();
    return trimmed.length > CartItemModel.maxNotesLength
        ? trimmed.substring(0, CartItemModel.maxNotesLength)
        : trimmed;
  }
}
