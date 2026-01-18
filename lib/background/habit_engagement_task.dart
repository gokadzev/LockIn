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
