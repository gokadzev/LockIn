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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:lockin/constants/app_values.dart';
import 'package:lockin/constants/hive_constants.dart';
import 'package:lockin/core/models/goal.dart';
import 'package:lockin/core/utils/box_crud_mixin.dart';
import 'package:lockin/core/utils/hive_utils.dart';

/// Provides access to the Hive box for goals.
final goalsBoxProvider = Provider<Box<Goal>?>((ref) {
  return openBoxIfAvailable<Goal>(HiveBoxes.goals);
});

/// Main provider for the list of goals, using [GoalsNotifier].
final goalsListProvider = NotifierProvider<GoalsNotifier, List<Goal>>(
  GoalsNotifier.new,
);

/// StateNotifier for managing the list of goals, including milestone progress and XP updates.
class GoalsNotifier extends Notifier<List<Goal>> with BoxCrudMixin<Goal> {
  Box<Goal>? _box;

  @override
  Box<Goal>? get box => _box;

  @override
  List<Goal> build() {
    stopWatchingBox();
    _box = ref.watch(goalsBoxProvider);
    startWatchingBox();
    ref.onDispose(stopWatchingBox);
    return _box?.values.toList() ?? [];
  }

  /// Adds a new goal to the box and updates state. Progress is set from milestones.
  Future<void> addGoal(Goal goal) async {
    if (box == null) return;
    goal.progress = goal.milestoneProgress;
    try {
      await box!.add(goal);
      syncStateFromBox();
    } catch (e) {
      debugPrint('Error adding goal to Hive box in addGoal(): $e');
    }
  }

  /// Updates a goal at [index], recalculates progress, and manages XP for milestone completion.
  /// If the number of milestones changes, progress is recalculated.
  void updateGoal(
    int index,
    Goal goal,
    void Function(int xpChange)? onXPChange,
  ) {
    if (box == null) return;
    if (index < 0 || index >= box!.length) return;

    try {
      final prevGoal = box!.getAt(index);

      // Calculate XP delta BEFORE mutating storage/state
      final prevCompleted =
          prevGoal?.milestones.where((m) => m.completed).length ?? 0;
      final newCompleted = goal.milestones.where((m) => m.completed).length;
      final xpDelta =
          (newCompleted - prevCompleted) * AppValues.milestoneCompletionXP;

      // Recalculate progress only if there are milestones; for milestone-less
      // goals we preserve manually set progress (e.g., marking finished sets 1.0)
      if (goal.milestones.isNotEmpty) {
        goal.progress = goal.milestoneProgress;
      }

      updateItem(index, goal);

      // Award or remove XP if milestone completion status changed.
      if (xpDelta != 0) {
        onXPChange?.call(xpDelta);
      }
    } catch (e, stackTrace) {
      debugPrint('Error updating goal at index $index: $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Deletes a goal at [index] from the box and updates state.
  void deleteGoal(int index) => deleteItem(index);

  /// Update goal by Hive [key] instead of index.
  void updateGoalByKey(
    dynamic key,
    Goal goal,
    void Function(int xpChange)? onXPChange,
  ) {
    if (box == null) return;
    try {
      final prevGoal = box!.get(key);
      if (prevGoal == null) {
        debugPrint('Goal key $key not found');
        return;
      }

      // Calculate XP delta BEFORE mutating storage/state
      final prevCompleted = prevGoal.milestones
          .where((m) => m.completed)
          .length;
      final newCompleted = goal.milestones.where((m) => m.completed).length;
      final xpDelta =
          (newCompleted - prevCompleted) * AppValues.milestoneCompletionXP;

      // Recalculate progress only if there are milestones
      if (goal.milestones.isNotEmpty) {
        goal.progress = goal.milestoneProgress;
      }

      // Persist using key-based update
      final success = updateItemByKey(key, goal);

      if (success && xpDelta != 0) {
        onXPChange?.call(xpDelta);
      }
    } catch (e, stackTrace) {
      debugPrint('Error updating goal by key: $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Delete goal by Hive [key] instead of index - delegates to mixin.
  void deleteGoalByKey(dynamic key) => deleteItemByKey(key);
}
