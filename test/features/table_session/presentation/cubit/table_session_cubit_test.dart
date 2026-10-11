import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zood_pay_at_table/core/error/app_exception.dart';
import 'package:zood_pay_at_table/features/table_session/domain/repositories/table_session_repository.dart';
import 'package:zood_pay_at_table/features/table_session/presentation/cubit/table_session_cubit.dart';

import '../../../../helpers/fixtures.dart';

class _MockTableSessionRepository extends Mock
    implements TableSessionRepository {}

void main() {
  late _MockTableSessionRepository repository;

  setUp(() => repository = _MockTableSessionRepository());

  group('TableSessionCubit', () {
    test('initial state is idle', () {
      expect(TableSessionCubit(repository).state, const TableSessionState());
    });

    blocTest<TableSessionCubit, TableSessionState>(
      'emits [loading, loaded] when the QR resolves',
      setUp: () => when(
        () => repository.resolveTable(demoQrId),
      ).thenAnswer((_) async => tableSession),
      build: () => TableSessionCubit(repository),
      act: (c) => c.resolve(demoQrId),
      expect: () => const [
        TableSessionState(status: TableSessionStatus.loading, qrId: demoQrId),
        TableSessionState(
          status: TableSessionStatus.loaded,
          qrId: demoQrId,
          session: tableSession,
        ),
      ],
      verify: (c) {
        expect(c.state.session!.displayTitle, 'Olaya · T5');
      },
    );

    blocTest<TableSessionCubit, TableSessionState>(
      'trims the QR id before resolving (ids are case-sensitive)',
      setUp: () => when(
        () => repository.resolveTable(demoQrId),
      ).thenAnswer((_) async => tableSession),
      build: () => TableSessionCubit(repository),
      act: (c) => c.resolve('  $demoQrId '),
      verify: (_) => verify(() => repository.resolveTable(demoQrId)).called(1),
    );

    blocTest<TableSessionCubit, TableSessionState>(
      'emits [loading, failure] with the exception message',
      setUp: () => when(
        () => repository.resolveTable(any()),
      ).thenThrow(const QrNotFoundException('Unknown table')),
      build: () => TableSessionCubit(repository),
      act: (c) => c.resolve('bad'),
      expect: () => const [
        TableSessionState(status: TableSessionStatus.loading, qrId: 'bad'),
        TableSessionState(
          status: TableSessionStatus.failure,
          qrId: 'bad',
          error: QrNotFoundException('Unknown table'),
        ),
      ],
    );

    blocTest<TableSessionCubit, TableSessionState>(
      'does not refetch an already-loaded QR',
      setUp: () => when(
        () => repository.resolveTable(demoQrId),
      ).thenAnswer((_) async => tableSession),
      build: () => TableSessionCubit(repository),
      act: (c) async {
        await c.resolve(demoQrId);
        await c.resolve(demoQrId);
      },
      verify: (_) => verify(() => repository.resolveTable(demoQrId)).called(1),
    );

    blocTest<TableSessionCubit, TableSessionState>(
      'retry re-resolves after a failure',
      setUp: () {
        var calls = 0;
        when(() => repository.resolveTable(demoQrId)).thenAnswer((_) async {
          if (calls++ == 0) throw const NetworkException();
          return tableSession;
        });
      },
      build: () => TableSessionCubit(repository),
      act: (c) async {
        await c.resolve(demoQrId);
        expect(c.state.status, TableSessionStatus.failure);
        await c.retry();
      },
      verify: (c) {
        expect(c.state.isLoaded, isTrue);
        expect(c.state.session, tableSession);
      },
    );

    blocTest<TableSessionCubit, TableSessionState>(
      'a stale response for a previous QR is ignored',
      setUp: () {
        when(() => repository.resolveTable(demoQrId)).thenAnswer(
          (_) => Future.delayed(
            const Duration(milliseconds: 30),
            () => tableSession,
          ),
        );
        when(
          () => repository.resolveTable('ffffffffffffffffffffffff'),
        ).thenThrow(const QrNotFoundException('gone'));
      },
      build: () => TableSessionCubit(repository),
      act: (c) async {
        final first = c.resolve(demoQrId);
        await c.resolve('ffffffffffffffffffffffff');
        await first;
      },
      verify: (c) {
        expect(c.state.qrId, 'ffffffffffffffffffffffff');
        expect(c.state.status, TableSessionStatus.failure);
      },
    );
  });
}
