import 'package:drift/native.dart';
import 'package:finance_tracker_mobile/app/app.dart';
import 'package:finance_tracker_mobile/core/auth/token_store.dart';
import 'package:finance_tracker_mobile/core/providers.dart';
import 'package:finance_tracker_mobile/data/database.dart';
import 'package:finance_tracker_mobile/sync/sync_triggers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'fake_api.dart';

const testUser = {'id': 1, 'name': 'Ayesha Khan', 'email': 'a@example.com'};

const testSummary = {
  'month': '2024-09',
  'currency': 'PKR',
  'income_cents': 28500000,
  'expense_cents': 12018300,
  'net_worth_cents': 237600000,
  'budgets': <Object>[],
};

/// A FakeApi answering the calls the signed-in app makes on start.
FakeApi signedInApi() => FakeApi()
  ..on('GET /me', (200, testUser))
  ..on('GET /summary', (200, testSummary))
  ..on('GET /accounts', (200, {'accounts': <Object>[]}))
  ..on('GET /categories', (200, {'categories': <Object>[]}))
  ..on('DELETE /session', (204, null))
  ..on('GET /transactions', (
    200,
    {'transactions': <Object>[], 'next_cursor': null},
  ))
  ..on('GET /deletions', (200, {'deletions': <Object>[]}));

/// The whole app with test doubles for storage, network and database.
Widget testApp({
  required FakeApi api,
  TokenStore? tokens,
  AppDatabase? db,
  Stream<bool>? connectivity,
}) =>
    ProviderScope(
      overrides: [
        tokenStoreProvider.overrideWithValue(tokens ?? InMemoryTokenStore()),
        apiClientProvider.overrideWithValue(api.client()),
        databaseProvider
            .overrideWithValue(db ?? AppDatabase(NativeDatabase.memory())),
        connectivityChangesProvider
            .overrideWithValue(connectivity ?? const Stream.empty()),
      ],
      child: const FinanceTrackerApp(),
    );

/// Unmounts the app and lets Drift's delayed stream-close timers fire, so the
/// test doesn't end with timers pending.
Future<void> unmountApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 3));
}
