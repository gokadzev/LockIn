import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:lockin/core/models/habit.dart';
import 'package:lockin/core/models/session.dart';
import 'package:lockin/core/models/task.dart';
import 'package:lockin/features/goals/goal_provider.dart';
import 'package:lockin/features/habits/habit_provider.dart';
import 'package:lockin/features/journal/journal_provider.dart';
import 'package:lockin/features/productivity/productivity_service.dart';
import 'package:lockin/features/sessions/session_provider.dart';
import 'package:lockin/features/tasks/task_provider.dart';

class DashboardStats {
  DashboardStats({
    required this.tasksDone,
    required this.habitsCompleted,
    required this.goalsProgress,
    required this.focusSessions,
    required this.journalEntries,
    required this.avgDuration,
    required this.clusters,
    required this.streak,
    required this.accuracy,
    required this.fatigue,
    required this.heatmap,
    required this.nudge,
  });
  final int tasksDone;
  final int habitsCompleted;
  final double goalsProgress;
  final int focusSessions;
  final int journalEntries;
  final double avgDuration;
  final List<int> clusters;
  final int streak;
  final double accuracy;
  final double fatigue;
  final Map<int, int> heatmap;
  final String nudge;
}

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final tasks = ref.watch(tasksListProvider);
  final habits = ref.watch(habitsListProvider);
  final goals = ref.watch(goalsListProvider);
  final sessions = ref.watch(sessionsListProvider);
  final journals = ref.watch(journalsListProvider);
  final taskBox = Hive.box<Task>('tasks');
  final habitBox = Hive.box<Habit>('habits');
  final sessionBox = Hive.box<Session>('sessions');
  final service = ProductivityService(taskBox, habitBox, sessionBox);

  // Calculate progress as the average of each goal's progress field (0.0 to 1.0)
  final progressValues = goals.map((g) => g.progress).toList();
  final avgProgress = progressValues.isEmpty
      ? 0.0
      : (progressValues.reduce((a, b) => a + b) / progressValues.length);
  final clampedProgress = avgProgress.clamp(0.0, 1.0);

  // Cache expensive stats
  final avgDuration = service.getMovingAverageDuration();
  final clusters = service.getFocusTimeClusters();
  final streak = service.getDailyStreak();
  final accuracy = service.getEstimateAccuracy();
  final fatigue = service.getFatigueScore();
  final heatmap = service.getHourlyHeatmap();
  final nudge = service.getNudge();

  return DashboardStats(
    tasksDone: tasks.where((t) => t.completed).length,
    habitsCompleted: habits.fold<int>(0, (sum, h) => sum + h.streak),
    goalsProgress: clampedProgress,
    focusSessions: sessions.length,
    journalEntries: journals.length,
    avgDuration: avgDuration,
    clusters: clusters,
    streak: streak,
    accuracy: accuracy,
    fatigue: fatigue,
    heatmap: heatmap,
    nudge: nudge,
  );
});
