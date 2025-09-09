import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:lockin/core/models/habit.dart';
import 'package:lockin/core/services/engagement_notification_manager.dart';
import 'package:lockin/core/services/user_activity_tracker.dart';

Future<void> sendDailyEngagementNotifications(TimeOfDay preferredTime) async {
  try {
    // Ensure boxes are opened in background isolate
    final habitBox = Hive.isBoxOpen('habits')
        ? Hive.box<Habit>('habits')
        : await Hive.openBox<Habit>('habits');
    final taskBox = Hive.isBoxOpen('tasks')
        ? Hive.box('tasks')
        : await Hive.openBox('tasks');
    final goalBox = Hive.isBoxOpen('goals')
        ? Hive.box('goals')
        : await Hive.openBox('goals');

    final manager = EngagementNotificationManager();
    final now = DateTime.now();

    // Fetch dashboard/task/habit/goal data
    final tasksDone = taskBox.values.where((t) => t.completed).length;
    final habitsCompleted = habitBox.values
        .where(
          (h) => h.history.any(
            (d) =>
                d.year == now.year && d.month == now.month && d.day == now.day,
          ),
        )
        .length;

    var goalsProgressPercent = 0;
    if (goalBox.values.isNotEmpty) {
      final progressList = goalBox.values
          .map(
            (g) => g.milestones.isEmpty
                ? 0.0
                : g.milestones.where((m) => m.completed).length /
                      g.milestones.length,
          )
          .toList();
      final avgProgress = progressList.isEmpty
          ? 0.0
          : (progressList.reduce((a, b) => a + b) / progressList.length);
      goalsProgressPercent = (avgProgress * 100).round();
    }

    // User activity detection: if app opened in last hour, mark active
    final isUserActive = await UserActivityTracker.wasActiveWithin(
      const Duration(hours: 1),
    );

    for (final habit in habitBox.values) {
      final streak = habit.streak;
      var missedDays = 0;
      if (habit.history.isNotEmpty) {
        final lastDone = habit.history.last;
        missedDays = now.difference(lastDone).inDays;
      }
      final didHabitToday = habit.history.any(
        (d) => d.year == now.year && d.month == now.month && d.day == now.day,
      );
      final lastActiveDay = habit.history.isNotEmpty
          ? habit.history.last
          : DateTime(2000);

      await manager.maybeSendEngagementNotification(
        streak: streak,
        missedDays: missedDays,
        didHabitToday: didHabitToday,
        lastActiveDay: lastActiveDay,
        preferredTime: preferredTime,
        tasksDone: tasksDone,
        habitsCompleted: habitsCompleted,
        goalsProgressPercent: goalsProgressPercent,
        isUserActive: isUserActive,
      );
    }
  } catch (e) {
    debugPrint('Error in sendDailyEngagementNotifications: $e');
  }
}
