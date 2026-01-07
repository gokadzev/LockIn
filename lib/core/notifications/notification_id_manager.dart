import 'dart:math';

/// Manages unique notification IDs across the app
class NotificationIdManager {
  // Singleton
  factory NotificationIdManager() => _instance;
  NotificationIdManager._();
  static final NotificationIdManager _instance = NotificationIdManager._();

  // ID ranges for different notification types
  static const int _habitIdStart = 1000;
  static const int _pomodoroIdStart = 2000;
  static const int _engagementIdStart = 3000;
  static const int _achievementIdStart = 4000;
  static const int _streakIdStart = 5000;

  // Maximum IDs per category (allows for 1000 notifications per type)
  static const int _categoryRange = 1000;

  final Map<String, int> _habitIds = {};
  final Set<int> _usedIds = {};
  int _lastDynamicId = 6000; // For one-time/dynamic notifications
  final Random _random = Random();

  /// Produce a deterministic id for a weekly instance.
  ///
  /// We reserve the lower 3 bits to encode the weekday (1..7). The base id
  /// is shifted left by 3 bits so collisions are avoided for reasonable base
  /// ids. This scheme is reversible via [decodeWeeklyInstanceId].
  static int weeklyInstanceId(int baseId, int weekday) {
    if (weekday < 1 || weekday > 7) {
      throw ArgumentError.value(weekday, 'weekday', 'Must be in 1..7');
    }
    return (baseId << 3) | (weekday & 0x7);
  }

  /// Decode an id produced by [weeklyInstanceId]. Returns a map with
  /// `baseId` and `weekday` keys.
  static Map<String, int> decodeWeeklyInstanceId(int instanceId) {
    final weekday = instanceId & 0x7;
    final baseId = instanceId >> 3;
    return {'baseId': baseId, 'weekday': weekday};
  }

  /// Produce a list of weekly instance ids for the given base id and
  /// weekdays.
  static List<int> weeklyInstanceIds(int baseId, Iterable<int> weekdays) {
    return weekdays.map((d) => weeklyInstanceId(baseId, d)).toList();
  }

  /// Get or create a unique ID for a habit
  int getHabitId(String habitId) {
    if (_habitIds.containsKey(habitId)) {
      return _habitIds[habitId]!;
    }

    // Prefer a deterministic mapping so IDs remain consistent across restarts.
    final deterministic =
        _habitIdStart + (habitId.hashCode.abs() % _categoryRange);

    // If deterministic id is free or already associated with this habit, use it.
    if (!_usedIds.contains(deterministic)) {
      _habitIds[habitId] = deterministic;
      _usedIds.add(deterministic);
      return deterministic;
    }

    // If collision occurs (rare), fall back to allocation in range.
    final id = _generateIdInRange(
      _habitIdStart,
      _habitIdStart + _categoryRange - 1,
    );
    _habitIds[habitId] = id;
    _usedIds.add(id);
    return id;
  }

  /// Get ID for a specific weekday of a habit (for custom schedules)
  int getHabitWeekdayId(String habitId, int weekday) {
    final baseId = getHabitId(habitId);
    // Use deterministic weekly instance id mapping
    return NotificationIdManager.weeklyInstanceId(baseId, weekday);
  }

  /// Get a unique ID for Pomodoro notifications
  int getPomodoroId([String? sessionId]) {
    if (sessionId != null) {
      // Use a consistent ID for the same session
      return _pomodoroIdStart + (sessionId.hashCode.abs() % _categoryRange);
    }
    return _pomodoroIdStart;
  }

  /// Get a unique ID for engagement notifications
  int getEngagementId([String? type]) {
    if (type != null) {
      return _engagementIdStart + (type.hashCode.abs() % _categoryRange);
    }
    return _generateIdInRange(
      _engagementIdStart,
      _engagementIdStart + _categoryRange - 1,
    );
  }

  /// Get a unique ID for achievement notifications
  int getAchievementId(String achievementId) {
    return _achievementIdStart +
        (achievementId.hashCode.abs() % _categoryRange);
  }

  /// Get a unique ID for streak notifications
  int getStreakId(String streakType) {
    return _streakIdStart + (streakType.hashCode.abs() % _categoryRange);
  }

  /// Generate a unique dynamic ID for one-time notifications
  int generateDynamicId() {
    while (_usedIds.contains(_lastDynamicId)) {
      _lastDynamicId++;
    }
    _usedIds.add(_lastDynamicId);
    return _lastDynamicId++;
  }

  /// Remove a habit ID when habit is deleted
  void removeHabitId(String habitId) {
    final id = _habitIds.remove(habitId);
    if (id != null) {
      _usedIds.remove(id);
    }
  }

  /// Clear all habit IDs (useful for data reset)
  void clearHabitIds() {
    for (final id in _habitIds.values) {
      _usedIds.remove(id);
    }
    _habitIds.clear();
  }

  /// Get all habit IDs for bulk operations
  List<int> getAllHabitIds() {
    return _habitIds.values.toList();
  }

  /// Check if an ID is in use
  bool isIdInUse(int id) {
    return _usedIds.contains(id);
  }

  int _generateIdInRange(int start, int end) {
    int id;
    var attempts = 0;
    const maxAttempts = 100;

    do {
      id = start + _random.nextInt(end - start + 1);
      attempts++;
    } while (_usedIds.contains(id) && attempts < maxAttempts);

    if (attempts >= maxAttempts) {
      // Fallback: find first available ID in range
      for (var i = start; i <= end; i++) {
        if (!_usedIds.contains(i)) {
          id = i;
          break;
        }
      }
    }

    _usedIds.add(id);

    return id;
  }

  /// Debug method to get current state
  Map<String, dynamic> getDebugInfo() {
    return {
      'habitIds': Map.from(_habitIds),
      'usedIds': _usedIds.toList()..sort(),
      'lastDynamicId': _lastDynamicId,
      'totalUsedIds': _usedIds.length,
    };
  }
}
