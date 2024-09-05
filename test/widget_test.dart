import 'package:finance_tracker_mobile/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app starts on the home screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: FinanceTrackerApp()));
    expect(find.text('Your money at a glance'), findsOneWidget);
  });
}
