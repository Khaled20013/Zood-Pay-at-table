import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zood_pay_at_table/core/error/app_exception.dart';
import 'package:zood_pay_at_table/core/network/demo_data_policy.dart';
import 'package:zood_pay_at_table/features/table_session/data/datasources/table_session_api.dart';
import 'package:zood_pay_at_table/features/table_session/data/repositories/table_session_repository_impl.dart';

import '../../../helpers/fake_http.dart';
import '../../../helpers/fixtures.dart';

void main() {
  TableSessionRepositoryImpl dummyRepo({String languageCode = 'en'}) =>
      TableSessionRepositoryImpl(
        api: TableSessionApi(Dio()),
        policy: const DemoDataPolicy(
          useDummyData: true,
          simulatedLatency: Duration.zero,
        ),
        languageCode: () => languageCode,
      );

  TableSessionRepositoryImpl apiRepo(FakeHttpAdapter adapter) =>
      TableSessionRepositoryImpl(
        api: TableSessionApi(fakeDio(adapter)),
        policy: const DemoDataPolicy(useDummyData: false),
      );

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

  group('TableSessionRepositoryImpl (dummy data)', () {
    test('resolves the demo QR to Olaya, table T5', () async {
      final session = await dummyRepo().resolveTable(demoQrId);
      expect(session.displayTitle, 'Olaya · T5');
      expect(session.businessReference, '100245');
      expect(session.qrId, demoQrId);
    });

    test('rejects malformed QR ids without a request', () {
      expect(
        dummyRepo().resolveTable('not a/qr'),
        throwsA(isA<QrNotFoundException>()),
      );
    });

    test('simulates 404 and 410', () {
      expect(
        dummyRepo().resolveTable('not-found'),
        throwsA(isA<QrNotFoundException>()),
      );
      expect(
        dummyRepo().resolveTable('inactive'),
        throwsA(isA<TableUnavailableException>()),
      );
    });

    test('shows name_localized in Arabic, name when it is empty', () async {
      final session = await dummyRepo(
        languageCode: 'ar',
      ).resolveTable(demoQrId);
      expect(session.branchName, 'العليا');
      expect(session.tableName, 'T5');
    });
  });

  group('TableSessionRepositoryImpl (API)', () {
    test('calls GET /public/pay-at-table/qr/{qr_id}', () async {
      final adapter = FakeHttpAdapter((_) => jsonResponse(200, qrBody()));
      final session = await apiRepo(adapter).resolveTable(demoQrId);
      expect(session.tableName, 'T5');
      expect(
        adapter.requests.single.uri.path,
        '/api/v1/public/pay-at-table/qr/$demoQrId',
      );
    });

    test('404 → QR not found (no retry)', () async {
      final adapter = FakeHttpAdapter((_) => errorResponse(404, 'Not found'));
      final call = apiRepo(adapter).resolveTable(demoQrId);
      await expectLater(call, throwsA(isA<QrNotFoundException>()));
    });

    test('410 or is_active false → ordering unavailable', () async {
      await expectLater(
        apiRepo(
          FakeHttpAdapter((_) => errorResponse(410, 'Gone')),
        ).resolveTable(demoQrId),
        throwsA(isA<TableUnavailableException>()),
      );
      await expectLater(
        apiRepo(
          FakeHttpAdapter((_) => jsonResponse(200, qrBody(isActive: false))),
        ).resolveTable(demoQrId),
        throwsA(isA<TableUnavailableException>()),
      );
    });

    test('other errors keep the server message and allow retry', () async {
      final adapter = FakeHttpAdapter((_) => errorResponse(500, 'Boom'));
      await expectLater(
        apiRepo(adapter).resolveTable(demoQrId),
        throwsA(
          isA<ServerException>()
              .having((e) => e.serverMessage, 'message', 'Boom')
              .having((e) => e.canRetry, 'canRetry', isTrue),
        ),
      );
    });
  });
}
