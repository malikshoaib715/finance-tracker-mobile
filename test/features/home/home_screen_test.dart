import 'package:finance_tracker_mobile/core/auth/token_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_api.dart';
import '../../support/harness.dart';

void main() {
  testWidgets('shows the summary and signs out after confirming',
      (tester) async {
    final tokens = InMemoryTokenStore('ft_ok');
    await tester.pumpWidget(testApp(api: signedInApi(), tokens: tokens));
    await tester.pumpAndSettle();

    expect(find.text('Hi, Ayesha'), findsOneWidget);
    expect(find.text('Rs 2,376,000.00'), findsOneWidget);

    await tester.tap(find.byTooltip('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Sign out'));
    await tester.pumpAndSettle();

    expect(await tokens.read(), isNull);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
    await unmountApp(tester);
  });

  testWidgets('loads accounts from the server without a manual refresh',
      (tester) async {
    final api = signedInApi()
      ..on('GET /accounts', (
        200,
        {
          'accounts': [
            {
              'id': 1,
              'name': 'Meezan Current',
              'kind': 'bank',
              'currency': 'PKR',
              'position': 1,
              'balance_cents': 15000000,
              'archived_at': null,
            },
          ],
        }
      ));
    await tester.pumpWidget(
      testApp(api: api, tokens: InMemoryTokenStore('ft_ok')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Meezan Current'), findsOneWidget);
    expect(find.text('Rs 150,000.00'), findsOneWidget);
    await unmountApp(tester);
  });

  testWidgets('shows an error with retry when offline and nothing is cached',
      (tester) async {
    final api = FakeApi()..on('GET /me', (200, testUser));
    await tester.pumpWidget(
      testApp(api: api, tokens: InMemoryTokenStore('ft_ok')),
    );
    await tester.pumpAndSettle();

    expect(find.text('No connection to the server'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    await unmountApp(tester);
  });
}
