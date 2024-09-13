import 'package:finance_tracker_mobile/app/app.dart';
import 'package:finance_tracker_mobile/core/auth/token_store.dart';
import 'package:finance_tracker_mobile/core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_api.dart';

void main() {
  testWidgets('greets the user and signs out after confirming', (tester) async {
    final tokens = InMemoryTokenStore('ft_ok');
    final api = FakeApi()
      ..on(
        'GET /me',
        (
          200,
          {'id': 1, 'name': 'Ayesha Khan', 'email': 'a@example.com'},
        ),
      )
      ..on('DELETE /session', (204, null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStoreProvider.overrideWithValue(tokens),
          apiClientProvider.overrideWithValue(api.client()),
        ],
        child: const FinanceTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Hi, Ayesha'), findsOneWidget);

    await tester.tap(find.byTooltip('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Sign out'));
    await tester.pumpAndSettle();

    expect(await tokens.read(), isNull);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
  });
}
