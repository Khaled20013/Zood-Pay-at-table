import '../entities/table_session.dart';

/// Throws an `AppException` subtype on failure.
abstract interface class TableSessionRepository {
  Future<TableSession> resolveTable(String qrId);
}
