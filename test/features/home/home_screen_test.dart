import 'package:finance_tracker_mobile/core/auth/token_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_api.dart';
import '../../support/harness.dart';

void main() {
  testWidgets('shows the summary', (tester) async {
    await tester.pumpWidget(
      testApp(api: signedInApi(), tokens: InMemoryTokenStore('ft_ok')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hi, Ayesha'), findsOneWidget);
    expect(find.text('Rs 2,376,000.00'), findsOneWidget);
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

  testWidgets('pull to refresh syncs, then reloads the summary',
      (tester) async {
    final api = signedInApi();
    await tester.pumpWidget(
      testApp(api: api, tokens: InMemoryTokenStore('ft_ok')),
    );
    await tester.pumpAndSettle();
    int count(String path) =>
        api.requests.where((r) => r.path.endsWith(path)).length;
    final summaries = count('/summary');
    final feeds = count('/transactions');

    api.on('GET /summary', (
      200,
      {...testSummary, 'net_worth_cents': 240000000},
    ));
    await tester.fling(find.text('Net worth'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(count('/transactions'), greaterThan(feeds));
    expect(count('/summary'), greaterThan(summaries));
    expect(find.text('Rs 2,400,000.00'), findsOneWidget);
    await unmountApp(tester);
  });
}
