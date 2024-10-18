import 'package:drift/native.dart';
import 'package:finance_tracker_mobile/core/auth/token_store.dart';
import 'package:finance_tracker_mobile/data/database.dart';
import 'package:finance_tracker_mobile/data/transactions_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';

void main() {
  testWidgets('shows the user and pending changes, and signs out',
      (tester) async {
    // A phone-sized screen (the default 800x600 test surface is landscape).
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final db = AppDatabase(NativeDatabase.memory());
    await TransactionsRepository(db).create(
      TransactionDraft(
        accountId: 1,
        kind: 'expense',
        amountCents: 50000,
        occurredOn: DateTime(2024, 10, 17),
        description: 'Careem',
      ),
    );
    final tokens = InMemoryTokenStore('ft_ok');
    // No POST handler: the upload fails, so the change stays pending.
    await tester
        .pumpWidget(testApp(api: signedInApi(), tokens: tokens, db: db));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Ayesha Khan'), findsOneWidget);
    expect(find.text('a@example.com'), findsOneWidget);
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Waiting to upload'),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(
        find.textContaining('1 change(s) haven’t synced yet'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Sign out'));
    await tester.pumpAndSettle();

    expect(await tokens.read(), isNull);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
    await unmountApp(tester);
  });
}
