import 'package:flutter/material.dart';
import 'package:lockin/core/models/goal.dart';
import 'package:lockin/core/models/habit.dart';
import 'package:lockin/core/models/task.dart';
import 'package:lockin/core/notifications/notification_id_manager.dart';
import 'package:lockin/core/notifications/notification_platform.dart';
import 'package:lockin/core/notifications/notification_service.dart';
import 'package:lockin/core/notifications/notification_types.dart';
import 'package:lockin/core/notifications/timezone_manager.dart';
import 'package:lockin/core/services/user_activity_tracker.dart';

/// Manages engagement and motivational notifications
class EngagementNotificationManager {
  factory EngagementNotificationManager() => _instance;
  EngagementNotificationManager._();
  static final EngagementNotificationManager _instance =
      EngagementNotificationManager._();

  final NotificationService _notificationService = NotificationService();

  /// Send smart engagement notification based on user behavior
  Future<bool> sendEngagementNotificationBackground({
    required List<Habit> habits,
    required List<Task> tasks,
    required List<Goal> goals,
    required TimeOfDay preferredTime,
    bool isUserActive = false,
  }) async {
    try {
      // Avoid spamming active users
      if (isUserActive) return true;

      // Initialize timezone db for scheduling
      final tzManager = TimezoneManager();
      final tzOk = await tzManager.initialize();
      if (!tzOk) {
        debugPrint('Timezone initialization failed in background');
      }

      // Initialize low-level notification platform
      final platform = NotificationPlatform();
      final platformResult = await platform.initialize();
      if (!platformResult.success) {
        debugPrint(
          'Notification platform init failed in background: ${platformResult.error}',
        );
        return false;
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final analysis = _analyzeUserState(habits, tasks, goals, today);
      if (!_shouldSendNotification(analysis)) return true;

      final message = _generateEngagementMessage(analysis);
      if (message == null) return true;

      final scheduledTime = _calculateOptimalTime(preferredTime, now);

      // Generate a deterministic engagement id
      final idManager = NotificationIdManager();
      final notifId = idManager.getEngagementId(message['type']);

      final data = EngagementNotificationData(
        id: notifId,
        title: message['title']!,
        body: message['body']!,
        scheduledTime: scheduledTime,
        engagementType: message['type']!,
        metadata: {'analysis': analysis, 'generatedAt': now.toIso8601String()},
        payload: 'engagement:${message['type']}',
      );

      final result = await platform.scheduleNotification(data);
      if (result.success) {
        debugPrint(
          'Scheduled engagement notification (background): ${message['title']}',
        );
        return true;
      } else {
        debugPrint(
          'Failed to schedule engagement notification (background): ${result.error}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error in sendEngagementNotificationBackground: $e');
      return false;
    }
  }

  /// Analyze user's current productivity state
  Map<String, dynamic> _analyzeUserState(
    List<Habit> habits,
    List<Task> tasks,
    List<Goal> goals,
    DateTime today,
  ) {
    // Habits analysis
    final habitsCompletedToday = habits
        .where(
          (h) => h.history.any(
            (d) =>
                d.year == today.year &&
                d.month == today.month &&
                d.day == today.day,
          ),
        )
        .length;

    final totalActiveHabits = habits.where((h) => !h.abandoned).length;
    final avgStreak = habits.isEmpty
        ? 0
        : habits.map((h) => h.streak).reduce((a, b) => a + b) / habits.length;

    // Tasks analysis
    final tasksCompletedToday = tasks
        .where(
          (t) =>
              t.completed &&
              t.completionTime != null &&
              t.completionTime!.year == today.year &&
              t.completionTime!.month == today.month &&
              t.completionTime!.day == today.day,
        )
        .length;

    final totalPendingTasks = tasks.where((t) => !t.completed).length;

    // Goals analysis
    final activeGoals = goals.where((g) => g.milestoneProgress < 1.0).length;
    var goalProgressPercent = 0.0;
    if (goals.isNotEmpty) {
      final progressList = goals
          .map(
            (g) => g.milestones.isEmpty
                ? 0.0
                : g.milestones.where((m) => m.completed).length /
                      g.milestones.length,
          )
          .toList();
      goalProgressPercent = progressList.isEmpty
          ? 0.0
          : progressList.reduce((a, b) => a + b) / progressList.length * 100;
    }

    return {
      'habitsCompletedToday': habitsCompletedToday,
      'totalActiveHabits': totalActiveHabits,
      'avgStreak': avgStreak,
      'tasksCompletedToday': tasksCompletedToday,
      'totalPendingTasks': totalPendingTasks,
      'activeGoals': activeGoals,
      'goalProgressPercent': goalProgressPercent,
      'habitCompletionRate': totalActiveHabits == 0
          ? 0
          : (habitsCompletedToday / totalActiveHabits),
    };
  }

  /// Determine if we should send a notification based on analysis
  bool _shouldSendNotification(Map<String, dynamic> analysis) {
    final habitsCompletedToday = analysis['habitsCompletedToday'] as int;
    final totalActiveHabits = analysis['totalActiveHabits'] as int;
    final tasksCompletedToday = analysis['tasksCompletedToday'] as int;
    final habitCompletionRate = analysis['habitCompletionRate'] as double;

    // Don't spam if user is already doing well
    if (habitCompletionRate >= 0.8 && tasksCompletedToday >= 3) {
      return false;
    }

    // Send if user has habits but hasn't completed any today
    if (totalActiveHabits > 0 && habitsCompletedToday == 0) {
      return true;
    }

    // Send if user has pending tasks but hasn't completed any today
    if (analysis['totalPendingTasks'] as int > 0 && tasksCompletedToday == 0) {
      return true;
    }

    // Send if goals exist but progress is low
    if (analysis['activeGoals'] as int > 0 &&
        analysis['goalProgressPercent'] as double < 30) {
      return true;
    }

    // Send motivational message for good streaks
    if (analysis['avgStreak'] as double >= 7 && habitCompletionRate < 0.5) {
      return true;
    }

    return false;
  }

  /// Generate appropriate engagement message
  Map<String, String>? _generateEngagementMessage(
    Map<String, dynamic> analysis,
  ) {
    final habitsCompletedToday = analysis['habitsCompletedToday'] as int;
    final totalActiveHabits = analysis['totalActiveHabits'] as int;
    final tasksCompletedToday = analysis['tasksCompletedToday'] as int;
    final totalPendingTasks = analysis['totalPendingTasks'] as int;
    final avgStreak = analysis['avgStreak'] as double;
    final goalProgressPercent = analysis['goalProgressPercent'] as double;

    // Priority: Tasks first, then habits, then goals
    if (totalPendingTasks > 0 && tasksCompletedToday == 0) {
      return {
        'title': 'Ready to tackle your tasks? 🎯',
        'body':
            'You have $totalPendingTasks pending tasks. Start with the easiest one!',
        'type': 'task_motivation',
      };
    }

    if (totalActiveHabits > 0 && habitsCompletedToday == 0) {
      if (avgStreak >= 7) {
        return {
          'title': 'Don\'t break your amazing streak! 🔥',
          'body':
              'You\'ve built great momentum. Keep your ${avgStreak.round()}-day average going!',
          'type': 'streak_maintenance',
        };
      } else {
        return {
          'title': 'Small steps, big results 🌱',
          'body': 'Complete just one habit today to build momentum!',
          'type': 'habit_motivation',
        };
      }
    }

    if (goalProgressPercent < 30 && analysis['activeGoals'] as int > 0) {
      return {
        'title': 'Your goals are waiting 🎯',
        'body': 'Make progress on your goals today. Every step counts!',
        'type': 'goal_motivation',
      };
    }

    // Celebration message for good performance
    if (habitsCompletedToday >= totalActiveHabits * 0.7 &&
        tasksCompletedToday >= 2) {
      return {
        'title': 'You\'re on fire today! 🎉',
        'body': 'Amazing progress! Keep the momentum going strong.',
        'type': 'celebration',
      };
    }

    return null; // No appropriate message
  }

  /// Calculate optimal notification time
  DateTime _calculateOptimalTime(TimeOfDay preferredTime, DateTime now) {
    final preferredDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      preferredTime.hour,
      preferredTime.minute,
    );

    // If preferred time has passed today, schedule for tomorrow
    if (preferredDateTime.isBefore(now)) {
      return preferredDateTime.add(const Duration(days: 1));
    }

    // If preferred time is within the next hour, schedule immediately
    if (preferredDateTime.isBefore(now.add(const Duration(hours: 1)))) {
      return now.add(const Duration(minutes: 5));
    }

    return preferredDateTime;
  }

  /// Send immediate motivational notification
  Future<bool> sendImmediateMotivation({
    required String title,
    required String body,
    String type = 'instant_motivation',
  }) async {
    try {
      final result = await _notificationService.showInstantNotification(
        title: title,
        body: body,
        payload: 'motivation:$type',
      );

      return result.success;
    } catch (e) {
      debugPrint('Error sending immediate motivation: $e');
      return false;
    }
  }

  /// Send streak celebration notification
  Future<bool> sendStreakCelebration({
    required String habitTitle,
    required int streakDays,
  }) async {
    String title;
    String body;

    if (streakDays >= 30) {
      title = '🏆 Incredible 30+ Day Streak!';
      body = '$habitTitle: $streakDays days strong! You\'re a habit master!';
    } else if (streakDays >= 14) {
      title = '🔥 Amazing 2-Week Streak!';
      body =
          '$habitTitle: $streakDays days in a row! You\'re building incredible discipline!';
    } else if (streakDays >= 7) {
      title = '⭐ First Week Complete!';
      body = '$habitTitle: $streakDays days straight! The foundation is built!';
    } else if (streakDays >= 3) {
      title = '💪 Building Momentum!';
      body =
          '$habitTitle: $streakDays days running! You\'re on the right track!';
    } else {
      return true; // Don't celebrate very short streaks
    }

    try {
      final result = await _notificationService.showInstantNotification(
        title: title,
        body: body,
        payload: 'streak:$habitTitle:$streakDays',
      );

      return result.success;
    } catch (e) {
      debugPrint('Error sending streak celebration: $e');
      return false;
    }
  }

  /// Check if user was recently active to avoid spam
  Future<bool> wasUserRecentlyActive({
    Duration threshold = const Duration(hours: 2),
  }) async {
    try {
      return await UserActivityTracker.wasActiveWithin(threshold);
    } catch (e) {
      debugPrint('Error checking user activity: $e');
      return false; // Assume not active on error
    }
  }
}
