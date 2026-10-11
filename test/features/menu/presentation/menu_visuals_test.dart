import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zood_pay_at_table/features/menu/presentation/widgets/menu_visuals.dart';

void main() {
  IconData iconOf(String text) => MenuVisuals.of([text]).icon;

  test('guesses the icon from English and Arabic names', () {
    expect(iconOf('Karak Tea'), Icons.emoji_food_beverage_rounded);
    expect(iconOf('Saudi Coffee Pot'), Icons.coffee_rounded);
    expect(iconOf('Kunafa with Cream'), Icons.cake_rounded);
    expect(iconOf('مشروبات باردة'), Icons.local_drink_rounded);
    expect(iconOf('القهوة السعودية'), Icons.coffee_rounded);
  });

  test('cold wins over coffee for iced drinks', () {
    expect(iconOf('Iced Spanish Latte'), Icons.local_drink_rounded);
  });

  test('matches whole-word starts only', () {
    expect(iconOf('Ribeye steak'), isNot(Icons.emoji_food_beverage_rounded));
  });

  test('falls back to the next hint, then a stable palette', () {
    expect(
      MenuVisuals.of(['Spanish', 'Hot Beverages']).icon,
      Icons.coffee_rounded,
    );
    final a = MenuVisuals.of(['Specials'], seed: 'cat_42');
    final b = MenuVisuals.of(['Specials'], seed: 'cat_42');
    expect(a.icon, Icons.restaurant_rounded);
    expect(a.tint, b.tint);
  });
}
