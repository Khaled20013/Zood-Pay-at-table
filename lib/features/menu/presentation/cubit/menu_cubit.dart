import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/product.dart';
import '../../../table_session/domain/entities/table_session.dart';
import '../../domain/repositories/menu_repository.dart';

part 'menu_state.dart';

class MenuCubit extends Cubit<MenuState> {
  MenuCubit(this._repository) : super(const MenuState());

  final MenuRepository _repository;
  TableSession? _session;

  Future<void> load(TableSession session, {bool force = false}) async {
    if (!force &&
        _session == session &&
        (state.status == MenuStatus.loaded ||
            state.status == MenuStatus.loading)) {
      return;
    }
    _session = session;
    emit(state.copyWith(status: MenuStatus.loading));
    try {
      final products = await _repository.getMenu(session);
      if (isClosed) return;
      emit(
        MenuState(
          status: MenuStatus.loaded,
          products: products,
          selectedCategory: MenuState.allCategory,
        ),
      );
    } on AppException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(status: MenuStatus.failure, error: e));
    }
  }

  /// Re-fetches the menu for [session] (e.g. after a language change) while
  /// keeping the current list, search and selected category on screen.
  /// Returns the new products, or null if the refresh failed.
  Future<List<Product>?> refresh(TableSession session) async {
    if (state.status != MenuStatus.loaded) {
      await load(session, force: true);
      return state.status == MenuStatus.loaded ? state.products : null;
    }
    final previousCategoryId = state.categoryIdOf(state.selectedCategory);
    _session = session;
    try {
      final products = await _repository.getMenu(session);
      if (isClosed) return null;
      final next = MenuState(status: MenuStatus.loaded, products: products);
      emit(
        next.copyWith(
          selectedCategory: next.categoryNameFor(previousCategoryId),
          query: state.query,
        ),
      );
      return products;
    } on AppException {
      return null;
    }
  }

  Future<void> retry() async {
    final session = _session;
    if (session != null) await load(session, force: true);
  }

  void selectCategory(String category) {
    if (category == state.selectedCategory) return;
    emit(state.copyWith(selectedCategory: category));
  }

  void search(String query) => emit(state.copyWith(query: query));
}
