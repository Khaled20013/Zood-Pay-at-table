import 'package:flutter/widgets.dart';

import '../../../../Bloc/AppCubit.dart';
import '../../../../Helper/CurrencyFormatter.dart';
import '../../../../Models/Menu/ModifierSelectionModel.dart';
import '../../../../Models/Menu/ProductModel.dart';

class ProductDetailsController {
  final Function() refresh;
  final AppCubit appCubit;
  final ProductModel product;

  ProductDetailsController(
    this.refresh, {
    required this.appCubit,
    required this.product,
  }) : selection = ModifierSelection.initial(product);

  final TextEditingController notesController = TextEditingController();
  ModifierSelection selection;
  int quantity = 1;

  /// Set once the guest taps "Add" with a required modifier left empty.
  bool showMissing = false;

  double get total => CurrencyFormatter.roundMoney(selection.unitPrice * quantity);

  void update() {
    refresh();
  }

  Future<void> onInit() async {
    update();
  }

  void dispose() {
    notesController.dispose();
  }

  void select(ModifierSelection next) {
    selection = next;
    update();
  }

  void increment() {
    quantity++;
    update();
  }

  void decrement() {
    quantity--;
    update();
  }

  /// Returns false (and flags [showMissing]) while a required modifier is
  /// still empty.
  bool addToCart() {
    if (!selection.isValid) {
      showMissing = true;
      update();
      return false;
    }
    appCubit.addProduct(
      product,
      options: selection.selectedOptions,
      quantity: quantity,
      notes: notesController.text,
    );
    return true;
  }
}
