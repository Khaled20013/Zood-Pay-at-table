import 'package:flutter_test/flutter_test.dart';
import 'package:zood_pay_at_table/Models/Menu/ModifierSelectionModel.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('ModifierSelection', () {
    test('starts from the default options and is valid', () {
      final selection = ModifierSelection.initial(karakTea);
      expect(selection.quantityOf(sizeModifier, small), 1);
      expect(selection.isValid, isTrue);
      expect(selection.unitPrice, 8.0);
    });

    test('a required modifier without a default blocks adding', () {
      final selection = ModifierSelection.initial(mintLemonade);
      expect(selection.isValid, isFalse);
      expect(selection.missing, [sugarModifier]);

      final picked = selection.toggle(sugarModifier, lessSugar);
      expect(picked.isValid, isTrue);
    });

    test(
      'single choice swaps the pick and cannot be cleared when required',
      () {
        var selection = ModifierSelection.initial(karakTea);
        selection = selection.toggle(sizeModifier, large);
        expect(selection.quantityOf(sizeModifier, small), 0);
        expect(selection.quantityOf(sizeModifier, large), 1);

        selection = selection.toggle(sizeModifier, large);
        expect(selection.quantityOf(sizeModifier, large), 1);
        expect(selection.unitPrice, 13.0);
      },
    );

    test('non-unique options take quantities up to maximum_options', () {
      var selection = ModifierSelection.initial(karakTea);
      selection = selection
          .increment(syrupModifier, vanilla)
          .increment(syrupModifier, vanilla)
          .increment(syrupModifier, caramel)
          .increment(syrupModifier, caramel);
      expect(selection.countFor(syrupModifier), 3);
      expect(selection.quantityOf(syrupModifier, caramel), 1);
      expect(selection.canIncrease(syrupModifier, vanilla), isFalse);

      selection = selection.decrement(syrupModifier, vanilla);
      expect(selection.quantityOf(syrupModifier, vanilla), 1);
      expect(selection.canIncrease(syrupModifier, caramel), isTrue);
    });

    test('free_options makes the first picked units free', () {
      final selection = ModifierSelection.initial(karakTea)
          .increment(syrupModifier, caramel)
          .increment(syrupModifier, vanilla)
          .increment(syrupModifier, vanilla);
      // Caramel (picked first) is free; two vanilla units are charged.
      expect(selection.unitPrice, 8.0 + 2 * 2);
    });

    test('selectedOptions are per one product unit, in modifier order', () {
      final selection = ModifierSelection.initial(karakTea)
          .increment(syrupModifier, vanilla)
          .increment(syrupModifier, vanilla)
          .toggle(sizeModifier, large);
      expect(
        selection.selectedOptions.map(
          (o) => (o.modifierId, o.option.id, o.quantity),
        ),
        [('mod_size', 'opt_large', 1), ('mod_syrup', 'opt_vanilla', 2)],
      );
    });
  });
}
