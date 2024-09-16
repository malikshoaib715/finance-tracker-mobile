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
}
