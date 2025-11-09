import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:lockin/core/models/goal.dart';
import 'package:lockin/core/models/habit.dart';
import 'package:lockin/core/models/task.dart';
import 'package:lockin/core/utils/hive_background_init.dart';
import 'package:lockin/features/habits/engagement_notification.dart';
import 'package:workmanager/workmanager.dart';

const String habitEngagementTaskName = 'habitEngagementTask';

@pragma('vm:entry-point')
void habitEngagementCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await initHiveForBackground();

      // Register adapters for models used in background.
      final adapters = <TypeAdapter<dynamic>>[
        TaskAdapter(),
        HabitAdapter(),
        GoalAdapter(),
        MilestoneAdapter(),
      ];

      for (final adapter in adapters) {
        if (!Hive.isAdapterRegistered(adapter.typeId)) {
          Hive.registerAdapter(adapter);
        }
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
