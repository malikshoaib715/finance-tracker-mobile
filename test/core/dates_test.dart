import 'package:finance_tracker_mobile/core/dates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2024, 10, 7, 23, 0);

  test('labels months and recent days', () {
    expect(Dates.month(DateTime(2024, 9, 14)), 'September 2024');
    expect(Dates.day(DateTime(2024, 10, 7, 8), now: now), 'Today');
    expect(Dates.day(DateTime(2024, 10, 6), now: now), 'Yesterday');
    expect(Dates.day(DateTime(2024, 9, 2), now: now), 'Mon 2 Sep');
  });
}
