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
import 'package:lockin/core/models/goal.dart';
import 'package:lockin/features/categories/categories_provider.dart';
import 'package:lockin/features/categories/category_manager_dialog.dart';
import 'package:lockin/features/goals/goal_provider.dart';
import 'package:lockin/features/goals/goals_sorted_provider.dart';
import 'package:lockin/features/xp/xp_provider.dart';
import 'package:lockin/widgets/category_dropdown.dart';
import 'package:lockin/widgets/lockin_app_bar.dart';
import 'package:lockin/widgets/lockin_dialog.dart';
import 'package:lockin/widgets/lockin_goal_card.dart';
import 'package:lockin/widgets/lockin_section_tabs.dart';
import 'package:lockin/widgets/lockin_snackbar.dart';

class GoalsHome extends ConsumerStatefulWidget {
  const GoalsHome({super.key});

  @override
  ConsumerState<GoalsHome> createState() => _GoalsHomeState();
}

class _GoalsHomeState extends ConsumerState<GoalsHome> {
  @override
  Widget build(BuildContext context) {
    final sorted = ref.watch(sortedGoalsProvider);
    final goals = sorted.all;
    final activeGoals = sorted.active;
    final finishedGoals = sorted.finished;
    final categories = ref.watch(categoriesProvider);
    final notifier = ref.read(goalsListProvider.notifier);
    return Scaffold(
      appBar: LockinAppBar(
        title: 'Goals',
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
        child: goals.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No goals yet. Tap + to add.',
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
                tabCounts: [activeGoals.length, finishedGoals.length],
                tabViews: [
                  if (activeGoals.isEmpty)
                    Center(
                      child: Text(
                        'No active goals.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  else
                    ListView.builder(
                      padding: AppConstants.listContentPadding,
                      itemCount: activeGoals.length,
                      itemBuilder: (context, idx) {
                        final goal = activeGoals[idx];
                        final goalKey = goal.key;
                        return GoalCard(
                          goal: goal,
                          index: idx,
                          isFinished: false,
                          onDelete: (i) => _handleDeleteGoal(goalKey, goal),
                          onEdit: (i) async {
                            final goalToEdit = goals[i];
                            final titleController = TextEditingController(
                              text: goalToEdit.title,
                            );
                            final smartController = TextEditingController(
                              text: goalToEdit.smart ?? '',
                            );
                            final milestones = <TextEditingController>[];
                            final milestonesFocusNodes = <FocusNode>[];
                            for (final m in goalToEdit.milestones) {
                              milestones.add(
                                TextEditingController(text: m.title),
                              );
                              milestonesFocusNodes.add(FocusNode());
                            }
                            if (milestones.isEmpty) {
                              milestones.add(TextEditingController());
                              milestonesFocusNodes.add(FocusNode());
                            }
                            var selectedDeadline = goalToEdit.deadline;
                            var selectedCategory =
                                goalToEdit.category ?? 'General';
                            if (!categories.contains(selectedCategory)) {
                              selectedCategory = 'General';
                            }
                            final result = await showDialog<Map<String, dynamic>>(
                              context: context,
                              builder: (context) => LockinDialog(
                                title: const Text('Edit Goal'),
                                content: StatefulBuilder(
                                  builder: (context, setState) => SingleChildScrollView(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: titleController,
                                          decoration: const InputDecoration(
                                            labelText: 'Title',
                                            labelStyle: TextStyle(
                                              color: Colors.white70,
                                            ),
                                            hintText: 'Goal title',
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        TextField(
                                          controller: smartController,
                                          decoration: const InputDecoration(
                                            labelText: 'SMART',
                                            labelStyle: TextStyle(
                                              color: Colors.white70,
                                            ),
                                            hintText: 'SMART details',
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        // Category selector
                                        CategoryDropdown(
                                          value: selectedCategory,
                                          onChanged: (v) => setState(
                                            () => selectedCategory =
                                                v ?? 'General',
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            const Text(
                                              'Deadline',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Spacer(),
                                            TextButton(
                                              onPressed: () async {
                                                final picked =
                                                    await showDatePicker(
                                                      context: context,
                                                      initialDate:
                                                          selectedDeadline ??
                                                          DateTime.now(),
                                                      firstDate: DateTime.now(),
                                                      lastDate: DateTime(2100),
                                                    );
                                                if (picked != null) {
                                                  setState(
                                                    () => selectedDeadline =
                                                        picked,
                                                  );
                                                }
                                              },
                                              child: Text(
                                                selectedDeadline == null
                                                    ? 'Pick date'
                                                    : '${selectedDeadline!.year}-${selectedDeadline!.month.toString().padLeft(2, '0')}-${selectedDeadline!.day.toString().padLeft(2, '0')}',
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            const Text(
                                              'Milestones',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Spacer(),
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              onPressed: () {
                                                setState(() {
                                                  milestones.add(
                                                    TextEditingController(),
                                                  );
                                                  milestonesFocusNodes.add(
                                                    FocusNode(),
                                                  );
                                                });
                                                Future.delayed(
                                                  const Duration(
                                                    milliseconds: 100,
                                                  ),
                                                  () {
                                                    if (!mounted ||
                                                        milestonesFocusNodes
                                                            .isEmpty) {
                                                      return;
                                                    }
                                                    milestonesFocusNodes.last
                                                        .requestFocus();
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        ReorderableListView(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          onReorder: (oldIndex, newIndex) {
                                            setState(() {
                                              if (newIndex > oldIndex) {
                                                newIndex--;
                                              }
                                              final ctrl = milestones.removeAt(
                                                oldIndex,
                                              );
                                              final node = milestonesFocusNodes
                                                  .removeAt(oldIndex);
                                              milestones.insert(newIndex, ctrl);
                                              milestonesFocusNodes.insert(
                                                newIndex,
                                                node,
                                              );
                                            });
                                          },
                                          children: [
                                            for (
                                              int j = 0;
                                              j < milestones.length;
                                              j++
                                            )
                                              Padding(
                                                key: ValueKey(
                                                  'milestone_edit_$j',
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 6,
                                                    ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextField(
                                                        controller:
                                                            milestones[j],
                                                        focusNode:
                                                            milestonesFocusNodes[j],
                                                        decoration: InputDecoration(
                                                          hintText:
                                                              'Milestone ${j + 1}',
                                                        ),
                                                        onSubmitted: (value) {
                                                          if (value
                                                              .trim()
                                                              .isNotEmpty) {
                                                            setState(() {
                                                              milestones.add(
                                                                TextEditingController(),
                                                              );
                                                              milestonesFocusNodes
                                                                  .add(
                                                                    FocusNode(),
                                                                  );
                                                            });
                                                            Future.delayed(
                                                              const Duration(
                                                                milliseconds:
                                                                    100,
                                                              ),
                                                              () {
                                                                if (!mounted ||
                                                                    milestonesFocusNodes
                                                                        .isEmpty) {
                                                                  return;
                                                                }
                                                                milestonesFocusNodes
                                                                    .last
                                                                    .requestFocus();
                                                              },
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.remove_circle,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          milestones[j]
                                                              .dispose();
                                                          milestonesFocusNodes[j]
                                                              .dispose();
                                                          milestones.removeAt(
                                                            j,
                                                          );
                                                          milestonesFocusNodes
                                                              .removeAt(j);
                                                        });
                                                      },
                                                    ),
                                                    const SizedBox(width: 4),
                                                    ReorderableDragStartListener(
                                                      index: j,
                                                      child: const Icon(
                                                        Icons.drag_handle,
                                                        size: 18,
                                                        color: Colors.white38,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      final milestoneObjs = milestones
                                          .where(
                                            (c) => c.text.trim().isNotEmpty,
                                          )
                                          .map((c) => Milestone(c.text.trim()))
                                          .toList();
                                      Navigator.pop(context, {
                                        'title': titleController.text,
                                        'smart': smartController.text,
                                        'milestones': milestoneObjs,
                                        'deadline': selectedDeadline,
                                        'category': selectedCategory,
                                      });
                                    },
                                    child: const Text('Save'),
                                  ),
                                ],
                              ),
                            );
                            if (result != null &&
                                (result['title'] as String).isNotEmpty) {
                              final updated = goalToEdit.copy()
                                ..title = result['title'] as String
                                ..smart = result['smart'] as String?
                                ..milestones =
                                    (result['milestones'] as List<Milestone>)
                                ..deadline = result['deadline'] as DateTime?;
                              final category = (result['category'] as String?)
                                  ?.trim();
                              updated.category =
                                  (category == null || category.isEmpty)
                                  ? 'General'
                                  : category;
                              final key = goalToEdit.key;
                              notifier.updateGoalByKey(key, updated, null);
                            }
                          },
                          onMilestoneRemove:
                              goal.milestones
                                  .where((m) => m.completed)
                                  .isNotEmpty
                              ? (i) {
                                  final updated = Goal()
                                    ..title = goal.title
                                    ..smart = goal.smart
                                    ..milestones = List.from(goal.milestones)
                                    ..progress = goal.progress;
                                  final firstDone = updated.milestones
                                      .indexWhere((m) => m.completed);
                                  if (firstDone != -1) {
                                    updated.milestones[firstDone].completed =
                                        false;
                                  }
                                  final key = goal.key;
                                  notifier.updateGoalByKey(key, updated, (
                                    xpChange,
                                  ) {
                                    ref
                                        .read(xpNotifierProvider.future)
                                        .then(
                                          (notifier) =>
                                              notifier.addXP(xpChange),
                                        );
                                    LockinSnackBar.showSimple(
                                      context: context,
                                      message: xpChange > 0
                                          ? 'You earned $xpChange XP!'
                                          : '${-xpChange} XP removed.',
                                    );
                                  });
                                }
                              : null,
                          onMilestoneAdd:
                              goal.milestones
                                  .where((m) => !m.completed)
                                  .isNotEmpty
                              ? (i) {
                                  final updated = Goal()
                                    ..title = goal.title
                                    ..smart = goal.smart
                                    ..milestones = List.from(goal.milestones)
                                    ..progress = goal.progress;
                                  final firstUndone = updated.milestones
                                      .indexWhere((m) => !m.completed);
                                  if (firstUndone != -1) {
                                    updated.milestones[firstUndone].completed =
                                        true;
                                  }
                                  final justFinished = updated.milestones.every(
                                    (m) => m.completed,
                                  );
                                  final key = goal.key;
                                  notifier.updateGoalByKey(key, updated, (
                                    xpChange,
                                  ) {
                                    ref
                                        .read(xpNotifierProvider.future)
                                        .then(
                                          (notifier) =>
                                              notifier.addXP(xpChange),
                                        );
                                    LockinSnackBar.showSimple(
                                      context: context,
                                      message: xpChange > 0
                                          ? 'You earned $xpChange XP!'
                                          : '${-xpChange} XP removed.',
                                    );
                                  });
                                  if (justFinished) {
                                    LockinSnackBar.showSimple(
                                      context: context,
                                      message: 'Goal marked as finished!',
                                    );
                                  }
                                }
                              : null,
                          onFinish: goal.milestones.isEmpty
                              ? (i) {
                                  final updated = Goal()
                                    ..title = goal.title
                                    ..smart = goal.smart
                                    ..milestones = []
                                    ..progress = 1.0
                                    ..deadline = goal.deadline;
                                  final key = goal.key;
                                  notifier.updateGoalByKey(key, updated, null);
                                  LockinSnackBar.showSimple(
                                    context: context,
                                    message: 'Goal marked as finished!',
                                  );
                                }
                              : null,
                        );
                      },
                    ),
                  if (finishedGoals.isEmpty)
                    Center(
                      child: Text(
                        'No finished goals.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  else
                    ListView.builder(
                      padding: AppConstants.listContentPadding,
                      itemCount: finishedGoals.length,
                      itemBuilder: (context, idx) {
                        final goal = finishedGoals[idx];
                        final goalKey = goal.key;
                        return GoalCard(
                          goal: goal,
                          index: idx,
                          isFinished: true,
                          onDelete: (i) => _handleDeleteGoal(goalKey, goal),
                        );
                      },
                    ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final titleController = TextEditingController();
          final smartController = TextEditingController();
          final milestones = <TextEditingController>[];
          final milestonesFocusNodes = <FocusNode>[];
          void addMilestone() {
            milestones.add(TextEditingController());
            milestonesFocusNodes.add(FocusNode());
          }

          addMilestone();
          DateTime? selectedDeadline;
          String? selectedCategory = 'General';
          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (context) => LockinDialog(
              title: const Text('Add Goal'),
              content: StatefulBuilder(
                builder: (context, setState) => SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          labelStyle: TextStyle(color: Colors.white70),
                          hintText: 'Goal title',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: smartController,
                        decoration: const InputDecoration(
                          labelText: 'SMART',
                          labelStyle: TextStyle(color: Colors.white70),
                          hintText: 'SMART details',
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Category selector for new goal
                      CategoryDropdown(
                        value: selectedCategory,
                        onChanged: (v) => setState(() => selectedCategory = v),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text(
                            'Deadline',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDeadline ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() => selectedDeadline = picked);
                              }
                            },
                            child: Text(
                              selectedDeadline == null
                                  ? 'Pick date'
                                  : '${selectedDeadline!.year}-${selectedDeadline!.month.toString().padLeft(2, '0')}-${selectedDeadline!.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text(
                            'Milestones',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                milestones.add(TextEditingController());
                                milestonesFocusNodes.add(FocusNode());
                              });
                              Future.delayed(
                                const Duration(milliseconds: 100),
                                () {
                                  if (!mounted ||
                                      milestonesFocusNodes.isEmpty) {
                                    return;
                                  }
                                  milestonesFocusNodes.last.requestFocus();
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      ReorderableListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final ctrl = milestones.removeAt(oldIndex);
                            final node = milestonesFocusNodes.removeAt(
                              oldIndex,
                            );
                            milestones.insert(newIndex, ctrl);
                            milestonesFocusNodes.insert(newIndex, node);
                          });
                        },
                        children: [
                          for (int i = 0; i < milestones.length; i++)
                            Padding(
                              key: ValueKey('milestone_$i'),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: milestones[i],
                                      focusNode: milestonesFocusNodes[i],
                                      decoration: InputDecoration(
                                        hintText: 'Milestone ${i + 1}',
                                      ),
                                      onSubmitted: (value) {
                                        if (value.trim().isNotEmpty) {
                                          setState(() {
                                            milestones.add(
                                              TextEditingController(),
                                            );
                                            milestonesFocusNodes.add(
                                              FocusNode(),
                                            );
                                          });
                                          Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () {
                                              if (!mounted ||
                                                  milestonesFocusNodes
                                                      .isEmpty) {
                                                return;
                                              }
                                              milestonesFocusNodes.last
                                                  .requestFocus();
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove_circle,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        milestones[i].dispose();
                                        milestonesFocusNodes[i].dispose();
                                        milestones.removeAt(i);
                                        milestonesFocusNodes.removeAt(i);
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                  ReorderableDragStartListener(
                                    index: i,
                                    child: const Icon(
                                      Icons.drag_handle,
                                      size: 18,
                                      color: Colors.white38,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final milestoneObjs = milestones
                        .where((c) => c.text.trim().isNotEmpty)
                        .map((c) => Milestone(c.text.trim()))
                        .toList();
                    Navigator.pop(context, {
                      'title': titleController.text,
                      'smart': smartController.text,
                      'milestones': milestoneObjs,
                      'deadline': selectedDeadline,
                      'category': selectedCategory ?? 'General',
                    });
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          );
          if (result != null && (result['title'] as String).isNotEmpty) {
            final category = (result['category'] as String?)?.trim();
            await notifier.addGoal(
              Goal()
                ..title = result['title'] as String
                ..smart = result['smart'] as String?
                ..milestones = (result['milestones'] as List<Milestone>)
                ..deadline = result['deadline'] as DateTime?
                ..category = (category == null || category.isEmpty)
                    ? 'General'
                    : category,
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _handleDeleteGoal(dynamic goalKey, Goal goal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => LockinDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
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
    if (confirm == true) {
      if (!mounted) return;
      final deletedGoal = goal;
      final notifier = ref.read(goalsListProvider.notifier)
        ..deleteGoalByKey(goalKey);
      LockinSnackBar.showUndo(
        context: context,
        message: 'Goal deleted',
        onUndo: () {
          notifier.addGoal(deletedGoal.copy());
        },
      );
    }
  }
}
