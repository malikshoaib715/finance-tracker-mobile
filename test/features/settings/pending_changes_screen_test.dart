import 'package:drift/native.dart';
import 'package:finance_tracker_mobile/core/auth/token_store.dart';
import 'package:finance_tracker_mobile/data/database.dart';
import 'package:finance_tracker_mobile/data/transactions_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';

void main() {
  testWidgets('lists changes the server rejected, with the reason',
      (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final db = AppDatabase(NativeDatabase.memory());
    await TransactionsRepository(db).create(
      TransactionDraft(
        accountId: 1,
        kind: 'expense',
        amountCents: 50000,
        occurredOn: DateTime(2024, 10, 21),
        description: 'Careem',
      ),
    );
    final api = signedInApi()
      ..on('POST /transactions', (
        422,
        {
          'error': {'message': 'Account must exist'},
        }
      ));

    await tester.pumpWidget(
      testApp(api: api, tokens: InMemoryTokenStore('ft_ok'), db: db),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Waiting to upload'));
    await tester.pumpAndSettle();

    expect(find.text('New: Careem'), findsOneWidget);
    expect(find.textContaining('Account must exist'), findsOneWidget);

    // Rejected changes aren't sent again until edited or discarded.
    final posts = api.requests.where((r) => r.method == 'POST').length;
    await tester.tap(find.byTooltip('Retry now'));
    await tester.pumpAndSettle();
    expect(api.requests.where((r) => r.method == 'POST').length, posts);

    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Discard'));
    await tester.pumpAndSettle();
    expect(find.text('Everything is uploaded.'), findsOneWidget);
    expect(await db.select(db.transactions).get(), isEmpty);
    await unmountApp(tester);
  });
}
