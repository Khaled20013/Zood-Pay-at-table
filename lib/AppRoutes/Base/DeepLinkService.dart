import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'package:zood_pay_at_table/Helper/Configs/AppConfig.dart';

/// Forwards deep links (App Links / Universal Links on `control.zood.ai`
/// and the `zoodpay://` scheme) into go_router, including the link that
/// cold-started the app.
class DeepLinkService {
  DeepLinkService(this._router, {AppLinks? appLinks}) : _appLinks = appLinks;

  final GoRouter _router;
  AppLinks? _appLinks;
  StreamSubscription<Uri>? _subscription;

  void start() {
    final links = _appLinks ??= AppLinks();
    // uriLinkStream also replays the link that cold-started the app.
    _subscription = links.uriLinkStream.listen((uri) {
      final location = locationFor(uri);
      if (location != null) _router.go(location);
    }, onError: (Object e) => debugPrint('DeepLinkService: $e'));
  }

  Future<void> dispose() async => _subscription?.cancel();

  /// Maps an incoming link to a router location, or null if it is not ours.
  ///
  /// `https://control.zood.ai/pay-at-table/<qr_id>/menu` and
  /// `zoodpay://pay-at-table/<qr_id>/menu` both map to
  /// `/pay-at-table/<qr_id>/menu`.
  static String? locationFor(Uri uri) {
    final path = uri.scheme == AppConfig.appScheme
        ? '/${uri.host}${uri.path}'
        : uri.path;
    if (!path.startsWith('/pay-at-table/')) return null;
    return uri.hasQuery ? '$path?${uri.query}' : path;
  }
}
