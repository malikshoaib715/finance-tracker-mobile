import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:finance_tracker_mobile/core/auth/token_store.dart';
import 'package:finance_tracker_mobile/data/database.dart';
import 'package:finance_tracker_mobile/data/transactions_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  testWidgets('says when an edit lost to a newer one from the web',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            clientId: 'c-1',
            serverId: const Value(99),
            accountId: 1,
            kind: 'expense',
            amountCents: 125000,
            occurredOn: DateTime(2024, 10, 1),
            description: 'Careem',
            serverUpdatedAt: Value(DateTime.utc(2024, 10, 1, 9)),
          ),
        );
    await TransactionsRepository(db).update(
      'c-1',
      TransactionDraft(
        accountId: 1,
        kind: 'expense',
        amountCents: 125000,
        occurredOn: DateTime(2024, 10, 1),
        description: 'Phone edit',
      ),
    );
    final api = signedInApi()
      ..on('PATCH /transactions/99', (
        409,
        {
          'error': {'message': 'Changed on the server since you last synced'},
          'transaction': {
            'id': 99,
            'client_id': 'c-1',
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

    await tester.pumpWidget(
      testApp(api: api, tokens: InMemoryTokenStore('ft_ok'), db: db),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('your change was replaced with the newer version'),
      findsOneWidget,
    );
    await unmountApp(tester);
  });
}
