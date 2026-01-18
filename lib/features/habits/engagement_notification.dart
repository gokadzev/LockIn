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
