import '../../../../AppRoutes/MenuRoutes.dart';
import '../../../../Bloc/AppCubit.dart';

class TableScanController {
  final Function() refresh;
  final AppCubit appCubit;
  String qrId;

  TableScanController(this.refresh, {required this.appCubit, required this.qrId});

  void update() {
    refresh();
  }

  /// Resolving also binds the cart and warms the menu (see [AppCubit]).
  Future<void> onInit() async {
    appCubit.resolveTable(qrId);
    update();
  }

  void onQrIdChanged(String next) {
    if (next == qrId) return;
    qrId = next;
    appCubit.resolveTable(qrId);
  }

  void openMenu() => MenuRoutes.openMenuScreen(qrId: qrId);
}
