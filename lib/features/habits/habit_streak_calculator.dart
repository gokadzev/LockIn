/// Service for calculating and managing habit streaks
class HabitStreakCalculator {
  HabitStreakCalculator._();

  /// Calculates the current streak based on habit history.
  ///
  /// The streak is the number of consecutive days (up to and including today)
  /// that the habit was completed. Days are normalized to date-only (ignoring time).
  ///
  /// Returns 0 if history is empty or if the streak was broken.
  static int calculateStreak(List<DateTime> history) {
    if (history.isEmpty) return 0;

    final normalizedHistory = _normalizeAndSort(history);
    final today = _normalizeDate(DateTime.now());

    return _countConsecutiveDays(normalizedHistory, today);
  }

  /// Normalizes all history dates to date-only (removing time component)
  /// and removes duplicates, then sorts chronologically.
  static List<DateTime> _normalizeAndSort(List<DateTime> history) {
    return history.map((d) => DateTime(d.year, d.month, d.day)).toSet().toList()
      ..sort();
  }

  /// Normalizes a date to date-only (removes time component)
  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Counts consecutive days backwards from the given start date
  static int _countConsecutiveDays(
    List<DateTime> sortedHistory,
    DateTime startDate,
  ) {
    var streak = 0;
    var cursor = startDate;

    while (sortedHistory.any((d) => _isSameDay(d, cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Checks if two dates represent the same calendar day
  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Checks if a date is today
  static bool isToday(DateTime date) {
    return _isSameDay(date, DateTime.now());
  }

  /// Normalizes history by ensuring only one entry per day
  /// and returns a sorted list of date-only DateTime objects
  static List<DateTime> normalizeHistory(List<DateTime> history) {
    return _normalizeAndSort(history);
  }

  /// Adds today to the history if not already present
  static List<DateTime> addTodayToHistory(List<DateTime> history) {
    final normalized = normalizeHistory(history);
    final today = _normalizeDate(DateTime.now());

    if (!normalized.any((d) => _isSameDay(d, today))) {
      return [...normalized, today]..sort();
    }

    return normalized;
  }

  /// Removes today from the history if present
  static List<DateTime> removeTodayFromHistory(List<DateTime> history) {
    final normalized = normalizeHistory(history);
    final today = _normalizeDate(DateTime.now());

    return normalized.where((d) => !_isSameDay(d, today)).toList();
  }
}
