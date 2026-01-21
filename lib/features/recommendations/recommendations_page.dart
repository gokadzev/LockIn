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
import 'package:lockin/constants/recommendations/goals.dart';
import 'package:lockin/constants/recommendations/habits.dart';
import 'package:lockin/constants/recommendations/tasks.dart';
import 'package:lockin/core/models/goal.dart';
import 'package:lockin/core/models/habit.dart';
import 'package:lockin/core/models/task.dart';
import 'package:lockin/core/notifications/habit_notification_manager.dart';
import 'package:lockin/core/utils/category_icon.dart';
import 'package:lockin/features/goals/goal_provider.dart';
import 'package:lockin/features/habits/habit_category_provider.dart';
import 'package:lockin/features/habits/habit_provider.dart';
import 'package:lockin/features/settings/engagement_time_provider.dart';
import 'package:lockin/features/tasks/task_provider.dart';
import 'package:lockin/widgets/recommendation_card.dart';

// Selected category for filtering recommendations. null == All
final recommendationsCategoryProvider = StateProvider<String?>((ref) => null);

class RecommendationsPage extends ConsumerWidget {
  const RecommendationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitNotifier = ref.read(habitsListProvider.notifier);
    final categories = ref.watch(habitCategoriesProvider);
    final categoriesNotifier = ref.read(habitCategoriesProvider.notifier);
    final selectedCategory = ref.watch(recommendationsCategoryProvider);
    final goalsNotifier = ref.read(goalsListProvider.notifier);
    final tasksNotifier = ref.read(tasksListProvider.notifier);
    final tasks = ref.watch(tasksListProvider);
    final habits = ref.watch(habitsListProvider);
    final goals = ref.watch(goalsListProvider);
    // Build a combined list of categories from existing app categories and suggestion items
    final catSet = <String>{};
    for (final c in categories) {
      final name = c.trim();
      if (name.isNotEmpty) catSet.add(name);
    }
    for (final s in habitSuggestionsDB) {
      catSet.add(s.category ?? 'General');
    }
    for (final s in taskSuggestionsDB) {
      catSet.add(s.category ?? 'General');
    }
    for (final s in goalSuggestionsDB) {
      catSet.add(s.category ?? 'General');
    }
    final categoryList = <String>['All', ...catSet.toList()..sort()];

    // Precompute filtered recommendation lists so we can hide empty sections
    final filteredHabits = habitSuggestionsDB
        .where((s) => !habits.any((h) => h.title == s.title))
        .where(
          (s) =>
              selectedCategory == null ||
              (s.category ?? 'General') == selectedCategory,
        )
        .toList();

    final filteredTasks = taskSuggestionsDB
        .where((s) => !tasks.any((t) => t.title == s.title))
        .where(
          (s) =>
              selectedCategory == null ||
              (s.category ?? 'General') == selectedCategory,
        )
        .toList();

    final filteredGoals = goalSuggestionsDB
        .where((s) => !goals.any((g) => g.title == s.title))
        .where(
          (s) =>
              selectedCategory == null ||
              (s.category ?? 'General') == selectedCategory,
        )
        .toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recommendations'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Habits', icon: Icon(Icons.repeat)),
              Tab(text: 'Tasks', icon: Icon(Icons.check_circle_outline)),
              Tab(text: 'Goals', icon: Icon(Icons.flag)),
            ],
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorSize: TabBarIndicatorSize.label,
            // Make the active label light (onSurface) so it contrasts with the dark background
            labelColor: Theme.of(context).colorScheme.onSurface,
            // Use a muted grey for unselected labels
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              // Category filter chips for recommendations
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (ctx, i) {
                    final cat = categoryList[i];
                    final isAll = cat == 'All';
                    final selected =
                        (isAll && selectedCategory == null) ||
                        (!isAll && selectedCategory == cat);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: selected,
                        selectedColor: Theme.of(context).colorScheme.primary,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        avatar: CircleAvatar(
                          radius: 10,
                          backgroundColor: selected
                              ? Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest
                              : Colors.transparent,
                          child: selected
                              ? Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                )
                              : Icon(
                                  categoryToIcon(cat),
                                  size: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                        ),
                        labelStyle: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(
                              color: selected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.color,
                            ),
                        onSelected: (v) {
                          ref
                              .read(recommendationsCategoryProvider.notifier)
                              .state = isAll
                              ? null
                              : (v ? cat : null);
                        },
                      ),
                    );
                  },
                  separatorBuilder: (_, _) => const SizedBox(width: 0),
                  itemCount: categoryList.length,
                ),
              ),

              const SizedBox(height: 12),

              // Tab contents
              Expanded(
                child: TabBarView(
                  children: [
                    // Habits tab
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (filteredHabits.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: Center(
                                child: Text(
                                  'No habit suggestions',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            )
                          else ...[
                            const SizedBox(height: 8),
                            Text(
                              'Habits',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: filteredHabits
                                    .map(
                                      (s) => RecommendationCard(
                                        title: s.title,
                                        description: s.description,
                                        category: s.category,
                                        onAdd: () async {
                                          final category =
                                              s.category ?? 'General';
                                          if (category.isNotEmpty &&
                                              !categories.any(
                                                (c) => c == category,
                                              )) {
                                            categoriesNotifier.addCategory(
                                              category,
                                            );
                                          }
                                          final newHabit = Habit()
                                            ..title = s.title
                                            ..frequency = s.frequency
                                            ..category = category;

                                          habitNotifier.addHabit(newHabit);

                                          try {
                                            final engagementTime = ref.read(
                                              engagementTimeProvider,
                                            );

                                            final habitId =
                                                newHabit.key?.toString() ??
                                                DateTime.now()
                                                    .millisecondsSinceEpoch
                                                    .toString();

                                            await HabitNotificationManager()
                                                .scheduleHabitReminder(
                                                  habitId: habitId,
                                                  habitTitle: s.title,
                                                  reminderTime: TimeOfDay(
                                                    hour: engagementTime.hour,
                                                    minute:
                                                        engagementTime.minute,
                                                  ),
                                                  frequency: s.frequency,
                                                );
                                          } catch (_) {
                                            debugPrint(
                                              'Failed to schedule notification for ${s.title}',
                                            );
                                          }
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Habit added: ${s.title}',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ],
                      ),
                    ),

                    // Tasks tab
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (filteredTasks.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: Center(
                                child: Text(
                                  'No task suggestions',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            )
                          else ...[
                            Text(
                              'Tasks',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: filteredTasks
                                    .map(
                                      (s) => RecommendationCard(
                                        title: s.title,
                                        description: s.description,
                                        category: s.category,
                                        priority: s.priority,
                                        onAdd: () {
                                          tasksNotifier.addTask(
                                            Task()
                                              ..title = s.title
                                              ..description = s.description
                                              ..priority = s.priority
                                              ..tags = [
                                                (s.category ?? 'General'),
                                              ],
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Task added: ${s.title}',
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ],
                      ),
                    ),

                    // Goals tab
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (filteredGoals.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: Center(
                                child: Text(
                                  'No goal suggestions',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            )
                          else ...[
                            Text(
                              'Goals',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: filteredGoals
                                    .map(
                                      (s) => RecommendationCard(
                                        title: s.title,
                                        description: s.description,
                                        category: s.category,
                                        onAdd: () {
                                          final category =
                                              s.category ?? 'General';
                                          goalsNotifier.addGoal(
                                            Goal()
                                              ..title = s.title
                                              ..smart = s.description
                                              ..category = category,
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Goal added: ${s.title}',
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
