import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/core/models/goal.dart';
import 'package:lockin/core/models/habit.dart';
import 'package:lockin/core/models/task.dart';

import 'package:lockin/core/notifications/habit_notification_manager.dart';
import 'package:lockin/core/utils/category_icon.dart';
import 'package:lockin/data/recommendations/goals.dart';
import 'package:lockin/data/recommendations/habits.dart';
import 'package:lockin/data/recommendations/tasks.dart';
import 'package:lockin/features/goals/goal_provider.dart';
import 'package:lockin/features/habits/habit_category_provider.dart';
import 'package:lockin/features/habits/habit_provider.dart';
import 'package:lockin/features/settings/engagement_time_provider.dart';
import 'package:lockin/features/tasks/task_provider.dart';
import 'package:lockin/themes/app_theme.dart';
import 'package:lockin/widgets/lockin_card.dart';

// Selected category for filtering recommendations. null == All
final suggestionsCategoryProvider = StateProvider<String?>((ref) => null);

class SuggestionsPage extends ConsumerWidget {
  const SuggestionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitNotifier = ref.read(habitsListProvider.notifier);
    final categories = ref.watch(habitCategoriesProvider);
    final categoriesNotifier = ref.read(habitCategoriesProvider.notifier);
    final selectedCategory = ref.watch(suggestionsCategoryProvider);
    final goalsNotifier = ref.read(goalsListProvider.notifier);
    final tasksNotifier = ref.read(tasksListProvider.notifier);
    final tasks = ref.watch(tasksListProvider);
    final habits = ref.watch(habitsListProvider);
    final goals = ref.watch(goalsListProvider);
    // Build a combined list of categories from existing app categories and suggestion items
    final catSet = <String>{};
    for (final c in categories) {
      if (c.name.trim().isNotEmpty) catSet.add(c.name);
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
              Tab(text: 'Habits', icon: Icon(Icons.self_improvement)),
              Tab(text: 'Tasks', icon: Icon(Icons.checklist)),
              Tab(text: 'Goals', icon: Icon(Icons.flag)),
            ],
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorSize: TabBarIndicatorSize.label,
            // Make the active label light (onSurface) so it contrasts with the dark background
            labelColor: Theme.of(context).colorScheme.onSurface,
            // Use a muted grey for unselected labels
            unselectedLabelColor: scheme.onSurfaceVariant,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
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
                        backgroundColor: scheme.surfaceContainerHighest,
                        avatar: CircleAvatar(
                          radius: 10,
                          backgroundColor: selected
                              ? scheme.surfaceContainerHighest
                              : Colors.transparent,
                          child: selected
                              ? Icon(
                                  Icons.check,
                                  size: 14,
                                  color: scheme.onPrimary,
                                )
                              : Icon(
                                  categoryToIcon(cat),
                                  size: 14,
                                  color: scheme.onSurfaceVariant,
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
                          ref.read(suggestionsCategoryProvider.notifier).state =
                              isAll ? null : (v ? cat : null);
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
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: filteredHabits
                                  .map(
                                    (s) => SuggestionCard(
                                      title: s.title,
                                      description: s.description,
                                      category: s.category,
                                      onAdd: () async {
                                        final category =
                                            s.category ?? 'General';
                                        if (category.isNotEmpty &&
                                            !categories.any(
                                              (c) => c.name == category,
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
                                                  minute: engagementTime.minute,
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
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: filteredTasks
                                  .map(
                                    (s) => SuggestionCard(
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
                                            ..tags = s.category != null
                                                ? [s.category!]
                                                : [],
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
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: filteredGoals
                                  .map(
                                    (s) => SuggestionCard(
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

class SuggestionCard extends StatelessWidget {
  const SuggestionCard({
    super.key,
    required this.title,
    this.description,
    this.category,
    this.priority,
    required this.onAdd,
  });
  final String title;
  final String? description;
  final String? category;
  final int? priority;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return LockinCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onAdd,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (priority != null) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          {3: 'High', 2: 'Medium', 1: 'Low'}[priority!] ?? '',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (category != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        category!,
                        style: Theme.of(context).textTheme.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        description!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Align(
                alignment: Alignment.topRight,
                child: Icon(Icons.add_circle, color: Colors.white, size: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
