import 'package:flutter/widgets.dart';

import '../../../../AppRoutes/Base/DeepLinkService.dart';
import '../../../../AppRoutes/GoRouterApp.dart';
import '../../../../AppRoutes/TableSessionRoutes.dart';
import '../../../../Models/TableSession/TableSessionModel.dart';

class WelcomeController {
  final Function() refresh;

  WelcomeController(this.refresh);

  final TextEditingController linkController = TextEditingController();

  /// Set after "Open" with something that isn't a table link.
  bool invalidLink = false;

  void update() {
    refresh();
  }

  Future<void> onInit() async {
    update();
  }

  void dispose() {
    linkController.dispose();
  }

  /// Accepts a full table link or a bare QR id.
  static String? locationForInput(String input) {
    final value = input.trim();
    if (value.isEmpty) return null;
    if (TableSessionModel.qrIdPattern.hasMatch(value)) {
      return '/pay-at-table/$value/menu';
    }
    final uri = Uri.tryParse(value);
    return uri == null ? null : DeepLinkService.locationFor(uri);
  }

  void onLinkChanged(String _) {
    if (!invalidLink) return;
    invalidLink = false;
    update();
  }

  /// Returns false (and flags [invalidLink]) when the input isn't a table.
  bool openLink() {
    final location = locationForInput(linkController.text);
    if (location == null) {
      invalidLink = true;
      update();
      return false;
    }
    GoRouterApp.openLocation(location);
    return true;
  }

  void openScanner() => TableSessionRoutes.openQrScanScreen();
}
