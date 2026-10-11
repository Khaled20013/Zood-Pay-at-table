import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../error/app_exception.dart';

export '../../l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension AppLocalizationsX on AppLocalizations {
  String errorText(AppException? error) => switch (error) {
    QrNotFoundException() => errorQrNotFound,
    TableUnavailableException() => errorTableUnavailable,
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
    _ => scanNotFoundTitle,
  };

  String tableErrorMessage(AppException? error) => switch (error) {
    QrNotFoundException() || TableUnavailableException() => askStaffForHelp,
    _ => errorText(error),
  };

  /// [MenuState.allCategory] is a sentinel; real category names come
  /// localized from the API.
  String categoryLabel(String category, {required String allSentinel}) =>
      category == allSentinel ? allCategory : category;
}
