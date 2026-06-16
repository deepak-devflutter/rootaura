/// Tiny formatting helpers (no intl dependency for such light needs).
class Format {
  Format._();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// e.g. "16 Jun 2026, 3:05 PM"
  static String dateTime(DateTime d) => '${date(d)}, ${time(d)}';

  /// e.g. "16 Jun 2026"
  static String date(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  /// e.g. "3:05 PM"
  static String time(DateTime d) {
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour < 12 ? 'AM' : 'PM';
    return '$h12:$m $ampm';
  }
}
