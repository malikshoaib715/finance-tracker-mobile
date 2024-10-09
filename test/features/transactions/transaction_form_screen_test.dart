import 'package:drift/native.dart';
import 'package:finance_tracker_mobile/core/auth/token_store.dart';
import 'package:finance_tracker_mobile/data/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';

void main() {
  Future<AppDatabase> openList(WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());
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
    return db;
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  Future<void> tapButton(WidgetTester tester, String label) async {
    final button = find.widgetWithText(FilledButton, label);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('validates, then adds a transaction and queues it for sync',
      (tester) async {
    final db = await openList(tester);
    await tester.tap(find.byTooltip('Add transaction'));
    await tester.pumpAndSettle();

    await tapButton(tester, 'Add transaction');
    expect(find.text('Enter an amount like 1,250.50'), findsOneWidget);
    expect(find.text('Add a short description'), findsOneWidget);

    await tester.enterText(field('Amount'), '0');
    await tapButton(tester, 'Add transaction');
    expect(find.text('Amount must be more than zero'), findsOneWidget);

    await tester.enterText(field('Amount'), '2,450.5');
    await tester.enterText(field('Description'), 'Imtiaz groceries');
    await tester.tap(find.text('Uncategorised'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Groceries').last);
    await tester.pumpAndSettle();
    await tapButton(tester, 'Add transaction');

    expect(find.text('Imtiaz groceries'), findsOneWidget);
    expect(find.text('-Rs 2,450.50'), findsOneWidget);
    final saved = await db.select(db.transactions).getSingle();
    expect(
        (saved.amountCents, saved.categoryId, saved.accountId), (245050, 5, 1));
    expect(
        (await db.select(db.outbox).get()).map((o) => o.operation), ['create']);
    await unmountApp(tester);
  });

  testWidgets('edits an existing transaction', (tester) async {
    final db = await openList(tester);
    await tester.tap(find.byTooltip('Add transaction'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Amount'), '500');
    await tester.enterText(field('Description'), 'Careem');
    await tapButton(tester, 'Add transaction');

    await tester.tap(find.text('Careem'));
    await tester.pumpAndSettle();
    expect(find.text('Edit transaction'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '500'), findsOneWidget);

    await tester.enterText(field('500'), '650');
    await tapButton(tester, 'Save changes');

    expect(find.text('-Rs 650.00'), findsOneWidget);
    expect(
      (await db.select(db.outbox).get()).map((o) => o.operation),
      ['create', 'update'],
    );
    await unmountApp(tester);
  });

  Future<void> addCareem(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Add transaction'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Amount'), '500');
    await tester.enterText(field('Description'), 'Careem');
    await tapButton(tester, 'Add transaction');
  }

  testWidgets('swipe deletes a transaction and Undo brings it back',
      (tester) async {
    final db = await openList(tester);
    await addCareem(tester);

    await tester.drag(find.text('Careem'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('Careem'), findsNothing);
    expect(find.text('Deleted “Careem”'), findsOneWidget);
    expect(await db.select(db.transactions).get(), isEmpty);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Careem'), findsOneWidget);
    expect(
        (await db.select(db.transactions).get()).single.description, 'Careem');
    await unmountApp(tester);
  });

  testWidgets('deletes from the edit screen', (tester) async {
    final db = await openList(tester);
    await addCareem(tester);

    await tester.tap(find.text('Careem'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Deleted “Careem”'), findsOneWidget);
    expect(await db.select(db.transactions).get(), isEmpty);
    await unmountApp(tester);
  });
}
