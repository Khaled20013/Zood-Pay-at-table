import 'package:flutter/widgets.dart';

import '../../../../AppRoutes/CheckoutRoutes.dart';
import '../../../../Bloc/AppCubit.dart';
import '../../../../Models/Menu/MenuModel.dart';
import '../../../../Models/Menu/ModifierSelectionModel.dart';
import '../../../../Models/Menu/ProductModel.dart';
import '../../../../Models/TableSession/TableSessionModel.dart';

class MenuScreenController {
  final Function() refresh;
  final AppCubit appCubit;
  final TableSessionModel session;

  MenuScreenController(this.refresh, {required this.appCubit, required this.session});

  final TextEditingController searchController = TextEditingController();
  String query = '';

  /// Language-neutral, so the filter survives a menu re-fetch in another
  /// language. Null means "All".
  String? selectedCategoryId;

  MenuModel get menu => appCubit.menu;

  String get selectedCategory => menu.categoryNameFor(selectedCategoryId);

  List<ProductModel> get visibleProducts => menu.visibleProducts(
    selectedCategory: selectedCategory,
    query: query,
  );

  void update() {
    refresh();
  }

  Future<void> onInit() async {
    appCubit.loadMenu(session);
    update();
  }

  void dispose() {
    searchController.dispose();
  }

  Future<void> retry() => appCubit.retryMenu();

  void search(String value) {
    query = value;
    update();
  }

  void resetFilters() {
    searchController.clear();
    query = '';
    selectedCategoryId = null;
    update();
  }

  /// Returns false when [product] needs the details sheet (it has options,
  /// or its defaults don't form a valid selection).
  bool quickAdd(ProductModel product) {
    final selection = ModifierSelection.initial(product);
    if (product.hasModifiers || !selection.isValid) return false;
    appCubit.addProduct(product, options: selection.selectedOptions);
    return true;
  }

  void openCheckout() => CheckoutRoutes.openCartSummaryScreen(qrId: session.qrId);
}
