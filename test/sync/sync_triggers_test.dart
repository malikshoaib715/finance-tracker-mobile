import 'dart:async';

import 'package:drift/native.dart';
import 'package:finance_tracker_mobile/core/providers.dart';
import 'package:finance_tracker_mobile/data/database.dart';
import 'package:finance_tracker_mobile/data/transactions_repository.dart';
import 'package:finance_tracker_mobile/sync/sync_controller.dart';
import 'package:finance_tracker_mobile/sync/sync_triggers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Counts sync requests instead of talking to a server.
class CountingSync extends SyncController {
  int calls = 0;

  @override
  Future<void> sync() async => calls++;
}

void main() {
  late AppDatabase db;
  late CountingSync sync;
  late StreamController<bool> online;

  setUp(() {
    sync = CountingSync();
    online = StreamController<bool>.broadcast();
  });
  tearDown(() => online.close());

  // The database is created inside the test so it runs in the widget test's
  // fake-async zone like everything else.
  Future<void> pumpTriggers(WidgetTester tester) {
    db = AppDatabase(NativeDatabase.memory());
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          syncControllerProvider.overrideWith(() => sync),
          connectivityChangesProvider.overrideWithValue(online.stream),
        ],
        child: const SyncTriggers(child: SizedBox()),
      ),
    );
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 3));
    await db.close();
  }

  testWidgets('syncs on start and when connectivity returns', (tester) async {
    await pumpTriggers(tester);
    await tester.pump();
    expect(sync.calls, 1);

    online.add(false);
    await tester.pump();
    expect(sync.calls, 1);

    online.add(true);
    await tester.pump();
    expect(sync.calls, 2);

    await unmount(tester);
  });

  testWidgets('syncs when the app comes back to the foreground',
      (tester) async {
    await pumpTriggers(tester);
    await tester.pump();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(sync.calls, 2);
    await unmount(tester);
  });

  testWidgets('a burst of local edits becomes one debounced sync',
      (tester) async {
    await pumpTriggers(tester);
    await tester.pump();
    final start = sync.calls;

    final repo = TransactionsRepository(db);
    for (final name in ['Tea', 'Samosa', 'Chai']) {
      await repo.create(
        TransactionDraft(
          accountId: 1,
          kind: 'expense',
          amountCents: 5000,
          occurredOn: DateTime(2024, 10, 4),
          description: name,
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }

    await tester.pump(const Duration(seconds: 1));
    expect(sync.calls, start);

    await tester.pump(const Duration(seconds: 2));
    expect(sync.calls, start + 1);

    await unmount(tester);
  });
}
