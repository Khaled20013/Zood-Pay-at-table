import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'injection_container.dart';

Future<void> main() async {
  // QR links are plain paths (`/pay-at-table/<qr_id>/menu`), not `#/` hashes.
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  configureDependencies(prefs: prefs);
  runApp(const ZoodPayAtTableApp());
}
