import '../../../../AppRoutes/MenuRoutes.dart';

class OrderSuccessController {
  final Function() refresh;
  final String qrId;

  OrderSuccessController(this.refresh, {required this.qrId});

  void update() {
    refresh();
  }

  Future<void> onInit() async {
    update();
  }

  void orderMore() => MenuRoutes.openMenuScreen(qrId: qrId, replacement: true);
}
