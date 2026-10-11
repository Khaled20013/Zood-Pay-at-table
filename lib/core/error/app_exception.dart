import 'package:equatable/equatable.dart';

/// Domain-level failure surfaced to the presentation layer. [serverMessage]
/// is the API's `message`, already in the request's `Accept-Language`.
sealed class AppException extends Equatable implements Exception {
  const AppException([this.serverMessage]);

  final String? serverMessage;

  /// False when retrying cannot help (e.g. the QR does not exist).
  bool get canRetry => true;

  @override
  List<Object?> get props => [serverMessage];

  @override
  String toString() => '$runtimeType(${serverMessage ?? ''})';
}

/// `404` on the QR check.
class QrNotFoundException extends AppException {
  const QrNotFoundException([super.serverMessage]);

  @override
  bool get canRetry => false;
}

/// `410` on the QR check, an inactive QR, or `404` / `410` on the order.
class TableUnavailableException extends AppException {
  const TableUnavailableException([super.serverMessage]);

  @override
  bool get canRetry => false;
}

/// No connection or timeout.
class NetworkException extends AppException {
  const NetworkException([super.serverMessage]);
}

/// Any other non-2xx response.
class ServerException extends AppException {
  const ServerException([super.serverMessage]);
}

/// `402` on the order.
class CardDeclinedException extends AppException {
  const CardDeclinedException([super.serverMessage]);
}

/// `422` on the order, e.g. a product is no longer available.
class OrderRejectedException extends AppException {
  const OrderRejectedException([super.serverMessage]);
}

/// `429` on the order.
class TooManyAttemptsException extends AppException {
  const TooManyAttemptsException([super.serverMessage]);
}

class UnexpectedException extends AppException {
  const UnexpectedException([super.serverMessage]);
}
