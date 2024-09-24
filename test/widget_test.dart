import 'package:finance_tracker_mobile/core/auth/token_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_api.dart';
import 'support/harness.dart';

void main() {
  testWidgets('signed-out users land on sign in', (tester) async {
    await tester.pumpWidget(testApp(api: FakeApi()));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
    await unmountApp(tester);
  });

  testWidgets('a stored, valid token goes straight home', (tester) async {
    await tester.pumpWidget(
      testApp(api: signedInApi(), tokens: InMemoryTokenStore('ft_ok')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Net worth'), findsOneWidget);
    await unmountApp(tester);
  });
}
