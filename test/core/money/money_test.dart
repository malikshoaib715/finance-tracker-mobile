import 'package:finance_tracker_mobile/core/money/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('format', () {
    test('international grouping', () {
      expect(Money.format(123450, 'PKR'), 'Rs 1,234.50');
      expect(Money.format(500, 'USD'), r'$5.00');
      expect(Money.format(-500, 'USD'), r'-$5.00');
      expect(Money.format(99, 'EUR'), '€0.99');
      expect(Money.format(1000, 'JPY'), 'JPY 10.00');
    });

    test('lakh and crore grouping', () {
      expect(Money.format(15000000, 'PKR', southAsian: true), 'Rs 1,50,000.00');
      expect(
        Money.format(1234567890, 'PKR', southAsian: true),
        'Rs 1,23,45,678.90',
      );
      expect(Money.format(99900, 'PKR', southAsian: true), 'Rs 999.00');
    });

    test('explicit plus sign for income', () {
      expect(Money.format(2500, 'PKR', signed: true), '+Rs 25.00');
    });
  });

  group('parse', () {
    test('accepts commas and up to two decimals', () {
      expect(Money.parse('1,250.5'), 125050);
      expect(Money.parse('99'), 9900);
      expect(Money.parse(' 0.07 '), 7);
    });

    test('rejects anything else', () {
      expect(Money.parse(''), isNull);
      expect(Money.parse('12.345'), isNull);
      expect(Money.parse('-5'), isNull);
      expect(Money.parse('abc'), isNull);
    });
  });
}
