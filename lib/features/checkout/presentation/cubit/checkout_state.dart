part of 'checkout_cubit.dart';

enum CheckoutStatus { idle, processing, success, failure }

class CheckoutState extends Equatable {
  const CheckoutState({
    this.status = CheckoutStatus.idle,
    this.receipt,
    this.error,
  });

  final CheckoutStatus status;
  final OrderReceipt? receipt;
  final AppException? error;

  bool get isProcessing => status == CheckoutStatus.processing;

  @override
  List<Object?> get props => [status, receipt, error];
}
