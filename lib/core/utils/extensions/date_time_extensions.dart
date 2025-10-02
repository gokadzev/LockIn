/// Extension methods for DateTime to simplify common date operations
extension DateTimeX on DateTime {
  /// Returns a new DateTime with only the date component (time set to midnight)
  DateTime get dateOnly => DateTime(year, month, day);

  /// Checks if this DateTime is on the same calendar day as another
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Checks if this DateTime is today
  bool get isToday => isSameDay(DateTime.now());

  /// Checks if this DateTime is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(yesterday);
  }

  /// Checks if this DateTime is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(tomorrow);
  }
}
