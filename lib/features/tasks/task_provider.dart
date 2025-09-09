import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:lockin/constants/app_values.dart';
import 'package:lockin/core/models/task.dart';
import 'package:lockin/core/utils/box_crud_mixin.dart';

/// Provides access to the Hive box for tasks.
final tasksBoxProvider = Provider<Box<Task>?>((ref) {
  try {
    return Hive.isBoxOpen('tasks') ? Hive.box<Task>('tasks') : null;
  } catch (e) {
    return null;
  }
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
    final prevTask = box!.getAt(index);
    // If marking as completed, set completion time; if un-completing, clear it.
    if (prevTask != null && !prevTask.completed && task.completed) {
      task.completionTime = DateTime.now();
    } else if (prevTask != null && prevTask.completed && !task.completed) {
      task.completionTime = null;
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
  }

  /// Updates a task by its Hive key. Returns true if update succeeded.
  bool updateTaskByKey(
    dynamic key,
    Task task,
    void Function(int xpChange)? onXPChange,
  ) {
    if (box == null) return false;
    try {
      final idx = box!.keys.toList().indexOf(key);
      if (idx == -1) return false;
      final prevTask = box!.getAt(idx);
      if (prevTask != null && !prevTask.completed && task.completed) {
        task.completionTime = DateTime.now();
      } else if (prevTask != null && prevTask.completed && !task.completed) {
        task.completionTime = null;
      }
      updateItem(idx, task);
      if (prevTask != null) {
        if (!prevTask.completed && task.completed) {
          onXPChange?.call(AppValues.taskCompletionXP);
        } else if (prevTask.completed && !task.completed) {
          onXPChange?.call(-AppValues.taskCompletionXP);
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Deletes a task at [index] from the box and updates state.
  void deleteTask(int index) => deleteItem(index);

  /// Deletes a task by its Hive key. Returns true if deletion succeeded.
  bool deleteTaskByKey(dynamic key) {
    if (box == null) return false;
    try {
      final idx = box!.keys.toList().indexOf(key);
      if (idx == -1) return false;
      deleteItem(idx);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    stopWatchingBox();
    super.dispose();
  }
}
