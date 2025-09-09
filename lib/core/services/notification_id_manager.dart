/// Manages unique notification IDs to prevent conflicts
class NotificationIdManager {
  static int _habitIdCounter = 2000;
  static final Map<String, int> _habitIds = {};

  /// Get a unique notification ID for a habit
  static int getHabitNotificationId(String habitTitle) {
    if (_habitIds.containsKey(habitTitle)) {
      return _habitIds[habitTitle]!;
    }

    final id = _habitIdCounter++;
    _habitIds[habitTitle] = id;
    return id;
  }

  /// Remove a habit's notification ID when habit is deleted
  static void removeHabitNotificationId(String habitTitle) {
    _habitIds.remove(habitTitle);
  }

  /// Get notification ID for custom weekday
  static int getCustomWeekdayId(String habitTitle, int weekday) {
    final baseId = getHabitNotificationId(habitTitle);
    return baseId + weekday;
  }

  /// Clear all habit notification IDs (useful for backup/restore)
  static void clearAllHabitIds() {
    _habitIds.clear();
    _habitIdCounter = 2000;
  }
}
