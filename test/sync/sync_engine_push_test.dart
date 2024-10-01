import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:finance_tracker_mobile/data/database.dart';
import 'package:finance_tracker_mobile/data/transactions_repository.dart';
import 'package:finance_tracker_mobile/sync/sync_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_api.dart';

TransactionDraft draft([String description = 'Careem']) => TransactionDraft(
      accountId: 1,
      kind: 'expense',
      amountCents: 125000,
      occurredOn: DateTime(2024, 10, 1),
      description: description,
    );

Map<String, dynamic> serverJson(RequestOptions r, {int id = 99}) {
  final t =
      (r.data as Map<String, dynamic>)['transaction'] as Map<String, dynamic>;
  return {
    ...t,
    'id': id,
    'tags': <String>[],
    'updated_at': '2024-10-01T12:00:00.000000Z',
  };
}

void main() {
  late AppDatabase db;
  late TransactionsRepository repo;
  late FakeApi api;
  late SyncEngine engine;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = TransactionsRepository(db);
    api = FakeApi();
    engine = SyncEngine(db, api.client());
  });
  tearDown(() => db.close());

  test('pushes a create with its client id and records the server id',
      () async {
    final clientId = await repo.create(draft());
    api.onDynamic('POST /transactions', (r) => (201, serverJson(r)));

    final result = await engine.push();

    expect(result.pushed, 1);
    expect(await db.select(db.outbox).get(), isEmpty);
    final row = await repo.findByClientId(clientId);
    expect(row!.serverId, 99);
    final body = api.requests.single.data as Map<String, dynamic>;
    expect((body['transaction'] as Map)['client_id'], clientId);
  });

  test('keeps everything queued when offline', () async {
    await repo.create(draft());
    final result = await engine.push(); // no routes: connection errors

    expect(result.offline, isTrue);
    final entry = (await db.select(db.outbox).get()).single;
    expect(entry.attempts, 1);
    expect(entry.lastError, 'No connection to the server');
  });

  test('sends updates with if_unmodified_since', () async {
    final clientId = await repo.create(draft());
    api
      ..onDynamic('POST /transactions', (r) => (201, serverJson(r)))
      ..onDynamic('PATCH /transactions/99', (r) => (200, serverJson(r)));
    await engine.push();

    await repo.update(clientId, draft('Careem ride'));
    await engine.push();

    final patch = api.requests.last.data as Map<String, dynamic>;
    expect(patch['if_unmodified_since'], '2024-10-01T12:00:00.000Z');
    expect((patch['transaction'] as Map)['description'], 'Careem ride');
  });

  test('a conflicting update takes the server copy', () async {
    final clientId = await repo.create(draft());
    api.onDynamic('POST /transactions', (r) => (201, serverJson(r)));
    await engine.push();

    await repo.update(clientId, draft('Phone edit'));
    api.on('PATCH /transactions/99', (
      409,
      {
        'error': {'message': 'Changed on the server since you last synced'},
        'transaction': {
          'id': 99,
          'client_id': clientId,
          'account_id': 1,
          'category_id': null,
          'kind': 'expense',
          'amount_cents': 125000,
          'occurred_on': '2024-10-01',
          'description': 'Web edit',
          'notes': null,
          'tags': <String>[],
          'updated_at': '2024-10-02T09:00:00.000000Z',
        },
      }
    ));

    final result = await engine.push();

    expect(result.conflicts, 1);
    expect((await repo.findByClientId(clientId))!.description, 'Web edit');
    expect(await db.select(db.outbox).get(), isEmpty);
  });

  test('deletes by server id, treating 404 as done', () async {
    final clientId = await repo.create(draft());
    api.onDynamic('POST /transactions', (r) => (201, serverJson(r)));
    await engine.push();

    await repo.delete(clientId);
    api.on('DELETE /transactions/99', (
      404,
      {
        'error': {'message': 'Not found'},
      }
    ));
    await engine.push();

    expect(await db.select(db.outbox).get(), isEmpty);
    expect(api.requests.last.method, 'DELETE');
  });

  test('a rejected change is recorded and later changes to it wait', () async {
    final clientId = await repo.create(draft());
    await repo.update(clientId, draft('Second'));
    final other = await repo.create(draft('Other'));
    api.onDynamic('POST /transactions', (r) {
      final t = (r.data as Map)['transaction'] as Map;
      return t['client_id'] == clientId
          ? (
              422,
              {
                'error': {'message': 'Account is not one of yours'},
              }
            )
          : (201, serverJson(r, id: 100));
    });

    final result = await engine.push();

    expect(result.failed, 1);
    expect((await repo.findByClientId(other))!.serverId, 100);
    final left = await db.select(db.outbox).get();
    expect(left.map((o) => o.operation), ['create', 'update']);
    expect(left.first.lastError, 'Account is not one of yours');
  });
}
