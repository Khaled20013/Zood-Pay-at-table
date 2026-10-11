import 'package:flutter/foundation.dart';

/// Compile-time configuration, overridable with `--dart-define`.
///
/// ```sh
/// flutter run --dart-define=USE_DUMMY_DATA=false \
///   --dart-define=API_BASE_URL=https://dev.api.zood.ai/api/v1/
/// ```
abstract final class AppConfig {
  static const String appName = 'Zood Pay-At-Table';

  static const String productionApiBaseUrl = 'https://api.zood.ai/api/v1/';
  static const String devApiBaseUrl = 'https://dev.api.zood.ai/api/v1/';

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: kReleaseMode ? productionApiBaseUrl : devApiBaseUrl,
  );

  /// When true the repositories never touch the network and serve the
  /// bundled demo data (same JSON shape as the API). Defaults to true until
  /// the Pay at Table endpoints are live.
  static const bool useDummyData = bool.fromEnvironment(
    'USE_DUMMY_DATA',
    defaultValue: true,
  );

  /// Host whose `/pay-at-table/...` links open the app (App Links /
  /// Universal Links). Printed on the table QR codes.
  static const String linkHost = 'control.zood.ai';

  /// Custom scheme registered by the app, e.g. `zoodpay://pay-at-table/<qr_id>/menu`.
  static const String appScheme = 'zoodpay';

  /// The API returns plain amounts; every branch charges in SAR.
  static const String currency = 'SAR';

  /// Prices come without VAT; the server adds it when charging.
  static const double vatRate = 0.15;

  /// QR opened by "Open demo table".
  static const String demoQrId = '40de86d3987ef0a98768ad61';

  static const bool enableNetworkLogs = bool.fromEnvironment(
    'ENABLE_NETWORK_LOGS',
    defaultValue: true,
  );

  /// Route to open on launch, e.g. `/pay-at-table/<qr_id>/menu`.
  /// Empty means the splash, then the landing page.
  static const String initialLocation = String.fromEnvironment(
    'INITIAL_LOCATION',
  );
}
