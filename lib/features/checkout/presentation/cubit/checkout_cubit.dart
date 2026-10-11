import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/utils/uuid.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../table_session/domain/entities/table_session.dart';
import '../../domain/entities/card_details.dart';
import '../../domain/entities/order_receipt.dart';
import '../../domain/repositories/order_repository.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({
    required OrderRepository repository,
    String Function()? newClientOrderId,
  }) : _repository = repository,
       _newClientOrderId = newClientOrderId ?? Uuid.v4,
       super(const CheckoutState());

  final OrderRepository _repository;
  final String Function() _newClientOrderId;

  /// Kept across retries of the same order so the server never charges
  /// twice; replaced after a decline or when the order changes.
  String? _clientOrderId;
  String? _orderFingerprint;

  Future<void> pay({
    required TableSession session,
    required List<CartItem> items,
    required CardDetails card,
    String customerNotes = '',
  }) async {
    if (state.isProcessing || items.isEmpty) return;

    final fingerprint = _fingerprintOf(session, items, customerNotes);
    if (_clientOrderId == null || fingerprint != _orderFingerprint) {
      _clientOrderId = _newClientOrderId();
      _orderFingerprint = fingerprint;
    }

    emit(const CheckoutState(status: CheckoutStatus.processing));
    try {
      final receipt = await _repository.placeOrder(
        session: session,
        items: items,
        card: card,
        clientOrderId: _clientOrderId!,
        customerNotes: customerNotes,
      );
      _clientOrderId = null;
      if (isClosed) return;
      emit(CheckoutState(status: CheckoutStatus.success, receipt: receipt));
    } on AppException catch (e) {
      if (e is CardDeclinedException || e is OrderRejectedException) {
        _clientOrderId = null;
      }
      if (isClosed) return;
      emit(CheckoutState(status: CheckoutStatus.failure, error: e));
    }
  }

  static String _fingerprintOf(
    TableSession session,
    List<CartItem> items,
    String customerNotes,
  ) => [
    session.qrId,
    customerNotes.trim(),
    for (final item in items) '${item.configurationKey}x${item.quantity}',
  ].join(';');
}
