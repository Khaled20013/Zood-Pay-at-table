import '../../../../core/network/localized_name_model.dart';
import '../../domain/entities/product.dart';
import 'product_model.dart';

/// Joins the categories, products and modifiers responses into the menu:
/// products grouped by category `index`, unknown categories last under
/// "Other items", each product's modifiers resolved by `modifier_id`.
abstract final class MenuMapper {
  static List<Product> toProducts({
    required List<CategoryModel> categories,
    required List<ProductModel> products,
    required List<ModifierModel> modifiers,
    required String languageCode,
  }) {
    final sortedCategories = [...categories]
      ..sort((a, b) => a.index.compareTo(b.index));
    final modifiersById = {for (final m in modifiers) m.id: m};
    final otherLabel = languageCode == 'ar' ? 'أصناف أخرى' : 'Other items';

    final groups = <String, List<Product>>{
      for (final c in sortedCategories) c.id: [],
      Product.otherCategoryId: [],
    };
    final categoriesById = {for (final c in sortedCategories) c.id: c};

    for (final model in products) {
      final category = categoriesById[model.categoryId];
      final product = Product(
        id: model.id,
        name: localizedText(model.name, model.nameLocalized, languageCode),
        description: localizedText(
          model.description ?? '',
          model.descriptionLocalized,
          languageCode,
        ),
        price: model.price,
        category: category == null
            ? otherLabel
            : localizedText(
                category.name,
                category.nameLocalized,
                languageCode,
              ),
        categoryId: category?.id ?? Product.otherCategoryId,
        imageUrl: _nonEmpty(model.image),
        modifiers: _modifiersFor(model, modifiersById, languageCode),
      );
      groups[product.categoryId]!.add(product);
    }
    return [for (final group in groups.values) ...group];
  }

  static List<ProductModifier> _modifiersFor(
    ProductModel product,
    Map<String, ModifierModel> modifiersById,
    String languageCode,
  ) {
    final refs = [...product.modifiers]
      ..sort((a, b) => a.index.compareTo(b.index));
    return [
      for (final ref in refs)
        ?_resolve(ref, modifiersById[ref.modifierId], languageCode),
    ];
  }

  /// Null when the modifier is unknown or all its options are excluded.
  static ProductModifier? _resolve(
    ProductModifierModel ref,
    ModifierModel? modifier,
    String languageCode,
  ) {
    if (modifier == null) return null;
    final excluded = ref.excludedOptionsIds.toSet();
    final options = [
      for (final o in modifier.options)
        if (!excluded.contains(o.id))
          ModifierOption(
            id: o.id,
            name: localizedText(o.name, o.nameLocalized, languageCode),
            price: o.price,
          ),
    ];
    if (options.isEmpty) return null;
    final visibleIds = {for (final o in options) o.id};
    return ProductModifier(
      modifierId: modifier.id,
      name: localizedText(modifier.name, modifier.nameLocalized, languageCode),
      options: options,
      minimumOptions: ref.minimumOptions,
      maximumOptions: ref.maximumOptions,
      freeOptions: ref.freeOptions,
      uniqueOptions: ref.uniqueOptions,
      defaultOptionIds: [
        for (final id in ref.defaultOptionsIds)
          if (visibleIds.contains(id)) id,
      ],
    );
  }

  static String? _nonEmpty(String? value) =>
      value == null || value.trim().isEmpty ? null : value;
}
