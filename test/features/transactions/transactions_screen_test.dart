import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:finance_tracker_mobile/core/auth/token_store.dart';
import 'package:finance_tracker_mobile/data/database.dart';
import 'package:finance_tracker_mobile/features/transactions/transactions_providers.dart';
import 'package:flutter/material.dart';
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
    final api = apiWithReferenceData();

    await tester.pumpWidget(
      testApp(api: api, tokens: InMemoryTokenStore('ft_ok'), db: db),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Transactions'));
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('+Rs 285,000.00'), findsOneWidget);
    expect(find.text('-Rs 12,450.00'), findsOneWidget);
    expect(find.text('Groceries'), findsNWidgets(2)); // category 5 on both rows
    expect(find.byTooltip('Not synced yet'), findsOneWidget);

    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text('No transactions this month.'), findsOneWidget);
    await unmountApp(tester);
  });

  testWidgets('searches across months and returns to the month view',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.batch(
      (b) => b.insertAll(db.transactions, [
        row('a', 'Imtiaz groceries', 1245000, today, serverId: 1),
        row('b', 'Careem', 50000, DateTime(today.year, today.month - 2, 3),
            serverId: 2),
      ]),
    );
    await tester.pumpWidget(
      testApp(
        api: apiWithReferenceData(),
        tokens: InMemoryTokenStore('ft_ok'),
        db: db,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Transactions'));
    await tester.pumpAndSettle();
    expect(find.text('Careem'), findsNothing);

    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'care');
    await tester.pumpAndSettle();
    expect(find.text('Careem'), findsOneWidget);
    expect(find.text('Imtiaz groceries'), findsNothing);

    await tester.enterText(find.byType(TextField), 'nothing like this');
    await tester.pumpAndSettle();
    expect(find.text('Nothing matches your search.'), findsOneWidget);

    await tester.tap(find.byTooltip('Close search'));
    await tester.pumpAndSettle();
    expect(find.text('Imtiaz groceries'), findsOneWidget);
    expect(find.byTooltip('Previous month'), findsOneWidget);
    await unmountApp(tester);
  });

  testWidgets('filters by type and category', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.batch(
      (b) => b.insertAll(db.transactions, [
        row('a', 'Salary', 28500000, today, kind: 'income', serverId: 1),
        row('b', 'Imtiaz groceries', 1245000, today, serverId: 2),
        TransactionsCompanion.insert(
          clientId: 'c',
          serverId: const Value(3),
          accountId: 1,
          kind: 'expense',
          amountCents: 50000,
          occurredOn: today,
          description: 'Careem',
        ),
      ]),
    );
    await tester.pumpWidget(
      testApp(
        api: apiWithReferenceData(),
        tokens: InMemoryTokenStore('ft_ok'),
        db: db,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Transactions'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Income'));
    await tester.pumpAndSettle();
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Careem'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Expenses'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Category'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Groceries'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Imtiaz groceries'), findsOneWidget);
    expect(find.text('Careem'), findsNothing);
    expect(find.text('Salary'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Income'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilterChip, 'Category'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);
    await unmountApp(tester);
  });
}
