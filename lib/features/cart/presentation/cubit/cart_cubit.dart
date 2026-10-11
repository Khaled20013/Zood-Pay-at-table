import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/cart_item.dart';
import '../../../menu/domain/entities/modifier_selection.dart';
import '../../../menu/domain/entities/product.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit({String Function()? idGenerator})
    : _idGenerator = idGenerator ?? _defaultIdGenerator,
      super(const CartState());

  static const int maxQuantityPerLine = 99;

  final String Function() _idGenerator;

  static int _seq = 0;
  static String _defaultIdGenerator() =>
      'line_${DateTime.now().microsecondsSinceEpoch}_${_seq++}';

  void bindSession(String qrId) {
    if (state.qrId == qrId) return;
    emit(CartState(qrId: qrId));
  }

  /// Adds [product]; merges into an existing line with the same options and
  /// notes.
  void addProduct(
    Product product, {
    List<SelectedOption> options = const [],
    int quantity = 1,
    String notes = '',
  }) {
    if (quantity <= 0 || !product.isAvailable) return;

    final candidate = CartItem(
      id: _idGenerator(),
      product: product,
      quantity: quantity.clamp(1, maxQuantityPerLine),
      selectedOptions: List.unmodifiable(options),
      notes: _cleanNotes(notes),
    );

    final index = state.items.indexWhere(
      (i) => i.configurationKey == candidate.configurationKey,
    );
    if (index == -1) {
      emit(state.copyWith(items: [...state.items, candidate]));
      return;
    }

    final existing = state.items[index];
    _replaceAt(
      index,
      existing.copyWith(
        quantity: (existing.quantity + quantity).clamp(1, maxQuantityPerLine),
      ),
    );
  }

  void increment(String itemId) => _updateQuantityBy(itemId, 1);

  /// Removes the line when the quantity would drop below 1.
  void decrement(String itemId) => _updateQuantityBy(itemId, -1);

  void setQuantity(String itemId, int quantity) {
    final index = _indexOf(itemId);
    if (index == -1) return;
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }
    _replaceAt(
      index,
      state.items[index].copyWith(
        quantity: quantity.clamp(1, maxQuantityPerLine),
      ),
    );
  }

  void updateNotes(String itemId, String notes) {
    final index = _indexOf(itemId);
    if (index == -1) return;
    _replaceAt(index, state.items[index].copyWith(notes: _cleanNotes(notes)));
  }

  void removeItem(String itemId) {
    emit(
      state.copyWith(items: state.items.where((i) => i.id != itemId).toList()),
    );
  }

  /// Re-inserts a line removed by mistake (used by the "Undo" snackbar).
  void restoreItem(CartItem item, int index) {
    final items = [...state.items];
    items.insert(index.clamp(0, items.length), item);
    emit(state.copyWith(items: items));
  }

  /// Swaps each line's product and options for the matching ones (by id) in
  /// a freshly loaded menu, e.g. after a language change or a `422`.
  /// Lines whose product is gone are dropped, and so are options that no
  /// longer exist.
  void syncProducts(List<Product> products) {
    if (state.items.isEmpty) return;
    final byId = {for (final p in products) p.id: p};
    final items = [
      for (final item in state.items)
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
    emit(state.copyWith(items: items));
  }

  void clear() => emit(CartState(qrId: state.qrId));

  void _updateQuantityBy(String itemId, int delta) {
    final index = _indexOf(itemId);
    if (index == -1) return;
    setQuantity(itemId, state.items[index].quantity + delta);
  }

  int _indexOf(String itemId) => state.items.indexWhere((i) => i.id == itemId);

  void _replaceAt(int index, CartItem item) {
    final items = [...state.items]..[index] = item;
    emit(state.copyWith(items: items));
  }

  static String _cleanNotes(String notes) {
    final trimmed = notes.trim();
    return trimmed.length > CartItem.maxNotesLength
        ? trimmed.substring(0, CartItem.maxNotesLength)
        : trimmed;
  }
}
