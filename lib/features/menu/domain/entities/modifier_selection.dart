import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import 'product.dart';

/// An option the guest picked, with its units **per one product unit**.
class SelectedOption extends Equatable {
  const SelectedOption({
    required this.modifierId,
    required this.option,
    required this.quantity,
  }) : assert(quantity > 0);

  final String modifierId;
  final ModifierOption option;
  final int quantity;

  SelectedOption copyWith({ModifierOption? option, int? quantity}) =>
      SelectedOption(
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
  factory ModifierSelection.initial(Product product) {
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

  final Product product;

  /// modifierId → optionId → units, in the order the guest picked them
  /// (free units go to the first picks).
  final Map<String, Map<String, int>> _units;

  int quantityOf(ProductModifier modifier, ModifierOption option) =>
      _units[modifier.modifierId]?[option.id] ?? 0;

  int countFor(ProductModifier modifier) =>
      _sum(_units[modifier.modifierId] ?? const {});

  bool isSatisfied(ProductModifier modifier) =>
      countFor(modifier) >= modifier.minimumOptions;

  /// Required modifiers that still need picks; adding is blocked until empty.
  List<ProductModifier> get missing => [
    for (final m in product.modifiers)
      if (!isSatisfied(m)) m,
  ];

  bool get isValid => missing.isEmpty;

  bool canIncrease(ProductModifier modifier, ModifierOption option) {
    if (modifier.uniqueOptions && quantityOf(modifier, option) > 0) {
      return false;
    }
    return !modifier.hasLimit || countFor(modifier) < modifier.maximumOptions;
  }

  /// Checkbox / radio behaviour for unique options. A single-choice modifier
  /// swaps its pick; at the limit, picking another option does nothing.
  ModifierSelection toggle(ProductModifier modifier, ModifierOption option) {
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

  ModifierSelection increment(ProductModifier modifier, ModifierOption option) {
    if (!canIncrease(modifier, option)) return this;
    return _set(modifier, option, quantityOf(modifier, option) + 1);
  }

  ModifierSelection decrement(ProductModifier modifier, ModifierOption option) {
    final current = quantityOf(modifier, option);
    if (current == 0) return this;
    return _set(modifier, option, current - 1);
  }

  /// Picks in modifier order, then in the order they were picked.
  List<SelectedOption> get selectedOptions => [
    for (final modifier in product.modifiers)
      for (final MapEntry(key: id, value: units)
          in (_units[modifier.modifierId] ?? const <String, int>{}).entries)
        if (modifier.optionById(id) case final option? when units > 0)
          SelectedOption(
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
  static double optionsPrice(Product product, List<SelectedOption> options) {
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
    ProductModifier modifier,
    ModifierOption option,
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
    ProductModifier modifier,
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
