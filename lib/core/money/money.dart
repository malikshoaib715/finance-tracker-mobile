/// Formats amounts stored as integer minor units (paisa, cents) — the same
/// representation the API uses — without ever going through floating point.
abstract final class Money {
  static const units = {
    'PKR': 'Rs ',
    'USD': r'$',
    'EUR': '€',
    'GBP': '£',
    'AED': 'AED ',
    'SAR': 'SAR ',
  };

  /// `Money.format(123450, 'PKR')` → `Rs 1,234.50`; negatives as `-Rs 5.00`.
  /// With [southAsian] grouping: `Money.format(15000000, 'PKR', southAsian: true)`
  /// → `Rs 1,50,000.00`.
  static String format(
    int cents,
    String currency, {
    bool southAsian = false,
    bool signed = false,
  }) {
    final unit = units[currency] ?? '$currency ';
    final sign = cents < 0 ? '-' : (signed && cents > 0 ? '+' : '');
    final abs = cents.abs();
    final whole = abs ~/ 100;
    final fraction = (abs % 100).toString().padLeft(2, '0');
    final grouped = southAsian
        ? _groupSouthAsian(whole.toString())
        : _group(whole.toString());
    return '$sign$unit$grouped.$fraction';
  }

  /// Parses user input like "1,250.5" into minor units. Null when invalid.
  static int? parse(String input) {
    final text = input.replaceAll(',', '').trim();
    final match = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$').firstMatch(text);
    if (match == null) return null;
    final whole = int.parse(match.group(1)!);
    final fraction = (match.group(2) ?? '').padRight(2, '0');
    return whole * 100 + int.parse(fraction);
  }

  static String _group(String digits) => digits.replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );

  /// Last three digits, then pairs: 1,23,45,678.
  static String _groupSouthAsian(String digits) {
    if (digits.length <= 3) return digits;
    final head = digits.substring(0, digits.length - 3);
    final tail = digits.substring(digits.length - 3);
    final pairs = head.replaceAllMapped(
      RegExp(r'\B(?=(\d{2})+(?!\d))'),
      (_) => ',',
    );
    return '$pairs,$tail';
  }
}
