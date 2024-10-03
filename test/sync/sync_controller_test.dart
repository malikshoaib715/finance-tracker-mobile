import 'package:drift/native.dart';
import 'package:finance_tracker_mobile/core/providers.dart';
import 'package:finance_tracker_mobile/data/database.dart';
import 'package:finance_tracker_mobile/data/transactions_repository.dart';
import 'package:finance_tracker_mobile/sync/sync_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_api.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  ProviderContainer container(FakeApi api) => ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          apiClientProvider.overrideWithValue(api.client()),
        ],
      );

  test('reports offline and keeps changes pending', () async {
    final c = container(FakeApi());
    addTearDown(c.dispose);
    await c.read(transactionsRepositoryProvider).create(
          TransactionDraft(
            accountId: 1,
            kind: 'expense',
            amountCents: 100,
            occurredOn: DateTime(2024, 10, 3),
            description: 'Tea',
          ),
        );

    await c.read(syncControllerProvider.notifier).sync();

    final status = c.read(syncControllerProvider);
    expect(status.phase, SyncPhase.offline);
    expect(status.pendingChanges, 1);
  });

  test('a full sync ends idle with a timestamp', () async {
    final api = FakeApi()
      ..on('GET /transactions',
          (200, {'transactions': <Object>[], 'next_cursor': null}))
      ..on('GET /deletions', (200, {'deletions': <Object>[]}))
      ..on('GET /accounts', (200, {'accounts': <Object>[]}))
      ..on('GET /categories', (200, {'categories': <Object>[]}));
    final c = container(api);
    addTearDown(c.dispose);

    await c.read(syncControllerProvider.notifier).sync();

    final status = c.read(syncControllerProvider);
    expect(status.phase, SyncPhase.idle);
    expect(status.lastSyncedAt, isNotNull);
  });

  test('concurrent requests share one run', () async {
    final api = FakeApi()
      ..on('GET /transactions',
          (200, {'transactions': <Object>[], 'next_cursor': null}))
      ..on('GET /deletions', (200, {'deletions': <Object>[]}))
      ..on('GET /accounts', (200, {'accounts': <Object>[]}))
      ..on('GET /categories', (200, {'categories': <Object>[]}));
    final c = container(api);
    addTearDown(c.dispose);
    final controller = c.read(syncControllerProvider.notifier);

    await Future.wait([controller.sync(), controller.sync()]);

    expect(api.requests.where((r) => r.uri.path.endsWith('/transactions')),
        hasLength(1));
  });
}
