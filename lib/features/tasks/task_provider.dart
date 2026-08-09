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
import 'package:lockin/constants/app_values.dart';
import 'package:lockin/constants/hive_constants.dart';
import 'package:lockin/core/models/task.dart';
import 'package:lockin/core/utils/box_crud_mixin.dart';
import 'package:lockin/core/utils/hive_utils.dart';

/// Provides access to the Hive box for tasks.
final tasksBoxProvider = Provider<Box<Task>?>((ref) {
  return openBoxIfAvailable<Task>(HiveBoxes.tasks);
});

/// Main provider for the list of tasks, using [TasksNotifier].
final tasksListProvider = NotifierProvider<TasksNotifier, List<Task>>(
  TasksNotifier.new,
);

/// StateNotifier for managing the list of tasks, including completion time and XP updates.
class TasksNotifier extends BoxCrudNotifier<Task> {
  @override
  String get boxName => HiveBoxes.tasks;

  /// Adds a new task to the box and updates state.
  Future<void> addTask(Task task) => addItem(task);

  /// Updates a task at [index], manages completion time, and awards/removes XP.
  Future<void> updateTask(
    int index,
    Task task,
    void Function(int xpChange)? onXPChange,
  ) async {
    await updateItemWithPrevious(
      index,
      task,
      prepare: (prevTask) {
        // If marking as completed, set completion time; if un-completing, clear it.
        if (prevTask != null && !prevTask.completed && task.completed) {
          task.completionTime ??= DateTime.now();
        } else if (prevTask != null && prevTask.completed && !task.completed) {
          task.completionTime = null;
        } else if (prevTask != null && prevTask.completed && task.completed) {
          task.completionTime ??= prevTask.completionTime;
        }
        return task;
      },
      onSuccess: (prevTask, _) {
        // Award or remove XP if completion state changed.
        if (prevTask != null) {
          if (!prevTask.completed && task.completed) {
            onXPChange?.call(AppValues.taskCompletionXP);
          } else if (prevTask.completed && !task.completed) {
            onXPChange?.call(-AppValues.taskCompletionXP);
          }
        }
      },
    );
  }

  /// Updates a task by its Hive key. Returns true if update succeeded.
  Future<bool> updateTaskByKey(
    dynamic key,
    Task task,
    void Function(int xpChange)? onXPChange,
  ) async {
    final index = indexForKey(key);
    if (index == null) return false;
    await updateTask(index, task, onXPChange);
    return true;
  }

  /// Deletes a task at [index] from the box and updates state.
  Future<void> deleteTask(int index) => deleteItem(index);

  /// Deletes a task by its Hive key - delegates to mixin.
  Future<bool> deleteTaskByKey(dynamic key) => deleteItemByKey(key);
}
