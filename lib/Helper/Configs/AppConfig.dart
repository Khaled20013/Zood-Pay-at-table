/// Compile-time configuration, overridable with `--dart-define`.
///
/// ```sh
/// flutter run --dart-define=USE_DUMMY_DATA=true
/// flutter run --dart-define=API_BASE_URL=https://dev.api.zood.ai/api/v1/
/// ```
abstract final class AppConfig {
  static const String appName = 'Zood Pay-At-Table';

  static const String devApiBaseUrl = 'https://dev.api.zood.ai/api/v1/';

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: devApiBaseUrl,
  );

  /// When true the repositories never touch the network and serve the
  /// bundled demo data (same JSON shape as the API).
  static const bool useDummyData = bool.fromEnvironment('USE_DUMMY_DATA');

  /// Host whose `/pay-at-table/...` links open the app (App Links /
  /// Universal Links). Printed on the table QR codes.
  static const String linkHost = 'control.zood.ai';

  /// Custom scheme registered by the app, e.g. `zoodpay://pay-at-table/<qr_id>/menu`.
  static const String appScheme = 'zoodpay';

  /// The API returns plain amounts; every branch charges in SAR.
  static const String currency = 'SAR';

  /// Prices come without VAT; the server adds it when charging.
  static const double vatRate = 0.15;

  /// Real dev-API table used by widget tests that open a menu route.
  static const String demoQrId = '7c034c7a804289d74b790856';

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
