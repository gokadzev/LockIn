import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:lockin/core/models/goal.dart';
import 'package:lockin/core/models/habit.dart';
import 'package:lockin/core/models/task.dart';
import 'package:lockin/features/habits/engagement_notification.dart';
import 'package:workmanager/workmanager.dart';

const String habitEngagementTaskName = 'habitEngagementTask';

@pragma('vm:entry-point')
void habitEngagementCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Initialize Hive for background isolate with path
      await Hive.initFlutter();

      // Register adapters for models used in background
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(HabitAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(TaskAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(GoalAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(MilestoneAdapter());
      }

      // Load preferred time from Hive settings
      final box = Hive.isBoxOpen('settings')
          ? Hive.box('settings')
          : await Hive.openBox('settings');
      var preferredTime = const TimeOfDay(hour: 9, minute: 0);
      if (box.containsKey('engagementTime')) {
        final timeMap = box.get('engagementTime') as Map?;
        if (timeMap != null &&
            timeMap['hour'] != null &&
            timeMap['minute'] != null) {
          preferredTime = TimeOfDay(
            hour: timeMap['hour'],
            minute: timeMap['minute'],
          );
        }
      }

      await sendDailyEngagementNotifications(preferredTime);
      return true;
    } catch (e) {
      debugPrint('Background task error: $e');
      return false;
    }
  });
}
