import '../../../AppRoutes/AppRoutes.dart';

class SplashController {
  final Function() refresh;

  SplashController(this.refresh);

  void update() {
    refresh();
  }

  Future<void> onInit() async {
    update();
  }

  /// A deep link arriving mid-animation replaces the splash route, which
  /// disposes the view before this runs.
  void finish() => AppRoutes.openLandingScreen();
}
