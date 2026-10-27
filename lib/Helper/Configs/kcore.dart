library;

import 'AppConfig.dart';

Config config = Config.fromEnvironment();

const String defaultLang = "en";

Future<void> initConfig() async {
  config = Config.fromEnvironment();
}

class Config {
  Config({required this.url});

  /// Base url without a trailing slash, e.g. `https://dev.api.zood.ai/api/v1`.
  factory Config.fromEnvironment() =>
      Config(url: _trimSlash(AppConfig.apiBaseUrl));

  String url;

  static String _trimSlash(String value) =>
      value.endsWith('/') ? value.substring(0, value.length - 1) : value;
}
