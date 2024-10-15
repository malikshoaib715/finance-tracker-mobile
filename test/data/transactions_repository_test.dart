import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:finance_tracker_mobile/data/database.dart';
import 'package:finance_tracker_mobile/data/transactions_repository.dart';
import 'package:flutter_test/flutter_test.dart';

TransactionDraft draft({String description = 'Careem', DateTime? on}) =>
    TransactionDraft(
      accountId: 1,
      kind: 'expense',
      amountCents: 125000,
      occurredOn: on ?? DateTime(2024, 9, 27),
      description: description,
    );

void main() {
  late AppDatabase db;
  late TransactionsRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = TransactionsRepository(db);
  });
  tearDown(() => db.close());

  test('creating saves the row and queues it in one go', () async {
    final clientId = await repo.create(draft(description: '  Careem  '));

    final saved = await repo.findByClientId(clientId);
    expect(saved!.description, 'Careem');
    expect(saved.serverId, isNull);

    final outbox = await db.select(db.outbox).get();
    expect(outbox.single.operation, 'create');
    expect(outbox.single.clientId, clientId);
  });

  test('edits and deletes are queued too', () async {
    final clientId = await repo.create(draft());
    await repo.update(clientId, draft(description: 'Careem ride'));
    await repo.delete(clientId);

    expect(await repo.findByClientId(clientId), isNull);
    final ops = (await db.select(db.outbox).get()).map((o) => o.operation);
    expect(ops, ['create', 'update', 'delete']);
  });

  test('watches one month, newest first', () async {
    await repo.create(draft(description: 'Aug', on: DateTime(2024, 8, 31)));
    await repo.create(draft(description: 'Early', on: DateTime(2024, 9, 1)));
    await repo.create(draft(description: 'Late', on: DateTime(2024, 9, 30)));

    final september = await repo.watchMonth(DateTime(2024, 9)).first;
    expect(september.map((t) => t.description), ['Late', 'Early']);
  });

  test('undoing a delete before it syncs drops the queued delete', () async {
    final clientId = await repo.create(draft());
    await db.delete(db.outbox).go(); // as if the create was pushed
    final deleted = await repo.delete(clientId);

    await repo.restore(deleted!);

    final restored = await repo.findByClientId(clientId);
    expect(restored, deleted);
    expect(await db.select(db.outbox).get(), isEmpty);
  });

  test('undoing a delete that already synced re-creates the transaction',
      () async {
    final clientId = await repo.create(draft());
    await (db.update(db.transactions)
          ..where((t) => t.clientId.equals(clientId)))
        .write(const TransactionsCompanion(serverId: Value(42)));
    final deleted = await repo.delete(clientId);
    await db.delete(db.outbox).go(); // the delete was pushed

    await repo.restore(deleted!);

    final row = (await db.select(db.transactions).get()).single;
    expect(row.clientId, isNot(clientId));
    expect((row.serverId, row.description), (null, 'Careem'));
    final outbox = await db.select(db.outbox).get();
    expect((outbox.single.operation, outbox.single.clientId),
        ('create', row.clientId));
  });

  test('searches description and notes across months', () async {
    await repo.create(
        draft(description: 'Careem to office', on: DateTime(2024, 8, 3)));
    await repo
        .create(draft(description: 'Groceries', on: DateTime(2024, 9, 10)));
    final withNote = TransactionDraft(
      accountId: 2,
      kind: 'expense',
      amountCents: 90000,
      occurredOn: DateTime(2024, 9, 20),
      description: 'Fuel',
      notes: 'careem bike top-up',
    );
    await repo.create(withNote);

    final found = await repo.watchSearch(' CAREEM ').first;
    expect(found.map((t) => t.description), ['Fuel', 'Careem to office']);

    final inAccount = await repo.watchSearch('careem', accountId: 1).first;
    expect(inAccount.map((t) => t.description), ['Careem to office']);
    expect(await repo.watchSearch('%').first, hasLength(3));
  });
}
