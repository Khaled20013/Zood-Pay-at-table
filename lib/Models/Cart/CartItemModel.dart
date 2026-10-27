import 'package:equatable/equatable.dart';

import 'package:zood_pay_at_table/Helper/CurrencyFormatter.dart';
import 'package:zood_pay_at_table/Models/Menu/ModifierSelectionModel.dart';
import 'package:zood_pay_at_table/Models/Menu/ProductModel.dart';

/// One cart line. Two lines with the same product but different options or
/// notes are kept separate so the kitchen ticket stays accurate.
class CartItemModel extends Equatable {
  const CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    this.selectedOptions = const [],
    this.notes = '',
  }) : assert(quantity > 0);

  static const int maxNotesLength = 250;

  final String id;
  final ProductModel product;
  final int quantity;

  /// Units are per one product unit.
  final List<SelectedOptionModel> selectedOptions;
  final String notes;

  /// Client-side estimate; the server prices the order when charging.
  double get unitPrice => CurrencyFormatter.roundMoney(
    product.price + ModifierSelection.optionsPrice(product, selectedOptions),
  );

  double get lineTotal => CurrencyFormatter.roundMoney(unitPrice * quantity);

  /// "Large · Vanilla ×2"
  String get optionsSummary => selectedOptions
      .map(
        (o) =>
            o.quantity > 1 ? '${o.option.name} ×${o.quantity}' : o.option.name,
      )
      .join(' · ');

  /// Identity used to merge repeated "add" actions into a single line.
  String get configurationKey {
    final options =
        selectedOptions
            .map((o) => '${o.modifierId}:${o.option.id}x${o.quantity}')
            .toList()
          ..sort();
    return '${product.id}|${options.join(',')}|${notes.trim()}';
  }

  CartItemModel copyWith({
    ProductModel? product,
    int? quantity,
    List<SelectedOptionModel>? selectedOptions,
    String? notes,
  }) => CartItemModel(
    id: id,
    product: product ?? this.product,
    quantity: quantity ?? this.quantity,
    selectedOptions: selectedOptions ?? this.selectedOptions,
    notes: notes ?? this.notes,
  );

  @override
  List<Object?> get props => [id, product, quantity, selectedOptions, notes];
}
