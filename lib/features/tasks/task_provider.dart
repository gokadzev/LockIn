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
import 'package:lockin/core/models/task.dart';
import 'package:lockin/core/utils/box_crud_mixin.dart';
import 'package:lockin/core/utils/hive_utils.dart';

/// Provides access to the Hive box for tasks.
final tasksBoxProvider = Provider<Box<Task>?>((ref) {
  return openBoxIfAvailable<Task>('tasks');
});

/// Main provider for the list of tasks, using [TasksNotifier].
final tasksListProvider = StateNotifierProvider<TasksNotifier, List<Task>>((
  ref,
) {
  final box = ref.watch(tasksBoxProvider);
  final notifier = TasksNotifier(box)..startWatchingBox();
  return notifier;
});

/// StateNotifier for managing the list of tasks, including completion time and XP updates.
class TasksNotifier extends StateNotifier<List<Task>> with BoxCrudMixin<Task> {
  /// Creates a TasksNotifier backed by the given Hive [box].
  TasksNotifier(this.box) : super(box?.values.toList() ?? []);
  @override
  final Box<Task>? box;

  /// Adds a new task to the box and updates state.
  void addTask(Task task) => addItem(task);

  /// Updates a task at [index], manages completion time, and awards/removes XP.
  void updateTask(
    int index,
    Task task,
    void Function(int xpChange)? onXPChange,
  ) {
    if (box == null) return;
    if (index < 0 || index >= box!.length) return;

    try {
      final prevTask = box!.getAt(index);

      // If marking as completed, set completion time; if un-completing, clear it.
      if (prevTask != null && !prevTask.completed && task.completed) {
        task.completionTime ??= DateTime.now();
      } else if (prevTask != null && prevTask.completed && !task.completed) {
        task.completionTime = null;
      } else if (prevTask != null && prevTask.completed && task.completed) {
        task.completionTime ??= prevTask.completionTime;
      }

      updateItem(index, task);

      // Award or remove XP if completion state changed.
      if (prevTask != null) {
        if (!prevTask.completed && task.completed) {
          onXPChange?.call(AppValues.taskCompletionXP);
        } else if (prevTask.completed && !task.completed) {
          onXPChange?.call(-AppValues.taskCompletionXP);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error updating task at index $index: $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Updates a task by its Hive key. Returns true if update succeeded.
  bool updateTaskByKey(
    dynamic key,
    Task task,
    void Function(int xpChange)? onXPChange,
  ) {
    if (box == null) return false;
    try {
      final prevTask = box!.get(key);
      if (prevTask == null) {
        debugPrint('Task key $key not found');
        return false;
      }

      // Manage completion time
      if (!prevTask.completed && task.completed) {
        task.completionTime ??= DateTime.now();
      } else if (prevTask.completed && !task.completed) {
        task.completionTime = null;
      } else if (prevTask.completed && task.completed) {
        task.completionTime ??= prevTask.completionTime;
      }

      // Persist using key-based update
      final success = updateItemByKey(key, task);

      // Manage XP only if update succeeded
      if (success) {
        if (!prevTask.completed && task.completed) {
          onXPChange?.call(AppValues.taskCompletionXP);
        } else if (prevTask.completed && !task.completed) {
          onXPChange?.call(-AppValues.taskCompletionXP);
        }
      }

      return success;
    } catch (e, stackTrace) {
      debugPrint('Error updating task by key: $e');
      debugPrint('StackTrace: $stackTrace');
      return false;
    }
  }

  /// Deletes a task at [index] from the box and updates state.
  void deleteTask(int index) => deleteItem(index);

  /// Deletes a task by its Hive key - delegates to mixin.
  bool deleteTaskByKey(dynamic key) => deleteItemByKey(key);

  @override
  void dispose() {
    stopWatchingBox();
    super.dispose();
  }
}
