import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:lockin/core/models/goal.dart';
import 'package:lockin/core/models/habit.dart';
import 'package:lockin/core/models/habit_category.dart';
import 'package:lockin/core/models/journal.dart';
import 'package:lockin/core/models/rule.dart';
import 'package:lockin/core/models/session.dart';
import 'package:lockin/core/models/task.dart';
import 'package:lockin/features/xp/xp_models.dart';
import 'package:path_provider/path_provider.dart';

Future<void> initializeApp() async {
  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
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
  await Hive.openBox<Task>('tasks');
  await Hive.openBox<Habit>('habits');
  await Hive.openBox<Goal>('goals');
  await Hive.openBox<Session>('sessions');
  await Hive.openBox<Journal>('journals');
  await Hive.openBox<Rule>('rules');
  await Hive.openBox<XPProfile>('xp_profile');
  await Hive.openBox<HabitCategory>('habit_categories');
  await Hive.openBox('settings');
}
