part of 'menu_cubit.dart';

enum MenuStatus { initial, loading, loaded, failure }

class MenuState extends Equatable {
  const MenuState({
    this.status = MenuStatus.initial,
    this.products = const [],
    this.selectedCategory = MenuState.allCategory,
    this.query = '',
    this.error,
  });

  static const String allCategory = 'All';

  final MenuStatus status;
  final List<Product> products;
  final String selectedCategory;
  final String query;
  final AppException? error;

  /// Categories in the order the POS returned them, prefixed with "All".
  List<String> get categories {
    final seen = <String>{};
    return [
      allCategory,
      for (final p in products)
        if (seen.add(p.category)) p.category,
    ];
  }

  List<Product> get visibleProducts {
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

  MenuState copyWith({
    MenuStatus? status,
    List<Product>? products,
    String? selectedCategory,
    String? query,
    AppException? error,
  }) {
    return MenuState(
      status: status ?? this.status,
      products: products ?? this.products,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      query: query ?? this.query,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, products, selectedCategory, query, error];
}
