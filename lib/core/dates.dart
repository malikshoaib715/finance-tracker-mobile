/// Small date labels, kept here so the app doesn't need `intl` for English-only text.
abstract final class Dates {
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July', //
    'August', 'September', 'October', 'November', 'December',
  ];
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  /// `September 2024`
  static String month(DateTime date) =>
      '${_months[date.month - 1]} ${date.year}';

  /// `Today`, `Yesterday`, `Mon 2 Sep`, or `Fri 29 Dec 2023` in other years.
  static String day(DateTime date, {DateTime? now}) {
    final today = dateOnly(now ?? DateTime.now());
    final difference = today.difference(dateOnly(date)).inDays;
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    final label = '${_weekdays[date.weekday - 1]} ${date.day} '
        '${_months[date.month - 1].substring(0, 3)}';
    return date.year == today.year ? label : '$label ${date.year}';
  }

  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
