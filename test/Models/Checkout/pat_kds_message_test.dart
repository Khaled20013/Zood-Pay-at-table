import 'package:flutter_test/flutter_test.dart';
import 'package:zood_pay_at_table/Models/Cart/CartItemModel.dart';
import 'package:zood_pay_at_table/Models/Checkout/PatKdsMessage.dart';
import 'package:zood_pay_at_table/Models/Menu/ModifierSelectionModel.dart';
import 'package:zood_pay_at_table/Models/Menu/ProductModel.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('PatKdsMessage', () {
    test('matches Self Order Multipeer wire shape', () {
      const items = [
        CartItemModel(
          id: 'line_0',
          product: karakTea,
          quantity: 2,
          notes: 'extra hot',
          selectedOptions: [
            SelectedOptionModel(modifierId: 'mod_size', option: large, quantity: 1),
            SelectedOptionModel(
              modifierId: 'mod_syrup',
              option: vanilla,
              quantity: 2,
            ),
          ],
        ),
      ];

      final message = PatKdsMessage.build(
        orderNumber: 509,
        orderId: 'uuid-1',
        items: items,
      );

      expect(
        message,
        '------509--[['
        '"ProductName":"Karak Tea",'
        '"qtyAddded":2,'
        '"itemStatus":"0",'
        '"NotesProduct":"extra hot",'
        '"NotesForOrder":"",'
        '"Modifiers":",1 X Large,1 X Vanilla,1 X Vanilla",'
        '"ProductId":"prd_karak_tea",'
        '"Edited":"0",'
        '"LocalIdForProduct":"0",'
        '"void_Product":"NO",'
        '"categoryId":"cat_hot",'
        '"orderTypePickUp":"0",'
        '"arabicName":"",'
        '"IdProductRows":"0",'
        '"PrepTime":"600",'
        '"iscombo":"0",'
        '"ComboGroupCount":0,'
        '"CourseName":"Course 1",'
        '"courseActivate":"0",'
        '"couserCount":"1",'
        '"sendtoKitchenKDS":"YES"'
        ']]----NO--0--PayAtTable--0--uuid-1',
      );
    });

    test('joins multiple products like Self Order', () {
      final message = PatKdsMessage.build(
        orderNumber: 1,
        orderId: 'id',
        items: const [
          CartItemModel(id: 'a', product: karakTea, quantity: 1),
          CartItemModel(id: 'b', product: mintLemonade, quantity: 1),
        ],
      );

      expect(message, startsWith('------1--[['));
      expect(message, contains('"ProductName":"Karak Tea"'));
      expect(message, contains(', ["ProductName":"Mint Lemonade"'));
      expect(message, endsWith('--NO--0--PayAtTable--0--id'));
    });

    test('falls back when device or cashier fields scrub to empty', () {
      final message = PatKdsMessage.build(
        orderNumber: 7,
        orderId: 'oid',
        items: const [CartItemModel(id: 'a', product: karakTea, quantity: 1)],
        // Brackets / whitespace scrub to empty → wire defaults kick in.
        deviceName: '[]',
        cashierId: '   ',
      );
      expect(message, endsWith('--NO--0--PayAtTable--0--oid'));
    });

    test('scrubs unsafe characters from product names', () {
      const product = ProductModel(
        id: 'prd_scrub',
        name: 'Tea [hot]--extra',
        description: '',
        price: 1,
        category: 'Hot',
        categoryId: 'cat_hot',
      );
      final message = PatKdsMessage.build(
        orderNumber: 1,
        orderId: 'id',
        items: const [CartItemModel(id: 'line_0', product: product, quantity: 1)],
      );
      expect(message, contains('"ProductName":"Tea  hot —extra"'));
      expect(message, isNot(contains('--extra')));
    });
  });
}
