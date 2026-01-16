import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:lockin/core/models/goal.dart';
import 'package:lockin/core/models/habit.dart';
import 'package:lockin/core/models/task.dart';
import 'package:lockin/core/notifications/engagement_notification_manager.dart';
import 'package:lockin/core/services/user_activity_tracker.dart';
import 'package:lockin/core/utils/hive_utils.dart';

Future<void> sendDailyEngagementNotifications(TimeOfDay preferredTime) async {
  try {
    // Ensure boxes are opened in background isolate
    final habitBox =
        openBoxIfAvailable<Habit>('habits') ??
        await Hive.openBox<Habit>('habits');
    final taskBox = openBoxIfAvailable('tasks') ?? await Hive.openBox('tasks');
    final goalBox = openBoxIfAvailable('goals') ?? await Hive.openBox('goals');

    final manager = EngagementNotificationManager();

    // User activity detection: if app opened in last hour, mark active
    final isUserActive = await UserActivityTracker.wasActiveWithin(
      const Duration(hours: 1),
    );

    // Collect all data
    final habits = habitBox.values.cast<Habit>().toList();
    final tasks = taskBox.values.cast<Task>().toList();
    final goals = goalBox.values.cast<Goal>().toList();

    // Send engagement notification
    await manager.sendEngagementNotificationBackground(
      habits: habits,
      tasks: tasks,
      goals: goals,
      preferredTime: preferredTime,
      isUserActive: isUserActive,
    );
  } catch (e) {
    debugPrint('Error in sendDailyEngagementNotifications: $e');
  }
}
