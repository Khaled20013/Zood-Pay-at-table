import 'package:equatable/equatable.dart';

import '../../Helper/Errors/AppException.dart';
import 'ProductModel.dart';

enum MenuStatus { initial, loading, loaded, failure }

/// The table's menu as held by `AppCubit`. Category / search filters are
/// per screen and passed in.
class MenuModel extends Equatable {
  const MenuModel({
    this.status = MenuStatus.initial,
    this.products = const [],
    this.error,
  });

  static const String allCategory = 'All';

  final MenuStatus status;
  final List<ProductModel> products;
  final AppException? error;

  bool get isLoaded => status == MenuStatus.loaded;
  bool get isLoading => status == MenuStatus.loading;

  /// Categories in the order the POS returned them, prefixed with "All".
  List<String> get categories {
    final seen = <String>{};
    return [
      allCategory,
      for (final p in products)
        if (seen.add(p.category)) p.category,
    ];
  }

  List<ProductModel> visibleProducts({
    String selectedCategory = allCategory,
    String query = '',
  }) {
    final q = query.trim().toLowerCase();
    return products
        .where(
          (p) =>
              selectedCategory == allCategory || p.category == selectedCategory,
        )
        .where(
          (p) =>
              q.isEmpty ||
              p.name.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q),
        )
        .toList(growable: false);
  }

  /// Language-neutral id for a category name (null for "All" or unknown).
  String? categoryIdOf(String category) {
    if (category == allCategory) return null;
    for (final p in products) {
      if (p.category == category) return p.categoryId ?? p.category;
    }
    return null;
  }

  /// Inverse of [categoryIdOf]; falls back to [allCategory].
  String categoryNameFor(String? categoryId) {
    if (categoryId == null) return allCategory;
    for (final p in products) {
      if ((p.categoryId ?? p.category) == categoryId) return p.category;
    }
    return allCategory;
  }

  int countFor(String category) => category == allCategory
      ? products.length
      : products.where((p) => p.category == category).length;

  MenuModel copyWith({
    MenuStatus? status,
    List<ProductModel>? products,
    AppException? error,
  }) {
    return MenuModel(
      status: status ?? this.status,
      products: products ?? this.products,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, products, error];
}
