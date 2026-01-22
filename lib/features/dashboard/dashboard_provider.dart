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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:lockin/constants/hive_constants.dart';
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

class WeeklyOverviewStats {
  WeeklyOverviewStats({
    required this.tasksDone,
    required this.habitsCompleted,
    required this.focusSessions,
  });

  final int tasksDone;
  final int habitsCompleted;
  final int focusSessions;
}

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final tasks = ref.watch(tasksListProvider);
  final habits = ref.watch(habitsListProvider);
  final goals = ref.watch(goalsListProvider);
  final sessions = ref.watch(sessionsListProvider);
  final journals = ref.watch(journalsListProvider);
  final taskBox = Hive.box<Task>(HiveBoxes.tasks);
  final habitBox = Hive.box<Habit>(HiveBoxes.habits);
  final sessionBox = Hive.box<Session>(HiveBoxes.sessions);
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
    tasksDone: tasks.where((t) => t.completed && !t.abandoned).length,
    habitsCompleted: habits.fold<int>(
      0,
      (sum, h) => h.abandoned ? sum : sum + h.history.length,
    ),
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

final weeklyOverviewStatsProvider = Provider<WeeklyOverviewStats>((ref) {
  final tasks = ref.watch(tasksListProvider);
  final habits = ref.watch(habitsListProvider);
  final sessions = ref.watch(sessionsListProvider);

  final now = DateTime.now();
  final end = DateTime(now.year, now.month, now.day);
  final start = end.subtract(const Duration(days: 6));

  bool inWindow(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return !day.isBefore(start) && !day.isAfter(end);
  }

  final tasksDone = tasks
      .where(
        (t) =>
            t.completed &&
            !t.abandoned &&
            t.completionTime != null &&
            inWindow(t.completionTime!),
      )
      .length;

  final habitsCompleted = habits.fold<int>(
    0,
    (sum, h) => h.abandoned
        ? sum
        : sum + h.history.where((date) => inWindow(date)).length,
  );

  final focusSessions = sessions.where((s) => inWindow(s.startTime)).length;

  return WeeklyOverviewStats(
    tasksDone: tasksDone,
    habitsCompleted: habitsCompleted,
    focusSessions: focusSessions,
  );
});

/// Provider for monthly heatmap data
/// Returns a map of DateTime -> activity count for the current month
final monthlyHeatmapProvider = Provider<Map<DateTime, int>>((ref) {
  final tasks = ref.watch(tasksListProvider);
  final habits = ref.watch(habitsListProvider);
  final sessions = ref.watch(sessionsListProvider);

  final monthlyData = <DateTime, int>{};
  final now = DateTime.now();
  final lastDay = DateTime(now.year, now.month + 1, 0);

  // Initialize all days of the month with 0
  for (var day = 1; day <= lastDay.day; day++) {
    final date = DateTime(now.year, now.month, day);
    monthlyData[date] = 0;
  }

  // Count completed tasks for each day
  for (final task in tasks) {
    if (task.completed && !task.abandoned && task.completionTime != null) {
      final completedDate = DateTime(
        task.completionTime!.year,
        task.completionTime!.month,
        task.completionTime!.day,
      );
      if (completedDate.month == now.month && completedDate.year == now.year) {
        monthlyData[completedDate] = (monthlyData[completedDate] ?? 0) + 1;
      }
    }
  }

  // Count completed habits for each day
  for (final habit in habits) {
    if (habit.abandoned) continue;
    for (final historyDate in habit.history) {
      if (historyDate.month == now.month && historyDate.year == now.year) {
        final date = DateTime(
          historyDate.year,
          historyDate.month,
          historyDate.day,
        );
        monthlyData[date] = (monthlyData[date] ?? 0) + 1;
      }
    }
  }

  // Count sessions for each day
  for (final session in sessions) {
    final sessionDate = DateTime(
      session.startTime.year,
      session.startTime.month,
      session.startTime.day,
    );
    if (sessionDate.month == now.month && sessionDate.year == now.year) {
      monthlyData[sessionDate] = (monthlyData[sessionDate] ?? 0) + 1;
    }
  }

  return monthlyData;
});
