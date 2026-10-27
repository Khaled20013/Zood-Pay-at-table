import 'package:flutter_test/flutter_test.dart';
import 'package:zood_pay_at_table/Bloc/AppCubit.dart';
import 'package:zood_pay_at_table/Helper/ApiServices/Base/KApiResponse.dart';
import 'package:zood_pay_at_table/Helper/Errors/AppException.dart';
import 'package:zood_pay_at_table/Models/Cart/CartItemModel.dart';
import 'package:zood_pay_at_table/Models/Checkout/CardDetailsModel.dart';
import 'package:zood_pay_at_table/Models/Checkout/OrderReceiptModel.dart';
import 'package:zood_pay_at_table/Models/Menu/ProductModel.dart';
import 'package:zood_pay_at_table/Models/TableSession/TableSessionModel.dart';
import 'package:zood_pay_at_table/Screens/Checkout/CartSummaryScreen/Controller/CartSummaryController.dart';

import '../../helpers/fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const card = CardDetailsModel(
    holderName: 'AHMED ALI',
    number: '4111111111111111',
    expiryMonth: '08',
    expiryYear: '2028',
    cvc: '123',
  );
  final receipt = OrderReceiptModel(
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

  late AppCubit appCubit;
  late List<String> sentIds;
  late List<Object> outcomes;
  late List<OrderReceiptModel> opened;
  late int idSeq;
  late List<ProductModel> menuProducts;

  CartSummaryController buildController() => CartSummaryController(
    () {},
    appCubit: appCubit,
    session: tableSession,
    newClientOrderId: () => 'id-${idSeq++}',
    openReceipt: opened.add,
    placeOrder:
        ({
          required TableSessionModel session,
          required List<CartItemModel> items,
          required CardDetailsModel card,
          required String clientOrderId,
          String customerNotes = '',
        }) async {
          sentIds.add(clientOrderId);
          final next = outcomes.removeAt(0);
          if (next is AppException) return KApiResponse.failure(next);
          return KApiResponse.successRespone()..data = next;
        },
  );

  setUp(() {
    sentIds = [];
    outcomes = [];
    opened = [];
    idSeq = 0;
    menuProducts = const [icedSpanishLatte];
    appCubit = AppCubit(
      loadMenuRequest: (_) async =>
          KApiResponse.successRespone()..data = menuProducts,
    )
      ..bindCart(demoQrId)
      ..addProduct(icedSpanishLatte);
  });

  tearDown(() => appCubit.close());

  test('success clears the cart and opens the receipt', () async {
    outcomes = [receipt];
    final controller = buildController();
    expect(await controller.pay(card), isNull);
    expect(controller.status, CheckoutStatus.success);
    expect(controller.receipt, receipt);
    expect(opened, [receipt]);
    expect(appCubit.cart.isEmpty, isTrue);
  });

  test('retries after a network error or 5xx reuse the same id', () async {
    outcomes = [const NetworkException(), const UnexpectedException(), receipt];
    final controller = buildController();
    expect(await controller.pay(card), isA<NetworkException>());
    expect(controller.status, CheckoutStatus.failure);
    await controller.pay(card);
    await controller.pay(card);
    expect(sentIds, ['id-0', 'id-0', 'id-0']);
  });

  test('a declined card gets a new id on retry', () async {
    outcomes = [const CardDeclinedException('No funds'), receipt];
    final controller = buildController();
    await controller.pay(card);
    expect(controller.error, const CardDeclinedException('No funds'));
    expect(appCubit.cart.isEmpty, isFalse);
    await controller.pay(card);
    expect(sentIds, ['id-0', 'id-1']);
  });

  test('changing the order gets a new id', () async {
    outcomes = [const NetworkException(), receipt];
    final controller = buildController();
    await controller.pay(card);
    appCubit.incrementCartLine(appCubit.cart.items.single.id);
    await controller.pay(card);
    expect(sentIds, ['id-0', 'id-1']);
  });

  test('changing the notes gets a new id', () async {
    outcomes = [const NetworkException(), receipt];
    final controller = buildController();
    await controller.pay(card);
    controller.notesController.text = 'window seat';
    await controller.pay(card);
    expect(sentIds, ['id-0', 'id-1']);
  });

  test('ignores a second tap while the payment is running', () async {
    outcomes = [receipt];
    final controller = buildController();
    final first = controller.pay(card);
    await controller.pay(card);
    await first;
    expect(sentIds, hasLength(1));
  });

  test('422 reloads the menu and drops what is gone', () async {
    outcomes = [const OrderRejectedException('Sold out')];
    appCubit.addProduct(karakTea);
    await appCubit.loadMenu(tableSession);
    final controller = buildController();
    await controller.pay(card);
    await pumpEventQueue();
    expect(appCubit.cart.items.map((i) => i.product.id), [
      icedSpanishLatte.id,
    ]);
  });
}
