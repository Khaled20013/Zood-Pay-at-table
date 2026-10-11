part of 'table_session_cubit.dart';

enum TableSessionStatus { initial, loading, loaded, failure }

class TableSessionState extends Equatable {
  const TableSessionState({
    this.status = TableSessionStatus.initial,
    this.qrId,
    this.session,
    this.error,
  });

  final TableSessionStatus status;
  final String? qrId;
  final TableSession? session;
  final AppException? error;

  bool get isLoading => status == TableSessionStatus.loading;
  bool get isLoaded => status == TableSessionStatus.loaded && session != null;

  @override
  List<Object?> get props => [status, qrId, session, error];
}
