import 'package:drift/native.dart';
import 'package:finance_tracker_mobile/core/api/api_exception.dart';
import 'package:finance_tracker_mobile/data/database.dart';
import 'package:finance_tracker_mobile/features/home/data/summary_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_api.dart';

const summaryJson = {
  'month': '2024-09',
  'currency': 'PKR',
  'income_cents': 28500000,
  'expense_cents': 12018300,
  'net_worth_cents': 237600000,
  'budgets': [
    {
      'id': 1,
      'category': 'Groceries',
      'color': 'lime',
      'amount_cents': 4500000,
      'spent_cents': 1746800,
      'status': 'ok',
    },
  ],
};

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('loads the summary and caches it', () async {
    final api = FakeApi()..on('GET /summary', (200, summaryJson));
    final summary = await SummaryRepository(db, api.client()).load();

    expect(summary!.netCents, 28500000 - 12018300);
    expect(summary.budgets.single.ratio, closeTo(0.388, 0.001));
    expect(summary.stale, isFalse);
  });

  test('falls back to the cached copy when offline', () async {
    final online = FakeApi()..on('GET /summary', (200, summaryJson));
    await SummaryRepository(db, online.client()).load();

    final offline = FakeApi(); // no routes: every request fails to connect
    final summary = await SummaryRepository(db, offline.client()).load();

    expect(summary!.stale, isTrue);
    expect(summary.netWorthCents, 237600000);
  });

  test('offline with nothing cached is an error', () async {
    expect(
      () => SummaryRepository(db, FakeApi().client()).load(),
      throwsA(isA<NetworkException>()),
    );
  });
}
