import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:lockin/constants/app_values.dart';
import 'package:lockin/core/models/goal.dart';
import 'package:lockin/core/utils/box_crud_mixin.dart';

/// Provides access to the Hive box for goals.
final goalsBoxProvider = Provider<Box<Goal>?>((ref) {
  try {
    return Hive.isBoxOpen('goals') ? Hive.box<Goal>('goals') : null;
  } catch (e, stackTrace) {
    debugPrint('Error accessing goals box: $e');
    debugPrint('StackTrace: $stackTrace');
    return null;
  }
});

/// Main provider for the list of goals, using [GoalsNotifier].
final goalsListProvider = StateNotifierProvider<GoalsNotifier, List<Goal>>((
  ref,
) {
  final box = ref.watch(goalsBoxProvider);
  return GoalsNotifier(box)..startWatchingBox();
});

/// StateNotifier for managing the list of goals, including milestone progress and XP updates.
class GoalsNotifier extends StateNotifier<List<Goal>> with BoxCrudMixin<Goal> {
  /// Creates a GoalsNotifier backed by the given Hive [box].
  GoalsNotifier(this.box) : super(box?.values.toList() ?? []);
  @override
  final Box<Goal>? box;

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
      final keys = box!.keys.toList();
      final index = keys.indexOf(key);
      if (index == -1) {
        debugPrint('Goal key $key not found');
        return;
      }
      updateGoal(index, goal, onXPChange);
    } catch (e, stackTrace) {
      debugPrint('Error updating goal by key: $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Delete goal by Hive [key] instead of index - delegates to mixin.
  void deleteGoalByKey(dynamic key) => deleteItemByKey(key);

  @override
  void dispose() {
    stopWatchingBox();
    super.dispose();
  }
}
