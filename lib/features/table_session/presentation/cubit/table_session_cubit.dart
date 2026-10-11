import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/table_session.dart';
import '../../domain/repositories/table_session_repository.dart';

part 'table_session_state.dart';

/// App-scoped: survives navigation between menu, cart and checkout.
class TableSessionCubit extends Cubit<TableSessionState> {
  TableSessionCubit(this._repository) : super(const TableSessionState());

  final TableSessionRepository _repository;

  Future<void> resolve(String qrId) async {
    final id = qrId.trim();
    if (state.qrId == id && (state.isLoaded || state.isLoading)) return;

    emit(TableSessionState(status: TableSessionStatus.loading, qrId: id));
    try {
      final session = await _repository.resolveTable(id);
      if (isClosed || state.qrId != id) return;
      emit(
        TableSessionState(
          status: TableSessionStatus.loaded,
          qrId: id,
          session: session,
        ),
      );
    } on AppException catch (e) {
      if (isClosed || state.qrId != id) return;
      emit(
        TableSessionState(
          status: TableSessionStatus.failure,
          qrId: id,
          error: e,
        ),
      );
    }
  }

  /// Re-fetches the loaded session (e.g. after a language change) without
  /// showing a loading state; keeps the current session on failure.
  Future<void> refresh() async {
    final qrId = state.qrId;
    if (qrId == null || !state.isLoaded) return;
    try {
      final session = await _repository.resolveTable(qrId);
      if (isClosed || state.qrId != qrId) return;
      emit(
        TableSessionState(
          status: TableSessionStatus.loaded,
          qrId: qrId,
          session: session,
        ),
      );
    } on AppException {
      // Keep showing the session we already have.
    }
  }

  Future<void> retry() async {
    final qrId = state.qrId;
    if (qrId == null) return;
    emit(const TableSessionState());
    await resolve(qrId);
  }
}
