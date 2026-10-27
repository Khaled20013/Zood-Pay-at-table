import 'package:equatable/equatable.dart';

import '../../Helper/LocalizedText.dart';
import '../../Helper/path_selector_base.dart';
import 'CategoryModel.dart';
import 'ModifierModel.dart';

/// One choice of a modifier, e.g. "Large" of "Size". [price] may be 0.
class ModifierOptionModel extends Equatable {
  const ModifierOptionModel({
    required this.id,
    required this.name,
    required this.price,
  });

  /// [name] is resolved for [languageCode].
  factory ModifierOptionModel.fromJson(
    Map<String, dynamic>? json, {
    required String languageCode,
  }) => ModifierOptionModel(
    id: jsonString(json?.select('id')),
    name: localizedText(
      jsonString(json?.select('name')),
      jsonStringOrNull(json?.select('name_localized')),
      languageCode,
    ),
    price: jsonDouble(json?.select('price')),
  );

  final String id;
  final String name;
  final double price;

  @override
  List<Object?> get props => [id, name, price];
}

/// A modifier as configured on one product: the name and options come from
/// `/modifiers`, the rules from the product's `modifiers[]` entry.
class ProductModifierModel extends Equatable {
  const ProductModifierModel({
    required this.modifierId,
    required this.name,
    required this.options,
    this.minimumOptions = 0,
    this.maximumOptions = 0,
    this.freeOptions = 0,
    this.uniqueOptions = true,
    this.defaultOptionIds = const [],
  });

  final String modifierId;
  final String name;

  /// Options shown for this product (`excluded_options_ids` removed).
  final List<ModifierOptionModel> options;

  /// Units the guest must pick; `> 0` makes the modifier required.
  final int minimumOptions;

  /// Units the guest may pick; `0` = no limit, `1` = single choice.
  final int maximumOptions;

  /// Units of this modifier that are not charged.
  final int freeOptions;

  /// Each option at most once (no quantity per option).
  final bool uniqueOptions;

  /// Options pre-selected (quantity 1) when the product opens.
  final List<String> defaultOptionIds;

  /// Joins a product's `modifiers[]` entry ([json]: rules only) with the
  /// catalog [modifier] (name and options). Null when the modifier is
  /// unknown or all its options are excluded.
  static ProductModifierModel? resolve(
    Map<String, dynamic> json,
    ModifierModel? modifier,
  ) {
    if (modifier == null) return null;
    final excluded = jsonStringList(json['excluded_options_ids']).toSet();
    final options = [
      for (final o in modifier.options)
        if (!excluded.contains(o.id)) o,
    ];
    if (options.isEmpty) return null;
    final visibleIds = {for (final o in options) o.id};
    return ProductModifierModel(
      modifierId: modifier.id,
      name: modifier.name,
      options: options,
      minimumOptions: jsonInt(json['minimum_options']),
      maximumOptions: jsonInt(json['maximum_options']),
      freeOptions: jsonInt(json['free_options']),
      uniqueOptions: getByType<bool>(json['unique_options']) ?? true,
      defaultOptionIds: [
        for (final id in jsonStringList(json['default_options_ids']))
          if (visibleIds.contains(id)) id,
      ],
    );
  }

  bool get isRequired => minimumOptions > 0;
  bool get isSingleChoice => maximumOptions == 1;
  bool get hasLimit => maximumOptions > 0;

  ModifierOptionModel? optionById(String id) {
    for (final option in options) {
      if (option.id == id) return option;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    modifierId,
    name,
    options,
    minimumOptions,
    maximumOptions,
    freeOptions,
    uniqueOptions,
    defaultOptionIds,
  ];
}

class ProductModel extends Equatable {
  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.categoryId,
    this.imageUrl,
    this.modifiers = const [],
    this.calories,
    this.isAvailable = true,
    this.isPopular = false,
  });

  /// An entry of `GET /public/pay-at-table/products`. [category] is null
  /// when `category_id` is missing or unknown; such products go under
  /// [otherLabel].
  factory ProductModel.fromJson(
    Map<String, dynamic> json, {
    required CategoryModel? category,
    required Map<String, ModifierModel> modifiersById,
    required String languageCode,
    required String otherLabel,
  }) {
    final refs = jsonObjects(json, 'modifiers')
      ..sort((a, b) => jsonInt(a['index']).compareTo(jsonInt(b['index'])));
    final image = jsonStringOrNull(json['image']);
    return ProductModel(
      id: jsonString(json['id']),
      name: localizedText(
        jsonString(json['name']),
        jsonStringOrNull(json['name_localized']),
        languageCode,
      ),
      description: localizedText(
        jsonString(json['description']),
        jsonStringOrNull(json['description_localized']),
        languageCode,
      ),
      price: jsonDouble(json['price']),
      category: category?.name ?? otherLabel,
      categoryId: category?.id ?? otherCategoryId,
      imageUrl: image == null || image.trim().isEmpty ? null : image,
      modifiers: [
        for (final ref in refs)
          ?ProductModifierModel.resolve(
            ref,
            modifiersById[jsonString(ref['modifier_id'])],
          ),
      ],
    );
  }

  /// Joins the categories, products and modifiers responses into the menu:
  /// products grouped by category `index`, unknown categories last under
  /// "Other items", each product's modifiers resolved by `modifier_id`.
  static List<ProductModel> fromMenuJson({
    required Map<String, dynamic>? categories,
    required Map<String, dynamic>? products,
    required Map<String, dynamic>? modifiers,
    required String languageCode,
  }) {
    final sortedCategories = CategoryModel.fromList(
      jsonObjects(categories, 'data'),
      languageCode: languageCode,
    )..sort((a, b) => a.index.compareTo(b.index));
    final modifiersById = {
      for (final m in ModifierModel.fromList(
        jsonObjects(modifiers, 'data'),
        languageCode: languageCode,
      ))
        m.id: m,
    };
    final otherLabel = languageCode == 'ar' ? 'أصناف أخرى' : 'Other items';
    final categoriesById = {for (final c in sortedCategories) c.id: c};
    final groups = <String, List<ProductModel>>{
      for (final c in sortedCategories) c.id: [],
      otherCategoryId: [],
    };
    for (final json in jsonObjects(products, 'data')) {
      final product = ProductModel.fromJson(
        json,
        category: categoriesById[jsonStringOrNull(json['category_id'])],
        modifiersById: modifiersById,
        languageCode: languageCode,
        otherLabel: otherLabel,
      );
      groups[product.categoryId]!.add(product);
    }
    return [for (final group in groups.values) ...group];
  }

  /// [categoryId] of products whose `category_id` is null or unknown; they
  /// are grouped under "Other items" at the end of the menu.
  static const String otherCategoryId = '_other';

  final String id;
  final String name;
  final String description;

  /// Price of one unit, before modifiers.
  final double price;

  /// Localized category name.
  final String category;
  final String? categoryId;
  final String? imageUrl;

  /// Sorted by the product's modifier `index`.
  final List<ProductModifierModel> modifiers;
  final int? calories;
  final bool isAvailable;
  final bool isPopular;

  bool get hasModifiers => modifiers.isNotEmpty;

  ProductModifierModel? modifierById(String id) {
    for (final modifier in modifiers) {
      if (modifier.modifierId == id) return modifier;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    category,
    categoryId,
    imageUrl,
    modifiers,
    calories,
    isAvailable,
    isPopular,
  ];
}
