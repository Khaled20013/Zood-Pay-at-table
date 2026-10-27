import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import 'package:zood_pay_at_table/Models/Menu/ProductModel.dart';

/// An option the guest picked, with its units **per one product unit**.
class SelectedOptionModel extends Equatable {
  const SelectedOptionModel({
    required this.modifierId,
    required this.option,
    required this.quantity,
  }) : assert(quantity > 0);

  final String modifierId;
  final ModifierOptionModel option;
  final int quantity;

  SelectedOptionModel copyWith({ModifierOptionModel? option, int? quantity}) =>
      SelectedOptionModel(
        modifierId: modifierId,
        option: option ?? this.option,
        quantity: quantity ?? this.quantity,
      );

  @override
  List<Object?> get props => [modifierId, option, quantity];
}

/// The options picked for one unit of [product], enforcing each modifier's
/// rules. Immutable: every change returns a new selection.
class ModifierSelection extends Equatable {
  const ModifierSelection._(this.product, this._units);

  /// Starts from the modifiers' `default_options_ids`.
  factory ModifierSelection.initial(ProductModel product) {
    final units = <String, Map<String, int>>{};
    for (final modifier in product.modifiers) {
      for (final id in modifier.defaultOptionIds) {
        if (modifier.optionById(id) == null) continue;
        final picked = units.putIfAbsent(modifier.modifierId, () => {});
        if (modifier.hasLimit && _sum(picked) >= modifier.maximumOptions) {
          break;
        }
        picked[id] = 1;
      }
    }
    return ModifierSelection._(product, units);
  }

  final ProductModel product;

  /// modifierId → optionId → units, in the order the guest picked them
  /// (free units go to the first picks).
  final Map<String, Map<String, int>> _units;

  int quantityOf(ProductModifierModel modifier, ModifierOptionModel option) =>
      _units[modifier.modifierId]?[option.id] ?? 0;

  int countFor(ProductModifierModel modifier) =>
      _sum(_units[modifier.modifierId] ?? const {});

  bool isSatisfied(ProductModifierModel modifier) =>
      countFor(modifier) >= modifier.minimumOptions;

  /// Required modifiers that still need picks; adding is blocked until empty.
  List<ProductModifierModel> get missing => [
    for (final m in product.modifiers)
      if (!isSatisfied(m)) m,
  ];

  bool get isValid => missing.isEmpty;

  bool canIncrease(ProductModifierModel modifier, ModifierOptionModel option) {
    if (modifier.uniqueOptions && quantityOf(modifier, option) > 0) {
      return false;
    }
    return !modifier.hasLimit || countFor(modifier) < modifier.maximumOptions;
  }

  /// Checkbox / radio behaviour for unique options. A single-choice modifier
  /// swaps its pick; at the limit, picking another option does nothing.
  ModifierSelection toggle(ProductModifierModel modifier, ModifierOptionModel option) {
    if (quantityOf(modifier, option) > 0) {
      if (modifier.isSingleChoice && modifier.isRequired) return this;
      return _set(modifier, option, 0);
    }
    if (modifier.isSingleChoice) {
      return _replace(modifier, {option.id: 1});
    }
    if (!canIncrease(modifier, option)) return this;
    return _set(modifier, option, 1);
  }

  ModifierSelection increment(ProductModifierModel modifier, ModifierOptionModel option) {
    if (!canIncrease(modifier, option)) return this;
    return _set(modifier, option, quantityOf(modifier, option) + 1);
  }

  ModifierSelection decrement(ProductModifierModel modifier, ModifierOptionModel option) {
    final current = quantityOf(modifier, option);
    if (current == 0) return this;
    return _set(modifier, option, current - 1);
  }

  /// Picks in modifier order, then in the order they were picked.
  List<SelectedOptionModel> get selectedOptions => [
    for (final modifier in product.modifiers)
      for (final MapEntry(key: id, value: units)
          in (_units[modifier.modifierId] ?? const <String, int>{}).entries)
        if (modifier.optionById(id) case final option? when units > 0)
          SelectedOptionModel(
            modifierId: modifier.modifierId,
            option: option,
            quantity: units,
          ),
  ];

  /// Price of one product unit including the chargeable options.
  double get unitPrice =>
      product.price + optionsPrice(product, selectedOptions);

  /// Sum of option prices for one product unit; the first `free_options`
  /// units of each modifier are free.
  static double optionsPrice(ProductModel product, List<SelectedOptionModel> options) {
    var total = 0.0;
    for (final modifier in product.modifiers) {
      var free = modifier.freeOptions;
      for (final picked in options) {
        if (picked.modifierId != modifier.modifierId) continue;
        final freeUnits = math.min(free, picked.quantity);
        free -= freeUnits;
        total += picked.option.price * (picked.quantity - freeUnits);
      }
    }
    return total;
  }

  ModifierSelection _set(
    ProductModifierModel modifier,
    ModifierOptionModel option,
    int units,
  ) {
    final picked = {...?_units[modifier.modifierId]};
    if (units <= 0) {
      picked.remove(option.id);
    } else {
      picked[option.id] = units;
    }
    return _replace(modifier, picked);
  }

  ModifierSelection _replace(
    ProductModifierModel modifier,
    Map<String, int> picked,
  ) => ModifierSelection._(product, {
    ..._units,
    modifier.modifierId: Map.unmodifiable(picked),
  });

  static int _sum(Map<String, int> units) =>
      units.values.fold(0, (sum, n) => sum + n);

  @override
  List<Object?> get props => [product, selectedOptions];
}
