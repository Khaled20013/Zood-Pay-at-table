import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../../AppRoutes/CheckoutRoutes.dart';
import '../../../../AppRoutes/GoRouterApp.dart';
import '../../../../AppRoutes/MenuRoutes.dart';
import '../../../../Bloc/AppCubit.dart';
import '../../../../Helper/ApiServices/Base/KApiResponse.dart';
import '../../../../Helper/Errors/AppException.dart';
import '../../../../Helper/Uuid.dart';
import '../../../../Models/Cart/CartItemModel.dart';
import '../../../../Models/Checkout/CardDetailsModel.dart';
import '../../../../Models/Checkout/OrderReceiptModel.dart';
import '../../../../Models/Checkout/OrdersApi.dart';
import '../../../../Models/TableSession/TableSessionModel.dart';

typedef PlaceOrderRequest =
    Future<KApiResponse> Function({
      required TableSessionModel session,
      required List<CartItemModel> items,
      required CardDetailsModel card,
      required String clientOrderId,
      String customerNotes,
    });

enum CheckoutStatus { idle, processing, success, failure }

class CartSummaryController {
  final Function() refresh;
  final AppCubit appCubit;
  final TableSessionModel session;
  final PlaceOrderRequest _placeOrder;
  final String Function() _newClientOrderId;
  final void Function(OrderReceiptModel receipt)? _openReceipt;

  CartSummaryController(
    this.refresh, {
    required this.appCubit,
    required this.session,
    PlaceOrderRequest? placeOrder,
    String Function()? newClientOrderId,
    void Function(OrderReceiptModel receipt)? openReceipt,
  }) : _placeOrder = placeOrder ?? OrdersApi.create,
       _newClientOrderId = newClientOrderId ?? Uuid.v4,
       _openReceipt = openReceipt;

  final TextEditingController notesController = TextEditingController();

  CheckoutStatus status = CheckoutStatus.idle;
  OrderReceiptModel? receipt;
  AppException? error;

  bool get isProcessing => status == CheckoutStatus.processing;

  /// Kept across retries of the same order so the server never charges
  /// twice; replaced after a decline or when the order changes.
  String? _clientOrderId;
  String? _orderFingerprint;

  void update() {
    refresh();
  }

  Future<void> onInit() async {
    update();
  }

  void dispose() {
    notesController.dispose();
  }

  void backToMenu() {
    if (GoRouterApp.canPop()) {
      GoRouterApp.pop();
    } else {
      MenuRoutes.openMenuScreen(qrId: session.qrId, replacement: true);
    }
  }

  void browseMenu() =>
      MenuRoutes.openMenuScreen(qrId: session.qrId, replacement: true);

  /// Charges [card] for the current cart. On success clears the cart and
  /// opens the receipt; on failure returns the error for the view to show.
  Future<AppException?> pay(CardDetailsModel card) async {
    final items = appCubit.cart.items;
    if (isProcessing || items.isEmpty) return null;
    final customerNotes = notesController.text;

    final fingerprint = _fingerprintOf(items, customerNotes);
    if (_clientOrderId == null || fingerprint != _orderFingerprint) {
      _clientOrderId = _newClientOrderId();
      _orderFingerprint = fingerprint;
    }

    status = CheckoutStatus.processing;
    error = null;
    update();

    final response = await _placeOrder(
      session: session,
      items: items,
      card: card,
      clientOrderId: _clientOrderId!,
      customerNotes: customerNotes,
    );
    final placed = response.data;
    if (placed is OrderReceiptModel) {
      _clientOrderId = null;
      status = CheckoutStatus.success;
      receipt = placed;
      update();
      HapticFeedback.mediumImpact();
      appCubit.clearCart();
      final openReceipt = _openReceipt;
      if (openReceipt != null) {
        openReceipt(placed);
      } else {
        CheckoutRoutes.openOrderSuccessScreen(
          qrId: session.qrId,
          receipt: placed,
        );
      }
      return null;
    }

    final failure = response.error ?? const UnexpectedException();
    if (failure is CardDeclinedException || failure is OrderRejectedException) {
      _clientOrderId = null;
    }
    status = CheckoutStatus.failure;
    error = failure;
    update();
    HapticFeedback.heavyImpact();
    if (failure is OrderRejectedException) _reloadMenu();
    return failure;
  }

  /// `422`: the menu changed (e.g. a product sold out). Reload it and drop
  /// what no longer exists so the guest can fix the order.
  Future<void> _reloadMenu() async {
    final products = await appCubit.refreshMenu(session);
    if (products != null) appCubit.syncCartProducts(products);
  }

  String _fingerprintOf(List<CartItemModel> items, String customerNotes) => [
    session.qrId,
    customerNotes.trim(),
    for (final item in items) '${item.configurationKey}x${item.quantity}',
  ].join(';');
}
