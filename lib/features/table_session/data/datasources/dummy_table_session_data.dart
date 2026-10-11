import '../../../../core/error/app_exception.dart';
import '../models/table_session_model.dart';

/// Demo QR check served while the Pay at Table API is not wired up
/// (`USE_DUMMY_DATA=true`, the default). Same JSON as the API.
///
/// Any QR id opens the demo table, except [notFoundQrId] (`404`) and
/// [inactiveQrId] (`410`), which exercise the error screens.
abstract final class DummyTableSessionData {
  static const String businessReference = '100245';
  static const String notFoundQrId = 'not-found';
  static const String inactiveQrId = 'inactive';

  static QrResponse qrFor(String qrId) {
    if (qrId == notFoundQrId) throw const QrNotFoundException();
    if (qrId == inactiveQrId) throw const TableUnavailableException();
    return QrResponse.fromJson({
      'data': {
        'id': qrId,
        'is_active': true,
        'business_reference': businessReference,
        'branch_id': '769bb763-c89c-48af-b097-25f8a516d3a1',
        'table_id': 'a1c2f3e4-5b6d-4e7f-8a9b-0c1d2e3f4a5b',
        'branch': {
          'id': '769bb763-c89c-48af-b097-25f8a516d3a1',
          'name': 'Olaya',
          'name_localized': 'العليا',
        },
        'table': {
          'id': 'a1c2f3e4-5b6d-4e7f-8a9b-0c1d2e3f4a5b',
          'name': 'T5',
          'name_localized': null,
        },
      },
    });
  }
}
