import 'package:finance_tracker_mobile/app/app.dart';
import 'package:finance_tracker_mobile/core/auth/token_store.dart';
import 'package:finance_tracker_mobile/core/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_api.dart';

void main() {
  testWidgets('signed-out users land on sign in', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [tokenStoreProvider.overrideWithValue(InMemoryTokenStore())],
        child: const FinanceTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsWidgets);
  });

  testWidgets('a stored, valid token goes straight home', (tester) async {
    final api = FakeApi()
      ..on(
        'GET /me',
        (
          200,
          {'id': 1, 'name': 'Ayesha Khan', 'email': 'a@example.com'},
        ),
      );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStoreProvider.overrideWithValue(InMemoryTokenStore('ft_ok')),
          apiClientProvider.overrideWithValue(api.client()),
        ],
        child: const FinanceTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Your money at a glance'), findsOneWidget);
  });
}
