import 'package:finance_tracker_mobile/data/database.dart';
import 'package:finance_tracker_mobile/sync/transaction_json.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds a request body with the client id and a plain date', () {
    final body = TransactionJson.toRequest(
      Transaction(
        localId: 1,
        clientId: 'c-1',
        accountId: 3,
        kind: 'expense',
        amountCents: 125000,
        occurredOn: DateTime(2024, 9, 3),
        description: 'Careem',
        tags: 'work',
      ),
    );
    expect(body['client_id'], 'c-1');
    expect(body['occurred_on'], '2024-09-03');
    expect(body['tag_list'], 'work');
  });

  test('reads a server transaction, giving server-made rows a stable client id',
      () {
    final row = TransactionJson.fromServer({
      'id': 42,
      'client_id': null,
      'account_id': 3,
      'category_id': 7,
      'kind': 'income',
      'amount_cents': 28500000,
      'occurred_on': '2024-09-01',
      'description': 'Salary',
      'notes': null,
      'tags': ['work', 'monthly'],
      'updated_at': '2024-09-01T10:00:00.123456Z',
    });
    expect(row.serverId.value, 42);
    expect(row.clientId.value, 'server-42');
    expect(row.tags.value, 'work, monthly');
    expect(row.serverUpdatedAt.value,
        DateTime.utc(2024, 9, 1, 10, 0, 0, 123, 456));
  });
}
