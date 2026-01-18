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

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:lockin/core/models/goal.dart';
import 'package:lockin/core/models/habit.dart';
import 'package:lockin/core/models/habit_category.dart';
import 'package:lockin/core/models/journal.dart';
import 'package:lockin/core/models/rule.dart';
import 'package:lockin/core/models/session.dart';
import 'package:lockin/core/models/task.dart';
import 'package:lockin/core/utils/hive_background_init.dart';
import 'package:lockin/features/xp/xp_models.dart';

Future<void> initializeApp() async {
  await initHiveForBackground();
  Hive
    ..registerAdapter(TaskAdapter())
    ..registerAdapter(HabitAdapter())
    ..registerAdapter(GoalAdapter())
    ..registerAdapter(MilestoneAdapter())
    ..registerAdapter(SessionAdapter())
    ..registerAdapter(JournalAdapter())
    ..registerAdapter(RuleAdapter())
    ..registerAdapter(XPProfileAdapter())
    ..registerAdapter(RewardAdapter())
    ..registerAdapter(RewardTypeAdapter())
    ..registerAdapter(HabitCategoryAdapter());
  await _migrateHabitCategoriesBox();
  await Hive.openBox<Task>('tasks');
  await Hive.openBox<Habit>('habits');
  await Hive.openBox<Goal>('goals');
  await Hive.openBox<Session>('sessions');
  await Hive.openBox<Journal>('journals');
  await Hive.openBox<Rule>('rules');
  await Hive.openBox<XPProfile>('xp_profile');
  await Hive.openBox<String>('habit_categories');
  await Hive.openBox<dynamic>('app_settings');
  await Hive.openBox('settings');
}

// TODO: remove migration function after a few releases (afa7169b9dbed6d8322e46219b54e4f6b6ea11f9)

Future<void> _migrateHabitCategoriesBox() async {
  final box = await Hive.openBox('habit_categories');
  var changed = false;

  for (final key in box.keys.toList()) {
    final value = box.get(key);
    if (value is HabitCategory) {
      final name = value.name.trim();
      if (name.isEmpty) {
        await box.delete(key);
      } else {
        await box.put(key, name);
      }
      changed = true;
    } else if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        await box.delete(key);
        changed = true;
      } else if (trimmed != value) {
        await box.put(key, trimmed);
        changed = true;
      }
    } else if (value == null) {
      await box.delete(key);
      changed = true;
    }
  }

  if (changed) {
    await box.compact();
  }
  await box.close();
}
