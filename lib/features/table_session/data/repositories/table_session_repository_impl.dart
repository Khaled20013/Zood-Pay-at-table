import '../../../../core/error/app_exception.dart';
import '../../../../core/network/demo_data_policy.dart';
import '../../domain/entities/table_session.dart';
import '../../domain/repositories/table_session_repository.dart';
import '../datasources/dummy_table_session_data.dart';
import '../datasources/table_session_api.dart';
import '../models/table_session_model.dart';

class TableSessionRepositoryImpl implements TableSessionRepository {
  TableSessionRepositoryImpl({
    required TableSessionApi api,
    required DemoDataPolicy policy,
    String Function()? languageCode,
  }) : _api = api,
       _policy = policy,
       _languageCode = languageCode ?? _english;

  final TableSessionApi _api;
  final DemoDataPolicy _policy;

  /// Current app language, used to pick `name` or `name_localized`.
  final String Function() _languageCode;
  static String _english() => 'en';

  @override
  Future<TableSession> resolveTable(String qrId) async {
    final id = qrId.trim();
    if (!TableSession.qrIdPattern.hasMatch(id)) {
      throw const QrNotFoundException();
    }
    final response = await _policy.run<QrResponse>(
      remote: () => _api.getQr(id),
      dummy: () => DummyTableSessionData.qrFor(id),
      onStatus: (status, message) => switch (status) {
        404 => QrNotFoundException(message),
        410 => TableUnavailableException(message),
        _ => null,
      },
    );
    if (!response.data.isActive) throw const TableUnavailableException();
    return response.data.toEntity(_languageCode());
  }
}
