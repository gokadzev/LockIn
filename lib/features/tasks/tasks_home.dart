import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/constants/app_constants.dart';
import 'package:lockin/core/models/task.dart';
import 'package:lockin/core/utils/task_priority_utils.dart';
import 'package:lockin/features/categories/category_manager_dialog.dart';
import 'package:lockin/features/tasks/task_provider.dart';
import 'package:lockin/features/tasks/tasks_sorted_provider.dart';
import 'package:lockin/themes/app_theme.dart';
import 'package:lockin/widgets/category_dropdown.dart';
import 'package:lockin/widgets/lockin_app_bar.dart';
import 'package:lockin/widgets/lockin_dialog.dart';
import 'package:lockin/widgets/lockin_section_tabs.dart';
import 'package:lockin/widgets/lockin_snackbar.dart';
import 'package:lockin/widgets/lockin_task_card.dart';

class TasksHome extends ConsumerStatefulWidget {
  const TasksHome({super.key});

  @override
  ConsumerState<TasksHome> createState() => _TasksHomeState();
}

class _TasksHomeState extends ConsumerState<TasksHome> {
  @override
  Widget build(BuildContext context) {
    final sorted = ref.watch(sortedTasksProvider);
    final allTasks = sorted.all;
    final activeTasks = sorted.active;
    final finishedTasks = sorted.finished;
    final notifier = ref.read(tasksListProvider.notifier);

    return Scaffold(
      appBar: LockinAppBar(
        title: 'Tasks',
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            tooltip: 'Manage Categories',
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => const CategoryManagerDialog(),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: AppConstants.bodyPadding,
        child: allTasks.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No tasks yet. Tap + to add.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      icon: const Icon(Icons.lightbulb_outline),
                      label: const Text('See examples'),
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.onSurface,
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/recommendations');
                      },
                    ),
                  ],
                ),
              )
            : LockinSectionTabs(
                tabTitles: const ['Active', 'Finished'],
                tabCounts: [activeTasks.length, finishedTasks.length],
                tabViews: [
                  if (activeTasks.isEmpty)
                    Center(
                      child: Text(
                        'No active tasks.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  else
                    ListView.builder(
                      padding: AppConstants.sectionPadding,
                      itemCount: activeTasks.length,
                      itemBuilder: (context, idx) {
                        final task = activeTasks[idx];
                        return LockinTaskCard(
                          task: task,
                          notifier: notifier,
                          allTasks: allTasks,
                          ref: ref,
                          parentContext: context,
                          onDelete: () => _handleDeleteTask(task.key, task),
                        );
                      },
                    ),
                  if (finishedTasks.isEmpty)
                    Center(
                      child: Text(
                        'No finished tasks.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  else
                    ListView.builder(
                      padding: AppConstants.sectionPadding,
                      itemCount: finishedTasks.length,
                      itemBuilder: (context, idx) {
                        final task = finishedTasks[idx];
                        return LockinTaskCard(
                          task: task,
                          notifier: notifier,
                          allTasks: allTasks,
                          ref: ref,
                          parentContext: context,
                          finished: true,
                          onDelete: () => _handleDeleteTask(task.key, task),
                        );
                      },
                    ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final titleController = TextEditingController();
          final descController = TextEditingController();
          var priority = 2;
          String? category;

          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (context) => LockinDialog(
              title: const Text('Add Task'),
              content: StatefulBuilder(
                builder: (context, setState) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(color: Colors.white70),
                        hintText: 'Task title',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(color: Colors.white70),
                        hintText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Category selector (compact dropdown)
                    CategoryDropdown(
                      value: category,
                      onChanged: (val) => setState(() => category = val),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: TaskPriorityUtils.buildPriorityChips(
                        selectedPriority: priority,
                        onPrioritySelected: (newPriority) =>
                            setState(() => priority = newPriority),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, {
                    'title': titleController.text,
                    'description': descController.text,
                    'priority': priority,
                    'category': category,
                  }),
                  child: const Text('Add'),
                ),
              ],
            ),
          );
          if (result != null && (result['title'] as String).isNotEmpty) {
            final t = Task()
              ..title = result['title'] as String
              ..description = result['description'] as String?
              ..priority = result['priority'] as int;
            if (result.containsKey('category') && result['category'] != null) {
              t.tags = [result['category'] as String];
            }
            notifier.addTask(t);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _handleDeleteTask(dynamic taskKey, Task task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => LockinDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      if (!mounted) return;
      final deletedTask = task;
      final notifier = ref.read(tasksListProvider.notifier);
      final deleted = notifier.deleteTaskByKey(taskKey);
      if (!deleted) return;
      LockinSnackBar.showUndo(
        context: context,
        message: 'Task deleted',
        onUndo: () {
          notifier.addTask(deletedTask.copy());
        },
      );
    }
  }
}
