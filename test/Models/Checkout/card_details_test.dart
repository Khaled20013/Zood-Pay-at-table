import 'package:flutter_test/flutter_test.dart';
import 'package:zood_pay_at_table/Models/Checkout/CardDetailsModel.dart';

void main() {
  test('fromInput normalises to the API format', () {
    final card = CardDetailsModel.fromInput(
      holderName: '  ahmed ali ',
      number: '4111 1111 1111 1111',
      expiry: '8/28',
      cvc: '123',
    );
    expect(card.holderName, 'ahmed ali');
    expect(card.number, '4111111111111111');
    expect(card.expiryMonth, '08');
    expect(card.expiryYear, '2028');
    expect(card.last4, '1111');
  });

  test('never prints the card number or CVC', () {
    const card = CardDetailsModel(
      holderName: 'A',
      number: '4111111111111111',
      expiryMonth: '08',
      expiryYear: '2028',
      cvc: '123',
    );
    expect(card.toString(), isNot(contains('4111111111')));
    expect(card.toString(), isNot(contains('123')));
  });

  test('validation', () {
    expect(CardDetailsModel.isValidNumber('4111 1111 1111 1111'), isTrue);
    expect(CardDetailsModel.isValidNumber('4111 1111 1111 1112'), isFalse);
    final now = DateTime(2026, 10, 11);
    expect(CardDetailsModel.isValidExpiry('10/26', now: now), isTrue);
    expect(CardDetailsModel.isValidExpiry('09/26', now: now), isFalse);
    expect(CardDetailsModel.isValidExpiry('13/30', now: now), isFalse);
    expect(CardDetailsModel.isValidCvc('123'), isTrue);
    expect(CardDetailsModel.isValidCvc('1234'), isTrue);
    expect(CardDetailsModel.isValidCvc('12'), isFalse);
  });
}
