import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:finance_tracker_mobile/core/auth/token_store.dart';
import 'package:finance_tracker_mobile/data/database.dart';
import 'package:finance_tracker_mobile/features/transactions/transactions_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  TransactionsCompanion row(
    String clientId,
    String description,
    int cents,
    DateTime on, {
    String kind = 'expense',
    int? serverId,
  }) =>
      TransactionsCompanion.insert(
        clientId: clientId,
        serverId: Value(serverId),
        accountId: 1,
        categoryId: const Value(5),
        kind: kind,
        amountCents: cents,
        occurredOn: on,
        description: description,
      );

  test('groups transactions by day, keeping order', () {
    Transaction t(int id, DateTime on) => Transaction(
          localId: id,
          clientId: 'c$id',
          accountId: 1,
          kind: 'expense',
          amountCents: 100,
          occurredOn: on,
          description: 'x',
          tags: '',
        );
    final groups = groupByDay([
      t(3, DateTime(2024, 10, 7, 20)),
      t(2, DateTime(2024, 10, 7, 9)),
      t(1, DateTime(2024, 10, 5)),
    ]);

    expect(groups.map((g) => g.day),
        [DateTime(2024, 10, 7), DateTime(2024, 10, 5)]);
    expect(groups.first.transactions.map((t) => t.localId), [3, 2]);
  });

  testWidgets('lists this month’s transactions by day and marks unsynced ones',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.batch((b) => b.insertAll(db.transactions, [
          row('a', 'Salary', 28500000, today, kind: 'income', serverId: 10),
          row('b', 'Imtiaz groceries', 1245000, today),
        ]));
    final api = signedInApi()
      ..on('GET /accounts', (
        200,
        {
          'accounts': [
            {
              'id': 1,
              'name': 'Meezan Current',
              'kind': 'bank',
              'currency': 'PKR',
              'position': 1,
              'balance_cents': 0,
              'archived_at': null,
            },
          ],
        }
      ))
      ..on('GET /categories', (
        200,
        {
          'categories': [
            {
              'id': 5,
              'name': 'Groceries',
              'kind': 'expense',
              'color': '#10b981'
            },
          ],
        }
      ));

    await tester.pumpWidget(
      testApp(api: api, tokens: InMemoryTokenStore('ft_ok'), db: db),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Transactions'));
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('+Rs 285,000.00'), findsOneWidget);
    expect(find.text('-Rs 12,450.00'), findsOneWidget);
    expect(find.text('Groceries'), findsNWidgets(2));
    expect(find.byTooltip('Not synced yet'), findsOneWidget);

    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text('No transactions this month.'), findsOneWidget);
    await unmountApp(tester);
  });
}
