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

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:lockin/constants/app_values.dart';
import 'package:lockin/core/models/habit.dart';
import 'package:lockin/core/utils/box_crud_mixin.dart';
import 'package:lockin/core/utils/extensions/date_time_extensions.dart';
import 'package:lockin/core/utils/hive_utils.dart';
import 'package:lockin/features/habits/habit_streak_calculator.dart';

/// Provides access to the Hive box for habits.
final habitsBoxProvider = Provider<Box<Habit>?>((ref) {
  return openBoxIfAvailable<Habit>('habits');
});

/// Main provider for the list of habits, using [HabitsNotifier].
final habitsListProvider = StateNotifierProvider<HabitsNotifier, List<Habit>>((
  ref,
) {
  final box = ref.watch(habitsBoxProvider);
  return HabitsNotifier(box)..startWatchingBox();
});

/// StateNotifier for managing the list of habits, including streak logic and XP updates.
class HabitsNotifier extends StateNotifier<List<Habit>>
    with BoxCrudMixin<Habit> {
  /// Creates a HabitsNotifier backed by the given Hive [box].
  HabitsNotifier(this.box) : super(box?.values.toList() ?? []);
  @override
  final Box<Habit>? box;

  /// Checks all habits for missed days and resets streaks if needed.
  /// If [streakSaverAvailable] is true and a streak is missed by 1-3 days, calls [onStreakSaverUsed].
  void checkStreaksWithStreakSaver(
    bool streakSaverAvailable,
    void Function(bool used)? onStreakSaverUsed,
  ) {
    if (box == null) return;
    final now = DateTime.now();
    final today = now.dateOnly;
    var streakSaverUsed = false;
    for (var i = 0; i < box!.length; i++) {
      final habit = box!.getAt(i);
      if (habit == null || habit.abandoned || habit.history.isEmpty) continue;
      final lastDone = habit.history.reduce((a, b) => a.isAfter(b) ? a : b);
      final daysMissed = today.difference(lastDone.dateOnly).inDays;
      if (daysMissed > 1) {
        if (streakSaverAvailable && !streakSaverUsed && daysMissed <= 3) {
          streakSaverUsed = true;
          onStreakSaverUsed?.call(true);
        } else {
          habit.streak = 0;
          updateItem(i, habit);
        }
      }
    }
    syncStateFromBox();
  }

  /// Adds a new habit to the box and updates state.
  void addHabit(Habit habit) => addItem(habit);

  /// Updates a habit at [index], recalculates streak, and manages XP for today's completion.
  void updateHabit(
    int index,
    Habit habit,
    void Function(int xpChange)? onXPChange,
  ) {
    if (box == null) return;
    if (index < 0 || index >= box!.length) return;

    try {
      final prevHabit = box!.getAt(index);

      // Normalize history using the streak calculator
      habit.history = HabitStreakCalculator.normalizeHistory(habit.history);
      final prevHistory =
          prevHabit?.history.map((d) => d.dateOnly).toList() ?? [];

      final wasDoneToday = prevHistory.any((d) => d.isToday);
      final isDoneToday = habit.history.any((d) => d.isToday);

      // Recalculate streak using the dedicated service
      habit.streak = HabitStreakCalculator.calculateStreak(habit.history);

      updateItem(index, habit);

      // Award or remove XP if today's completion status changed.
      if (!wasDoneToday && isDoneToday) {
        onXPChange?.call(AppValues.habitCompletionXP);
      } else if (wasDoneToday && !isDoneToday) {
        onXPChange?.call(-AppValues.habitCompletionXP);
      }
    } catch (e, stackTrace) {
      debugPrint('Error updating habit at index $index: $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Deletes a habit at [index] from the box and updates state.
  void deleteHabit(int index) => deleteItem(index);

  /// Update habit by Hive [key] instead of index.
  void updateHabitByKey(
    dynamic key,
    Habit habit,
    void Function(int xpChange)? onXPChange,
  ) {
    if (box == null) return;
    try {
      final prevHabit = box!.get(key);
      if (prevHabit == null) {
        debugPrint('Habit key $key not found');
        return;
      }

      // Normalize history using the streak calculator
      habit.history = HabitStreakCalculator.normalizeHistory(habit.history);
      final prevHistory = prevHabit.history.map((d) => d.dateOnly).toList();

      final wasDoneToday = prevHistory.any((d) => d.isToday);
      final isDoneToday = habit.history.any((d) => d.isToday);

      // Recalculate streak using the dedicated service
      habit.streak = HabitStreakCalculator.calculateStreak(habit.history);

      // Persist using key-based update
      final success = updateItemByKey(key, habit);

      // Award or remove XP if today's completion status changed.
      if (success) {
        if (!wasDoneToday && isDoneToday) {
          onXPChange?.call(AppValues.habitCompletionXP);
        } else if (wasDoneToday && !isDoneToday) {
          onXPChange?.call(-AppValues.habitCompletionXP);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error updating habit by key: $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Delete habit by Hive [key] instead of index - delegates to mixin.
  void deleteHabitByKey(dynamic key) => deleteItemByKey(key);

  @override
  void dispose() {
    stopWatchingBox();
    super.dispose();
  }
}
