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
import 'package:lockin/constants/app_constants.dart';
import 'package:lockin/core/models/task.dart';
import 'package:lockin/core/utils/task_priority_utils.dart';
import 'package:lockin/features/categories/category_manager_dialog.dart';
import 'package:lockin/features/tasks/task_provider.dart';
import 'package:lockin/features/tasks/tasks_sorted_provider.dart';
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
          IconButton.filledTonal(
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
                    FilledButton.icon(
                      icon: const Icon(Icons.lightbulb_outline),
                      label: const Text('See examples'),
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
                      padding: AppConstants.listContentPadding,
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
                      padding: AppConstants.listContentPadding,
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
          String? category = 'General';

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
                        context: context,
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
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, {
                    'title': titleController.text,
                    'description': descController.text,
                    'priority': priority,
                    'category': category ?? 'General',
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
            final category = (result['category'] as String?)?.trim();
            t.tags = [
              if (category == null || category.isEmpty) 'General' else category,
            ];
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
