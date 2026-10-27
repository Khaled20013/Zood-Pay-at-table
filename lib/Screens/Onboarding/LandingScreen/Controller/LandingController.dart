import '../../../../AppRoutes/OnboardingRoutes.dart';

class LandingController {
  final Function() refresh;

  LandingController(this.refresh);

  void update() {
    refresh();
  }

  Future<void> onInit() async {
    update();
  }

  void openWelcome() => OnboardingRoutes.openWelcomeScreen();
}
