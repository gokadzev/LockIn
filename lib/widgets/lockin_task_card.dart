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
import 'package:lockin/core/models/task.dart';
import 'package:lockin/core/utils/category_icon.dart';
import 'package:lockin/core/utils/task_priority_utils.dart';
import 'package:lockin/features/categories/categories_provider.dart';
import 'package:lockin/features/xp/xp_provider.dart';
import 'package:lockin/widgets/action_icon_button.dart';
import 'package:lockin/widgets/category_dropdown.dart';
import 'package:lockin/widgets/icon_badge.dart';
import 'package:lockin/widgets/lockin_card.dart';
import 'package:lockin/widgets/lockin_dialog.dart';
import 'package:lockin/widgets/lockin_snackbar.dart';

class LockinTaskCard extends StatelessWidget {
  const LockinTaskCard({
    required this.task,
    required this.notifier,
    required this.allTasks,
    required this.ref,
    required this.parentContext,
    required this.onDelete,
    this.finished = false,
    super.key,
  });

  final Task task;
  final dynamic notifier;
  final List<Task> allTasks;
  final WidgetRef ref;
  final BuildContext parentContext;
  final bool finished;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final categories = ref.watch(categoriesProvider);
    return LockinCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (task.tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconBadge(
                    icon: task.tags.length > 1
                        ? Icons.view_module_outlined
                        : categoryToIcon(task.tags.first),
                  ),
                ),
              Expanded(
                child: Text(
                  task.title,
                  style: textTheme.titleMedium?.copyWith(
                    color: finished
                        ? scheme.onSurface.withValues(alpha: 0.7)
                        : scheme.onSurface,
                    height: 1.15,
                    decoration: task.completed
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: scheme.onSurface,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ActionIconButton(
                    icon: task.completed
                        ? Icons.cancel_outlined
                        : Icons.check_circle_outline,
                    color: task.completed
                        ? scheme.onSurfaceVariant
                        : scheme.onSurface,
                    tooltip: task.completed ? 'Completed' : 'Mark as done',
                    onPressed: () {
                      final isCompleted = !task.completed;
                      final updated = Task()
                        ..title = task.title
                        ..description = task.description
                        ..priority = task.priority
                        ..completed = isCompleted
                        ..tags = List<String>.from(task.tags);
                      notifier.updateTaskByKey(task.key, updated, (xpChange) {
                        ref
                            .read(xpNotifierProvider.future)
                            .then((notifier) => notifier.addXP(xpChange));
                        LockinSnackBar.showSimple(
                          context: parentContext,
                          message: xpChange > 0
                              ? 'You earned $xpChange XP!'
                              : '${-xpChange} XP removed.',
                        );
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionIconButton(
                    icon: Icons.edit_outlined,
                    color: scheme.onSurface,
                    onPressed: () async {
                      final titleController = TextEditingController(
                        text: task.title,
                      );
                      final descController = TextEditingController(
                        text: task.description ?? '',
                      );
                      var priority = task.priority;
                      var selectedCategory = task.tags.isNotEmpty
                          ? task.tags.first
                          : 'General';
                      if (!categories.contains(selectedCategory)) {
                        selectedCategory = 'General';
                      }
                      final result = await showDialog<Map<String, dynamic>>(
                        context: parentContext,
                        builder: (context) => LockinDialog(
                          title: const Text('Edit Task'),
                          content: StatefulBuilder(
                            builder: (context, setState) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: titleController,
                                  decoration: const InputDecoration(
                                    labelText: 'Title',
                                    hintText: 'Task title',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: descController,
                                  decoration: const InputDecoration(
                                    labelText: 'Description',
                                    hintText: 'Description',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                CategoryDropdown(
                                  value: selectedCategory,
                                  onChanged: (val) => setState(
                                    () => selectedCategory = val ?? 'General',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      TaskPriorityUtils.buildPriorityChips(
                                        context: context,
                                        selectedPriority: priority,
                                        onPrioritySelected: (newPriority) =>
                                            setState(
                                              () => priority = newPriority,
                                            ),
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
                                'category': selectedCategory,
                              }),
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      );
                      if (result != null &&
                          (result['title'] as String).isNotEmpty) {
                        final updated = Task()
                          ..title = result['title'] as String
                          ..description = result['description'] as String?
                          ..priority = result['priority'] as int
                          ..completed = task.completed
                          ..tags = List<String>.from(task.tags);
                        final category = (result['category'] as String?)
                            ?.trim();
                        updated.tags = [
                          if (category == null || category.isEmpty)
                            'General'
                          else
                            category,
                        ];
                        notifier.updateTaskByKey(task.key, updated, null);
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                  ActionIconButton(
                    icon: Icons.delete_outline,
                    color: scheme.onSurfaceVariant,
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
          if (task.description != null && task.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              task.description!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: finished
                    ? scheme.onSurface.withValues(alpha: 0.38)
                    : scheme.onSurfaceVariant,
                height: 1.4,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.05,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TaskPriorityUtils.buildPriorityContainer(
              context,
              task.priority,
            ),
          ),
        ],
      ),
    );
  }
}
