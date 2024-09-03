import 'package:finance_tracker_mobile/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app starts', (tester) async {
    await tester.pumpWidget(const FinanceTrackerApp());
    expect(find.text('Finance Tracker'), findsOneWidget);
  });
}
