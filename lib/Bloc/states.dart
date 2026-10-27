import 'package:flutter/foundation.dart';

import '../Helper/Errors/AppException.dart';
import '../Models/Cart/CartModel.dart';
import '../Models/Menu/MenuModel.dart';
import '../Models/TableSession/TableSessionModel.dart';

@immutable
abstract class AppStates {
  const AppStates();
}

class InitialAppStates extends AppStates {}

/// The table QR started resolving, resolved, or failed.
@immutable
class TableSessionAppStates extends AppStates {
  final TableSessionStatus status;
  final TableSessionModel? session;
  final AppException? error;
  const TableSessionAppStates(this.status, {this.session, this.error});
}

/// The menu started loading, loaded, failed, or was refreshed.
@immutable
class MenuAppStates extends AppStates {
  final MenuModel menu;
  const MenuAppStates(this.menu);
}

/// The cart changed; [previous] lets listeners react to transitions
/// (e.g. the cart just became empty).
@immutable
class CartAppStates extends AppStates {
  final CartModel previous;
  final CartModel cart;
  const CartAppStates(this.previous, this.cart);
}
