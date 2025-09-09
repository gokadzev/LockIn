import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/core/models/task.dart';
import 'package:lockin/features/tasks/task_provider.dart';

class SortedTasks {
  SortedTasks({
    required this.active,
    required this.finished,
    required this.all,
  });
  final List<Task> active;
  final List<Task> finished;
  final List<Task> all;
}

final sortedTasksProvider = Provider<SortedTasks>((ref) {
  final allTasksRaw = ref.watch(tasksListProvider);
  final allTasks = allTasksRaw.toList()
    ..sort((a, b) => b.priority.compareTo(a.priority));
  final activeTasks = allTasks.where((t) => !t.completed).toList();
  final finishedTasks = allTasks.where((t) => t.completed).toList();
  return SortedTasks(
    active: activeTasks,
    finished: finishedTasks,
    all: allTasks,
  );
});
