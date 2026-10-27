import 'package:equatable/equatable.dart';

import '../../Helper/CurrencyFormatter.dart';
import 'CartItemModel.dart';

/// The guest's order before paying, held by `AppCubit`.
class CartModel extends Equatable {
  const CartModel({this.items = const [], this.qrId});

  final List<CartItemModel> items;

  /// Table the cart belongs to; scanning another table starts a fresh cart.
  final String? qrId;

  bool get isEmpty => items.isEmpty;

  int get totalQuantity => items.fold(0, (sum, i) => sum + i.quantity);

  /// Sum of the lines before VAT.
  double get subtotal =>
      CurrencyFormatter.roundMoney(items.fold(0.0, (s, i) => s + i.lineTotal));

  /// Estimated VAT added on top of [subtotal]; the server charges the
  /// exact amount.
  double vat(double vatRate) =>
      CurrencyFormatter.roundMoney(subtotal * vatRate);

  double total(double vatRate) =>
      CurrencyFormatter.roundMoney(subtotal + vat(vatRate));

  int quantityOf(String productId) => items
      .where((i) => i.product.id == productId)
      .fold(0, (sum, i) => sum + i.quantity);

  CartModel copyWith({List<CartItemModel>? items, String? qrId}) =>
      CartModel(items: items ?? this.items, qrId: qrId ?? this.qrId);

  @override
  List<Object?> get props => [items, qrId];
}
