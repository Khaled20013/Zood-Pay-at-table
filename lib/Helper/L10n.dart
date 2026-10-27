import 'package:zood_pay_at_table/Helper/Errors/AppException.dart';
import 'package:zood_pay_at_table/generated/l10n.dart';

export 'package:zood_pay_at_table/generated/l10n.dart';

extension SX on S {
  String errorText(AppException? error) => switch (error) {
    QrNotFoundException() => errorQrNotFound,
    TableUnavailableException() => errorTableUnavailable,
    ServiceUnavailableException() => errorServiceUnavailable,
    NetworkException() => errorNetwork,
    CardDeclinedException(:final serverMessage) =>
      serverMessage == null
          ? errorCardDeclined
          : '$errorCardDeclined $serverMessage',
    OrderRejectedException(:final serverMessage) =>
      serverMessage ?? errorOrderRejected,
    TooManyAttemptsException() => errorTooManyAttempts,
    ServerException(:final serverMessage) => serverMessage ?? errorUnexpected,
    UnexpectedException() || null => errorUnexpected,
  };

  /// Title of the full-screen error shown when a table QR can't be opened.
  String tableErrorTitle(AppException? error) => switch (error) {
    QrNotFoundException() => errorQrNotFound,
    TableUnavailableException() => errorTableUnavailable,
    ServiceUnavailableException() => serviceUnavailableTitle,
    NetworkException() => networkErrorTitle,
    _ => scanNotFoundTitle,
  };

  String tableErrorMessage(AppException? error) => switch (error) {
    QrNotFoundException() || TableUnavailableException() => askStaffForHelp,
    ServiceUnavailableException() => errorServiceUnavailable,
    _ => errorText(error),
  };

  /// [MenuModel.allCategory] is a sentinel; real category names come
  /// localized from the API.
  String categoryLabel(String category, {required String allSentinel}) =>
      category == allSentinel ? allCategory : category;
}
