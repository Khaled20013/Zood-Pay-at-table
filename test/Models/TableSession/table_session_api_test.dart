import 'package:flutter_test/flutter_test.dart';
import 'package:zood_pay_at_table/Constants.dart' as constants;
import 'package:zood_pay_at_table/Helper/Errors/AppException.dart';
import 'package:zood_pay_at_table/Models/TableSession/TableSessionApi.dart';
import 'package:zood_pay_at_table/Models/TableSession/TableSessionModel.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mock_http.dart';

void main() {
  tearDown(() {
    MockApi.reset();
    constants.lang = 'en';
  });

  Map<String, Object?> qrBody({bool isActive = true}) => {
    'data': {
      'id': demoQrId,
      'is_active': isActive,
      'business_reference': '100245',
      'branch_id': 'b1',
      'table_id': 't1',
      'branch': {'id': 'b1', 'name': 'Olaya', 'name_localized': 'العليا'},
      'table': {'id': 't1', 'name': 'T5', 'name_localized': null},
    },
  };

  Future<AppException?> errorOf(String qrId) async =>
      (await TableSessionApi.getDetails(qrId: qrId)).error;

  group('TableSessionApi (dummy data)', () {
    setUp(useDummyData);

    test('resolves the demo QR to Olaya, table T5', () async {
      final response = await TableSessionApi.getDetails(qrId: demoQrId);
      final session = response.data as TableSessionModel;
      expect(session.displayTitle, 'Olaya · T5');
      expect(session.businessReference, '100245');
      expect(session.qrId, demoQrId);
    });

    test('rejects malformed QR ids without a request', () async {
      expect(await errorOf('not a/qr'), isA<QrNotFoundException>());
    });

    test('simulates 404 and 410', () async {
      expect(await errorOf('not-found'), isA<QrNotFoundException>());
      expect(await errorOf('inactive'), isA<TableUnavailableException>());
    });

    test('shows name_localized in Arabic, name when it is empty', () async {
      constants.lang = 'ar';
      final response = await TableSessionApi.getDetails(qrId: demoQrId);
      final session = response.data as TableSessionModel;
      expect(session.branchName, 'العليا');
      expect(session.tableName, 'T5');
    });
  });

  group('TableSessionApi (API)', () {
    test('calls GET /public/pay-at-table/qr/{qr_id}', () async {
      final api = MockApi((_) async => jsonResponse(200, qrBody()));
      final response = await TableSessionApi.getDetails(qrId: demoQrId);
      expect((response.data as TableSessionModel).tableName, 'T5');
      expect(api.requests.single.method, 'GET');
      expect(
        api.requests.single.url.path,
        '/api/v1/public/pay-at-table/qr/$demoQrId',
      );
    });

    test('sends no auth header', () async {
      final api = MockApi((_) async => jsonResponse(200, qrBody()));
      await TableSessionApi.getDetails(qrId: demoQrId);
      expect(
        api.requests.single.headers.keys.map((k) => k.toLowerCase()),
        isNot(contains('authorization')),
      );
    });

    test('404 → QR not found (no retry)', () async {
      MockApi((_) async => errorResponse(404, 'Not found'));
      expect(await errorOf(demoQrId), isA<QrNotFoundException>());
    });

    test('404 for an undeployed route → service unavailable, not QR', () async {
      MockApi(
        (r) async => jsonResponse(404, {
          'message': 'The route ${r.url.path} could not be found.',
          'exception':
              r'Symfony\Component\HttpKernel\Exception'
              r'\NotFoundHttpException',
        }),
      );
      expect(
        await errorOf(demoQrId),
        isA<ServiceUnavailableException>().having(
          (e) => e.canRetry,
          'canRetry',
          isTrue,
        ),
      );
    });

    test('410 or is_active false → ordering unavailable', () async {
      MockApi((_) async => errorResponse(410, 'Gone'));
      expect(await errorOf(demoQrId), isA<TableUnavailableException>());
      MockApi((_) async => jsonResponse(200, qrBody(isActive: false)));
      expect(await errorOf(demoQrId), isA<TableUnavailableException>());
    });

    test('other errors keep the server message and allow retry', () async {
      MockApi((_) async => errorResponse(500, 'Boom'));
      expect(
        await errorOf(demoQrId),
        isA<ServerException>()
            .having((e) => e.serverMessage, 'message', 'Boom')
            .having((e) => e.canRetry, 'canRetry', isTrue),
      );
    });

    test('network failure → NetworkException', () async {
      MockApi((_) async => throw Exception('offline'));
      expect(await errorOf(demoQrId), isA<NetworkException>());
    });
  });
}
