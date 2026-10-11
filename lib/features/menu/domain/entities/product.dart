import 'package:equatable/equatable.dart';

/// One choice of a modifier, e.g. "Large" of "Size". [price] may be 0.
class ModifierOption extends Equatable {
  const ModifierOption({
    required this.id,
    required this.name,
    required this.price,
  });

  final String id;
  final String name;
  final double price;

  @override
  List<Object?> get props => [id, name, price];
}

/// A modifier as configured on one product: the name and options come from
/// `/modifiers`, the rules from the product's `modifiers[]` entry.
class ProductModifier extends Equatable {
  const ProductModifier({
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
  final List<ModifierOption> options;

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

  bool get isRequired => minimumOptions > 0;
  bool get isSingleChoice => maximumOptions == 1;
  bool get hasLimit => maximumOptions > 0;

  ModifierOption? optionById(String id) {
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

class Product extends Equatable {
  const Product({
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
  final List<ProductModifier> modifiers;
  final int? calories;
  final bool isAvailable;
  final bool isPopular;

  bool get hasModifiers => modifiers.isNotEmpty;

  ProductModifier? modifierById(String id) {
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
