import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zood_pay_at_table/core/error/app_exception.dart';
import 'package:zood_pay_at_table/features/cart/domain/entities/cart_item.dart';
import 'package:zood_pay_at_table/features/checkout/domain/entities/card_details.dart';
import 'package:zood_pay_at_table/features/checkout/domain/entities/order_receipt.dart';
import 'package:zood_pay_at_table/features/checkout/domain/repositories/order_repository.dart';
import 'package:zood_pay_at_table/features/checkout/presentation/cubit/checkout_cubit.dart';

import '../../../../helpers/fixtures.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  const card = CardDetails(
    holderName: 'AHMED ALI',
    number: '4111111111111111',
    expiryMonth: '08',
    expiryYear: '2028',
    cvc: '123',
  );
  const items = [CartItem(id: 'l1', product: icedSpanishLatte, quantity: 1)];
  const moreItems = [
    CartItem(id: 'l1', product: icedSpanishLatte, quantity: 2),
  ];
  final receipt = OrderReceipt(
    orderId: 'o1',
    orderNumber: '23',
    reference: '#R000023',
    subtotal: 18,
    taxes: 2.7,
    total: 20.7,
    currency: 'SAR',
    branchName: 'Olaya',
    tableName: 'T5',
    paidAt: DateTime(2026, 10, 11),
  );

  late _MockOrderRepository repository;
  late List<String> sentIds;
  late List<Object> outcomes;
  late int idSeq;

  CheckoutCubit buildCubit() => CheckoutCubit(
    repository: repository,
    newClientOrderId: () => 'id-${idSeq++}',
  );

  setUp(() {
    repository = _MockOrderRepository();
    sentIds = [];
    outcomes = [];
    idSeq = 0;
    registerFallbackValue(card);
    registerFallbackValue(tableSession);
    registerFallbackValue(<CartItem>[]);
    when(
      () => repository.placeOrder(
        session: any(named: 'session'),
        items: any(named: 'items'),
        card: any(named: 'card'),
        clientOrderId: any(named: 'clientOrderId'),
        customerNotes: any(named: 'customerNotes'),
      ),
    ).thenAnswer((invocation) async {
      sentIds.add(invocation.namedArguments[#clientOrderId] as String);
      final next = outcomes.removeAt(0);
      if (next is AppException) throw next;
      return next as OrderReceipt;
    });
  });

  Future<void> pay(CheckoutCubit cubit, {List<CartItem> cart = items}) =>
      cubit.pay(session: tableSession, items: cart, card: card);

  test('success emits the receipt', () async {
    outcomes = [receipt];
    final cubit = buildCubit();
    await pay(cubit);
    expect(cubit.state.status, CheckoutStatus.success);
    expect(cubit.state.receipt, receipt);
  });

  test('retries after a network error or 5xx reuse the same id', () async {
    outcomes = [const NetworkException(), const UnexpectedException(), receipt];
    final cubit = buildCubit();
    await pay(cubit);
    expect(cubit.state.status, CheckoutStatus.failure);
    await pay(cubit);
    await pay(cubit);
    expect(sentIds, ['id-0', 'id-0', 'id-0']);
  });

  test('a declined card gets a new id on retry', () async {
    outcomes = [const CardDeclinedException('No funds'), receipt];
    final cubit = buildCubit();
    await pay(cubit);
    expect(cubit.state.error, const CardDeclinedException('No funds'));
    await pay(cubit);
    expect(sentIds, ['id-0', 'id-1']);
  });

  test('changing the order gets a new id', () async {
    outcomes = [const NetworkException(), receipt];
    final cubit = buildCubit();
    await pay(cubit);
    await pay(cubit, cart: moreItems);
    expect(sentIds, ['id-0', 'id-1']);
  });

  test('ignores a second tap while the payment is running', () async {
    outcomes = [receipt];
    final cubit = buildCubit();
    final first = pay(cubit);
    await pay(cubit);
    await first;
    expect(sentIds, hasLength(1));
  });
}
