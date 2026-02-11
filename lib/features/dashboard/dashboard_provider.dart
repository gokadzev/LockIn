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

enum GoalProgressMode { overall, milestones }

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

class AdvancedDashboardStats {
  AdvancedDashboardStats({
    required this.windowStart,
    required this.windowEnd,
    required this.focusMinutesByDay,
    required this.avgSessionMinutes,
    required this.sessionCompletionRate,
    required this.habitConsistencyRate,
    required this.bestDayLabel,
    required this.bestDayCount,
    required this.bestHourLabel,
    required this.bestHourCount,
  });

  final DateTime windowStart;
  final DateTime windowEnd;
  final List<int> focusMinutesByDay;
  final double avgSessionMinutes;
  final double sessionCompletionRate;
  final double habitConsistencyRate;
  final String bestDayLabel;
  final int bestDayCount;
  final String bestHourLabel;
  final int bestHourCount;
}

final dashboardStatsProviderFamily =
    Provider.family<DashboardStats, GoalProgressMode>((ref, mode) {
      final tasks = ref.watch(tasksListProvider);
      final habits = ref.watch(habitsListProvider);
      final goals = ref.watch(goalsListProvider);
      final sessions = ref.watch(sessionsListProvider);
      final journals = ref.watch(journalsListProvider);
      final taskBox = Hive.box<Task>(HiveBoxes.tasks);
      final habitBox = Hive.box<Habit>(HiveBoxes.habits);
      final sessionBox = Hive.box<Session>(HiveBoxes.sessions);
      final service = ProductivityService(taskBox, habitBox, sessionBox);

      double calculateGoalProgress() {
        if (goals.isEmpty) return 0;
        if (mode == GoalProgressMode.milestones) {
          final milestoneProgresses = goals
              .map(
                (g) => g.milestones.isEmpty
                    ? 0.0
                    : g.milestones.where((m) => m.completed).length /
                          g.milestones.length,
              )
              .toList();
          final avgMilestoneProgress = milestoneProgresses.reduce(
            (a, b) => a + b,
          );
          return (avgMilestoneProgress / milestoneProgresses.length).clamp(
            0.0,
            1.0,
          );
        }

        final progressValues = goals.map((g) => g.progress).toList();
        final avgProgress = progressValues.reduce((a, b) => a + b);
        return (avgProgress / progressValues.length).clamp(0.0, 1.0);
      }

      final clampedProgress = calculateGoalProgress();

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

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  return ref.watch(dashboardStatsProviderFamily(GoalProgressMode.overall));
});

final advancedDashboardStatsProvider = Provider<DashboardStats>((ref) {
  return ref.watch(dashboardStatsProviderFamily(GoalProgressMode.milestones));
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

final advancedDashboardInsightsProvider = Provider<AdvancedDashboardStats>((
  ref,
) {
  const windowDays = 30;
  final tasks = ref.watch(tasksListProvider);
  final habits = ref.watch(habitsListProvider);
  final sessions = ref.watch(sessionsListProvider);
  final now = DateTime.now();
  final windowEnd = DateTime(now.year, now.month, now.day);
  final windowStart = windowEnd.subtract(const Duration(days: windowDays - 1));

  bool inWindow(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return !day.isBefore(windowStart) && !day.isAfter(windowEnd);
  }

  int sessionMinutes(Session session) {
    if (session.duration > 0) return session.duration;
    if (session.endTime != null) {
      final diff = session.endTime!.difference(session.startTime).inMinutes;
      return diff <= 0 ? 0 : diff;
    }
    return 0;
  }

  final focusMinutesByDay = List<int>.filled(windowDays, 0);
  final sessionsInWindow = <Session>[];
  var totalCompletedMinutes = 0;
  var completedSessions = 0;

  for (final session in sessions) {
    if (!inWindow(session.startTime)) continue;
    sessionsInWindow.add(session);
    final minutes = sessionMinutes(session);
    if (minutes > 0) {
      totalCompletedMinutes += minutes;
      completedSessions += 1;
    }
    final dayIndex = DateTime(
      session.startTime.year,
      session.startTime.month,
      session.startTime.day,
    ).difference(windowStart).inDays;
    if (dayIndex >= 0 && dayIndex < windowDays) {
      focusMinutesByDay[dayIndex] += minutes;
    }
  }

  final avgSessionMinutes = completedSessions == 0
      ? 0.0
      : totalCompletedMinutes / completedSessions;
  final sessionCompletionRate = sessionsInWindow.isEmpty
      ? 0.0
      : completedSessions / sessionsInWindow.length;

  final activeHabits = habits.where((h) => !h.abandoned).toList();
  final totalPossible = activeHabits.length * windowDays;
  var completionsInWindow = 0;
  for (final habit in activeHabits) {
    for (final date in habit.history) {
      if (inWindow(date)) completionsInWindow += 1;
    }
  }
  final habitConsistencyRate = totalPossible == 0
      ? 0.0
      : (completionsInWindow / totalPossible).clamp(0.0, 1.0);

  final dayCounts = <int, int>{};
  for (final task in tasks) {
    final time = task.completionTime;
    if (task.completed && !task.abandoned && time != null && inWindow(time)) {
      dayCounts[time.weekday] = (dayCounts[time.weekday] ?? 0) + 1;
    }
  }
  for (final habit in activeHabits) {
    for (final date in habit.history) {
      if (inWindow(date)) {
        dayCounts[date.weekday] = (dayCounts[date.weekday] ?? 0) + 1;
      }
    }
  }
  for (final session in sessionsInWindow) {
    dayCounts[session.startTime.weekday] =
        (dayCounts[session.startTime.weekday] ?? 0) + 1;
  }

  String dayLabel(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(weekday - 1).clamp(0, 6)];
  }

  String hourLabel(int hour) {
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$hour12 $period';
  }

  var bestDayLabel = 'No data';
  var bestDayCount = 0;
  if (dayCounts.isNotEmpty) {
    final best = dayCounts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    bestDayLabel = dayLabel(best.key);
    bestDayCount = best.value;
  }

  final hourCounts = <int, int>{};
  for (final task in tasks) {
    final time = task.completionTime;
    if (task.completed && !task.abandoned && time != null && inWindow(time)) {
      hourCounts[time.hour] = (hourCounts[time.hour] ?? 0) + 1;
    }
  }
  for (final session in sessionsInWindow) {
    final hour = session.startTime.hour;
    hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
  }

  var bestHourLabel = 'No data';
  var bestHourCount = 0;
  if (hourCounts.isNotEmpty) {
    final best = hourCounts.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
    bestHourLabel = hourLabel(best.key);
    bestHourCount = best.value;
  }

  return AdvancedDashboardStats(
    windowStart: windowStart,
    windowEnd: windowEnd,
    focusMinutesByDay: focusMinutesByDay,
    avgSessionMinutes: avgSessionMinutes,
    sessionCompletionRate: sessionCompletionRate,
    habitConsistencyRate: habitConsistencyRate,
    bestDayLabel: bestDayLabel,
    bestDayCount: bestDayCount,
    bestHourLabel: bestHourLabel,
    bestHourCount: bestHourCount,
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
