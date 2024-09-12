import 'package:finance_tracker_mobile/core/auth/token_store.dart';
import 'package:finance_tracker_mobile/core/providers.dart';
import 'package:finance_tracker_mobile/features/auth/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_api.dart';

Widget screen(FakeApi api, TokenStore tokens) => ProviderScope(
      overrides: [
        tokenStoreProvider.overrideWithValue(tokens),
        apiClientProvider.overrideWithValue(api.client(token: null)),
      ],
      child: const MaterialApp(home: SignInScreen()),
    );

void main() {
  test('validates email and password', () {
    expect(SignInScreenValidators.email(''), 'Enter your email');
    expect(SignInScreenValidators.email('nope'), isNotNull);
    expect(SignInScreenValidators.email('a@b.co'), isNull);
    expect(SignInScreenValidators.password(''), 'Enter your password');
  });

  testWidgets('shows field errors without calling the server', (tester) async {
    final api = FakeApi();
    await tester.pumpWidget(screen(api, InMemoryTokenStore()));

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();

    expect(find.text('Enter your email'), findsOneWidget);
    expect(api.requests, isEmpty);
  });

  testWidgets('shows the server error for wrong credentials', (tester) async {
    final api = FakeApi()
      ..on(
        'POST /session',
        (
          401,
          {
            'error': {'message': 'Invalid email or password'},
          }
        ),
      );
    await tester.pumpWidget(screen(api, InMemoryTokenStore()));

    await tester.enterText(find.byKey(const Key('email')), 'a@example.com');
    await tester.enterText(find.byKey(const Key('password')), 'wrong');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid email or password'), findsOneWidget);
  });

  testWidgets('stores the token on success', (tester) async {
    final tokens = InMemoryTokenStore();
    final api = FakeApi()
      ..on(
        'POST /session',
        (
          201,
          {
            'token': 'ft_new',
            'user': {'id': 1, 'name': 'Ayesha Khan', 'email': 'a@example.com'},
          }
        ),
      );
    await tester.pumpWidget(screen(api, tokens));

    await tester.enterText(find.byKey(const Key('email')), 'a@example.com');
    await tester.enterText(find.byKey(const Key('password')), 'password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(await tokens.read(), 'ft_new');
  });
}
