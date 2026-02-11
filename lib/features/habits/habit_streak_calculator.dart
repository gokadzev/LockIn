/*
 *     Copyright (C) 2026 Valeri Gokadze
 *
 *     LockIn is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     LockIn is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

/// Service for calculating and managing habit streaks
class HabitStreakCalculator {
  HabitStreakCalculator._();

  /// Calculates the current streak based on habit history and frequency.
  ///
  /// For daily habits, the streak is consecutive days (including today or yesterday).
  /// For weekly/custom habits, the streak counts consecutive weeks with a completion.
  /// For monthly habits, the streak counts consecutive months with a completion.
  static int calculateStreak(
    List<DateTime> history, {
    required String frequency,
    String? cue,
  }) {
    if (history.isEmpty) return 0;

    final normalizedHistory = _normalizeAndSort(history);
    final today = _normalizeDate(DateTime.now());

    switch (frequency) {
      case 'weekly':
      case 'custom':
        return _countWeeklyStreak(normalizedHistory, today);
      case 'monthly':
        return _countMonthlyStreak(normalizedHistory, today);
      case 'daily':
      default:
        if (normalizedHistory.any((d) => _isSameDay(d, today))) {
          return _countConsecutiveDays(normalizedHistory, today);
        }

        final yesterday = today.subtract(const Duration(days: 1));
        if (normalizedHistory.any((d) => _isSameDay(d, yesterday))) {
          return _countConsecutiveDays(normalizedHistory, yesterday);
        }

        return 0;
    }
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
    final dayKeys = sortedHistory.map(_dayKey).toSet();
    var streak = 0;
    var cursor = startDate;

    while (dayKeys.contains(_dayKey(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Counts consecutive weeks with at least one completion.
  static int _countWeeklyStreak(List<DateTime> sortedHistory, DateTime today) {
    final weekStarts = sortedHistory.map(_startOfWeek).toSet().toList()..sort();
    final currentWeek = _startOfWeek(today);
    DateTime? cursor;

    if (weekStarts.any((d) => _isSameDay(d, currentWeek))) {
      cursor = currentWeek;
    } else {
      final previousWeek = currentWeek.subtract(const Duration(days: 7));
      if (weekStarts.any((d) => _isSameDay(d, previousWeek))) {
        cursor = previousWeek;
      } else {
        return 0;
      }
    }

    var streak = 0;
    while (weekStarts.any((d) => _isSameDay(d, cursor!))) {
      streak++;
      cursor = cursor!.subtract(const Duration(days: 7));
    }

    return streak;
  }

  /// Counts consecutive months with at least one completion.
  static int _countMonthlyStreak(List<DateTime> sortedHistory, DateTime today) {
    final monthKeys = sortedHistory.map((d) => _monthKey(d)).toSet().toList()
      ..sort();
    final currentKey = _monthKey(today);
    int? cursor;

    if (monthKeys.contains(currentKey)) {
      cursor = currentKey;
    } else {
      final previousKey = _previousMonthKey(currentKey);
      if (monthKeys.contains(previousKey)) {
        cursor = previousKey;
      } else {
        return 0;
      }
    }

    var streak = 0;
    while (monthKeys.contains(cursor)) {
      streak++;
      cursor = _previousMonthKey(cursor!);
    }

    return streak;
  }

  /// Checks if two dates represent the same calendar day
  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static int _dayKey(DateTime date) {
    return date.year * 10000 + date.month * 100 + date.day;
  }

  static DateTime _startOfWeek(DateTime date) {
    final normalized = _normalizeDate(date);
    final weekday = normalized.weekday; // 1=Mon ... 7=Sun
    return normalized.subtract(Duration(days: weekday - 1));
  }

  static int _monthKey(DateTime date) => date.year * 12 + date.month;

  static int _previousMonthKey(int key) {
    final month = key % 12;
    final year = (key - month) ~/ 12;
    if (month <= 1) {
      return (year - 1) * 12 + 12;
    }
    return year * 12 + (month - 1);
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
