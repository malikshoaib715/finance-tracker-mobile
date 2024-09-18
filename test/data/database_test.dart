import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:finance_tracker_mobile/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('stores and replaces cached accounts by server id', () async {
    await db.into(db.accounts).insertOnConflictUpdate(
          AccountsCompanion.insert(
            id: const Value(3),
            name: 'Meezan Current',
            kind: 'bank',
            currency: 'PKR',
            balanceCents: 15000000,
          ),
        );
    await db.into(db.accounts).insertOnConflictUpdate(
          AccountsCompanion.insert(
            id: const Value(3),
            name: 'Meezan Current',
            kind: 'bank',
            currency: 'PKR',
            balanceCents: 14000000,
          ),
        );

    final rows = await db.select(db.accounts).get();
    expect(rows, hasLength(1));
    expect(rows.single.balanceCents, 14000000);
  });

  test('client ids are unique so a transaction is never stored twice',
      () async {
    TransactionsCompanion row() => TransactionsCompanion.insert(
          clientId: 'c-1',
          accountId: 3,
          kind: 'expense',
          amountCents: 1250,
          occurredOn: DateTime(2024, 9, 18),
          description: 'Careem',
        );

    await db.into(db.transactions).insert(row());
    expect(
      () => db.into(db.transactions).insert(row()),
      throwsA(isA<SqliteException>()),
    );
  });

  test('outbox keeps operations in order', () async {
    for (final op in ['create', 'update']) {
      await db
          .into(db.outbox)
          .insert(OutboxCompanion.insert(operation: op, clientId: 'c-1'));
    }
    final ops = await (db.select(db.outbox)
          ..orderBy([(o) => OrderingTerm.asc(o.id)]))
        .get();
    expect(ops.map((o) => o.operation), ['create', 'update']);
  });
}
