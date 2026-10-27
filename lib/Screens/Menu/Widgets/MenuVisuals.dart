import 'package:flutter/material.dart';

import 'package:zood_pay_at_table/Styles/AppColors.dart';

/// Icon and tints for a product or category without a photo.
class MenuVisual {
  const MenuVisual(this.icon, this.soft, this.tint);

  final IconData icon;
  final Color soft;
  final Color tint;
}

/// POS category ids are opaque, so the look is guessed from the localized
/// names (English or Arabic), with a stable palette per id as fallback.
abstract final class MenuVisuals {
  static const _iceCream = MenuVisual(
    Icons.icecream_rounded,
    Color(0xFFF1E4FF),
    Color(0xFF8B4DD8),
  );
  static const _dessert = MenuVisual(
    Icons.cake_rounded,
    Color(0xFFFFE0EA),
    Color(0xFFD0436F),
  );
  static const _tea = MenuVisual(
    Icons.emoji_food_beverage_rounded,
    Color(0xFFFBEBD0),
    Color(0xFFB7791F),
  );
  static const _cold = MenuVisual(
    Icons.local_drink_rounded,
    Color(0xFFD6F0FB),
    Color(0xFF1F86B8),
  );
  static const _coffee = MenuVisual(
    Icons.coffee_rounded,
    Color(0xFFFFE6CC),
    Color(0xFFD9641E),
  );
  static const _bakery = MenuVisual(
    Icons.bakery_dining_rounded,
    Color(0xFFFFF1CC),
    Color(0xFFC98A0B),
  );
  static const _food = MenuVisual(
    Icons.lunch_dining_rounded,
    Color(0xFFDDF5E6),
    Color(0xFF1E9A5A),
  );

  /// Checked in order, so "Iced latte" is cold before it is coffee.
  static const List<(MenuVisual, List<String>)> _rules = [
    (
      _iceCream,
      ['ice cream', 'icecream', 'gelato', 'آيس كريم', 'ايس كريم', 'بوظة'],
    ),
    (
      _dessert,
      [
        'dessert',
        'cake',
        'kunafa',
        'knafeh',
        'cookie',
        'brownie',
        'donut',
        'cheesecake',
        'sweet',
        'حلويات',
        'حلى',
        'كيك',
        'كنافة',
        'كنافه',
        'بسبوسة',
        'دونات',
        'تشيز',
        'براوني',
      ],
    ),
    (_tea, ['tea', 'karak', 'chai', 'matcha', 'شاي', 'شاهي', 'كرك', 'ماتشا']),
    (
      _cold,
      [
        'iced',
        'cold',
        'juice',
        'lemonade',
        'mojito',
        'smoothie',
        'frapp',
        'shake',
        'water',
        'soda',
        'بارد',
        'مثلج',
        'عصير',
        'ليمون',
        'موهيتو',
        'سموذي',
        'فرابي',
        'شيك',
        'مياه',
        'صودا',
      ],
    ),
    (
      _coffee,
      [
        'coffee',
        'espresso',
        'latte',
        'cappuccino',
        'mocha',
        'americano',
        'macchiato',
        'flat white',
        'dallah',
        'hot',
        'قهوة',
        'قهوه',
        'اسبريسو',
        'إسبريسو',
        'لاتيه',
        'كابتشينو',
        'موكا',
        'دلة',
        'ساخن',
      ],
    ),
    (
      _bakery,
      [
        'bakery',
        'croissant',
        'pastr',
        'bread',
        'muffin',
        'معجنات',
        'مخبوزات',
        'كرواسون',
        'خبز',
        'مافن',
      ],
    ),
    (
      _food,
      [
        'burger',
        'pizza',
        'sandwich',
        'salad',
        'breakfast',
        'meal',
        'food',
        'pasta',
        'chicken',
        'برجر',
        'بيتزا',
        'ساندويتش',
        'سلطة',
        'فطور',
        'وجبات',
        'وجبة',
        'باستا',
        'دجاج',
      ],
    ),
  ];

  static const List<List<Color>> _fallbackPalettes = [
    [AppColors.primarySoft, AppColors.primary],
    [Color(0xFFD5F3F0), Color(0xFF138A7E)],
    [Color(0xFFFFE6CC), Color(0xFFD9641E)],
    [Color(0xFFF1E4FF), Color(0xFF8B4DD8)],
    [Color(0xFFFFE0EA), Color(0xFFD0436F)],
  ];

  static final RegExp _separator = RegExp(r'[\s\-_,./&()]+');

  /// Keywords match the start of a word (so "steak" is not "tea"); Arabic
  /// words may carry the definite article "ال".
  static bool _matches(List<String> tokens, String text, String word) {
    if (word.contains(' ')) return text.contains(word);
    for (final token in tokens) {
      if (token.startsWith(word)) return true;
      if (token.startsWith('ال') && token.substring(2).startsWith(word)) {
        return true;
      }
    }
    return false;
  }

  /// The first of [hints] that matches a rule wins; [seed] (usually the
  /// category id) picks the fallback palette.
  static MenuVisual of(List<String?> hints, {String? seed}) {
    for (final hint in hints) {
      final text = hint?.toLowerCase().trim() ?? '';
      if (text.isEmpty) continue;
      final tokens = text.split(_separator);
      for (final (visual, words) in _rules) {
        if (words.any((w) => _matches(tokens, text, w))) return visual;
      }
    }
    final key = seed ?? hints.whereType<String>().join();
    final hash = key.codeUnits.fold(0, (h, c) => (h * 31 + c) & 0x7fffffff);
    final [soft, tint] = _fallbackPalettes[hash % _fallbackPalettes.length];
    return MenuVisual(Icons.restaurant_rounded, soft, tint);
  }

  static MenuVisual forCategory(String name, {String? id}) =>
      of([name, id], seed: id ?? name);
}
