import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:finance_tracker_mobile/core/auth/token_store.dart';
import 'package:finance_tracker_mobile/data/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';

void main() {
  testWidgets('an account shows only its own transactions', (tester) async {
    final now = DateTime.now();
    final db = AppDatabase(NativeDatabase.memory());
    await db.batch(
      (b) => b.insertAll(db.transactions, [
        for (final (id, account, text) in [
          (1, 1, 'Imtiaz groceries'),
          (2, 2, 'Card payment'),
        ])
          TransactionsCompanion.insert(
            clientId: 'c$id',
            serverId: Value(id),
            accountId: account,
            kind: 'expense',
            amountCents: 100000,
            occurredOn: DateTime(now.year, now.month, now.day),
            description: text,
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
    await tester.tap(find.text('Meezan Current'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Meezan Current'), findsOneWidget);
    expect(find.text('Imtiaz groceries'), findsOneWidget);
    expect(find.text('Card payment'), findsNothing);

    await tester.tap(find.byTooltip('Add transaction'));
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(DropdownButtonFormField<int>, 'Meezan Current'),
      findsOneWidget,
    );
    await unmountApp(tester);
  });
}
