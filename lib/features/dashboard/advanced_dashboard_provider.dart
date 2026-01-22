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
import 'package:lockin/features/dashboard/dashboard_provider.dart';
import 'package:lockin/features/goals/goal_provider.dart';
import 'package:lockin/features/habits/habit_provider.dart';
import 'package:lockin/features/journal/journal_provider.dart';
import 'package:lockin/features/productivity/productivity_service.dart';
import 'package:lockin/features/sessions/session_provider.dart';
import 'package:lockin/features/tasks/task_provider.dart';

final advancedDashboardStatsProvider = Provider<DashboardStats>((ref) {
  final tasks = ref.watch(tasksListProvider);
  final habits = ref.watch(habitsListProvider);
  final goals = ref.watch(goalsListProvider);
  final sessions = ref.watch(sessionsListProvider);
  final journals = ref.watch(journalsListProvider);
  final taskBox = Hive.box<Task>(HiveBoxes.tasks);
  final habitBox = Hive.box<Habit>(HiveBoxes.habits);
  final sessionBox = Hive.box<Session>(HiveBoxes.sessions);
  final service = ProductivityService(taskBox, habitBox, sessionBox);

  final milestoneProgresses = goals
      .map(
        (g) => g.milestones.isEmpty
            ? 0.0
            : g.milestones.where((m) => m.completed).length /
                  g.milestones.length,
      )
      .toList();
  final avgMilestoneProgress = milestoneProgresses.isEmpty
      ? 0.0
      : (milestoneProgresses.reduce((a, b) => a + b) /
            milestoneProgresses.length);
  final clampedProgress = avgMilestoneProgress.clamp(0.0, 1.0);

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
