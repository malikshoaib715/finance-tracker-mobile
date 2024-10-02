import 'package:drift/native.dart';
import 'package:finance_tracker_mobile/data/database.dart';
import 'package:finance_tracker_mobile/data/transactions_repository.dart';
import 'package:finance_tracker_mobile/sync/sync_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_api.dart';

Map<String, dynamic> serverTx(
  int id,
  String description, {
  String? clientId,
  String updatedAt = '2024-10-02T10:00:00.000000Z',
}) =>
    {
      'id': id,
      'client_id': clientId,
      'account_id': 1,
      'category_id': null,
      'kind': 'expense',
      'amount_cents': 50000,
      'occurred_on': '2024-10-02',
      'description': description,
      'notes': null,
      'tags': <String>[],
      'updated_at': updatedAt,
    };

void main() {
  late AppDatabase db;
  late FakeApi api;
  late SyncEngine engine;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    api = FakeApi()..on('GET /deletions', (200, {'deletions': <Object>[]}));
    engine = SyncEngine(db, api.client());
  });
  tearDown(() => db.close());

  test('follows the cursor and stores the newest server timestamp', () async {
    api.onDynamic('GET /transactions', (r) {
      final cursor = r.queryParameters['cursor'];
      return cursor == null
          ? (
              200,
              {
                'transactions': [serverTx(1, 'A')],
                'next_cursor': 'page2'
              }
            )
          : (
              200,
              {
                'transactions': [
                  serverTx(2, 'B', updatedAt: '2024-10-02T11:00:00.000000Z'),
                ],
                'next_cursor': null,
              }
            );
    });

    expect(await engine.pull(), 2);
    expect((await db.select(db.transactions).get()).length, 2);

    await engine.pull();
    final lastFeedRequest =
        api.requests.lastWhere((r) => r.uri.path.endsWith('/transactions'));
    expect(
      lastFeedRequest.queryParameters['updated_since'],
      '2024-10-02T11:00:00.000000Z',
    );
  });

  test('matches its own uploads by client id instead of duplicating', () async {
    final repo = TransactionsRepository(db);
    final clientId = await repo.create(
      TransactionDraft(
        accountId: 1,
        kind: 'expense',
        amountCents: 50000,
        occurredOn: DateTime(2024, 10, 2),
        description: 'Mine',
      ),
    );
    await db.delete(db.outbox).go(); // as if already pushed
    api.on('GET /transactions', (
      200,
      {
        'transactions': [
          serverTx(7, 'Mine (edited on web)', clientId: clientId)
        ],
        'next_cursor': null,
      }
    ));

    await engine.pull();

    final rows = await db.select(db.transactions).get();
    expect(rows.single.serverId, 7);
    expect(rows.single.description, 'Mine (edited on web)');
  });

  test('never overwrites a local change that is still queued', () async {
    final repo = TransactionsRepository(db);
    final clientId = await repo.create(
      TransactionDraft(
        accountId: 1,
        kind: 'expense',
        amountCents: 50000,
        occurredOn: DateTime(2024, 10, 2),
        description: 'Local edit',
      ),
    );
    api.on('GET /transactions', (
      200,
      {
        'transactions': [serverTx(7, 'Server version', clientId: clientId)],
        'next_cursor': null,
      }
    ));

    await engine.pull();

    expect((await repo.findByClientId(clientId))!.description, 'Local edit');
  });

  test('applies deletion tombstones', () async {
    api
      ..on('GET /transactions', (
        200,
        {
          'transactions': [serverTx(1, 'Gone soon')],
          'next_cursor': null
        },
      ))
      ..on('GET /deletions', (
        200,
        {
          'deletions': [
            {
              'record_type': 'Transaction',
              'record_id': 1,
              'deleted_at': '2024-10-02T12:00:00.000000Z',
            },
          ],
        }
      ));

    await engine.pull();

    expect(await db.select(db.transactions).get(), isEmpty);
  });
}
