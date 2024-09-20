import 'package:drift/native.dart';
import 'package:finance_tracker_mobile/data/database.dart';
import 'package:finance_tracker_mobile/data/reference_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_api.dart';

Map<String, dynamic> account(int id, String name,
        {int position = 0, bool archived = false}) =>
    {
      'id': id,
      'name': name,
      'kind': 'bank',
      'currency': 'PKR',
      'position': position,
      'balance_cents': 100000 * id,
      'archived_at': archived ? '2024-09-01T00:00:00Z' : null,
    };

void main() {
  late AppDatabase db;
  late FakeApi api;
  late ReferenceRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    api = FakeApi()
      ..on(
        'GET /categories',
        (
          200,
          {
            'categories': [
              {
                'id': 1,
                'name': 'Groceries',
                'kind': 'expense',
                'color': 'lime'
              },
            ],
          }
        ),
      );
    repo = ReferenceRepository(db, api.client());
  });
  tearDown(() => db.close());

  test('caches active accounts in the user’s order', () async {
    api.on(
      'GET /accounts',
      (
        200,
        {
          'accounts': [
            account(2, 'Wallet cash', position: 2),
            account(1, 'Meezan Current', position: 1),
            account(3, 'Old card', position: 3, archived: true),
          ],
        }
      ),
    );

    await repo.refresh();

    final accounts = await repo.watchAccounts().first;
    expect(accounts.map((a) => a.name), ['Meezan Current', 'Wallet cash']);
    expect((await repo.watchCategories().first).single.name, 'Groceries');
  });

  test('a refresh drops accounts deleted on the server', () async {
    api.on('GET /accounts', (
      200,
      {
        'accounts': [account(1, 'A'), account(2, 'B')]
      }
    ));
    await repo.refresh();
    api.on('GET /accounts', (
      200,
      {
        'accounts': [account(1, 'A')]
      }
    ));
    await repo.refresh();

    expect((await repo.watchAccounts().first).map((a) => a.id), [1]);
  });
}
