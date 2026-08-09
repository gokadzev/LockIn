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
import 'package:lockin/constants/hive_constants.dart';
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
  await Future.wait([
    Hive.openBox<Task>(HiveBoxes.tasks),
    Hive.openBox<Habit>(HiveBoxes.habits),
    Hive.openBox<Goal>(HiveBoxes.goals),
    Hive.openBox<Session>(HiveBoxes.sessions),
    Hive.openBox<Journal>(HiveBoxes.journals),
    Hive.openBox<Rule>(HiveBoxes.rules),
    Hive.openBox<XPProfile>(HiveBoxes.xpProfile),
    Hive.openBox<String>(HiveBoxes.habitCategories),
    Hive.openBox<dynamic>(HiveBoxes.appSettings),
    Hive.openBox<dynamic>(HiveBoxes.settings),
    Hive.openBox<int>(HiveBoxes.userActivity),
  ]);
}
