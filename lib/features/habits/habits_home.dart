import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/constants/app_constants.dart';
import 'package:lockin/core/models/habit.dart';
import 'package:lockin/core/models/habit_category.dart';
import 'package:lockin/core/notifications/habit_notification_manager.dart';
import 'package:lockin/features/categories/category_manager_dialog.dart';
import 'package:lockin/features/habits/habit_category_provider.dart';
import 'package:lockin/features/habits/habit_provider.dart';
import 'package:lockin/features/habits/habits_sorted_provider.dart';
import 'package:lockin/features/xp/xp_provider.dart';
import 'package:lockin/themes/app_theme.dart';
import 'package:lockin/widgets/lockin_app_bar.dart';
import 'package:lockin/widgets/lockin_dialog.dart';
import 'package:lockin/widgets/lockin_habit_card.dart';
import 'package:lockin/widgets/lockin_snackbar.dart';

extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class HabitsHome extends ConsumerStatefulWidget {
  const HabitsHome({super.key});

  @override
  ConsumerState<HabitsHome> createState() => _HabitsHomeState();
}

class _HabitsHomeState extends ConsumerState<HabitsHome> {
  final HabitNotificationManager _habitNotificationManager =
      HabitNotificationManager();

  @override
  void initState() {
    super.initState();
    // Check streak saver on startup
    Future.microtask(() async {
      final xpNotifier = await ref.read(xpNotifierProvider.future);
      final streakSaverAvailable = xpNotifier.profile.streakSaverAvailable;
      ref.read(habitsListProvider.notifier).checkStreaksWithStreakSaver(
        streakSaverAvailable,
        (used) async {
          if (used) {
            await xpNotifier.consumeStreakSaver(
              50,
            ); // Lose 50 XP and consume streak saver
            if (mounted) {
              LockinSnackBar.showSimple(
                context: context,
                message: 'Streak Saver used! 50 XP lost.',
              );
            }
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(sortedHabitsProvider);
    final notifier = ref.read(habitsListProvider.notifier);
    final categories = ref.watch(habitCategoriesProvider);
    final categoriesNotifier = ref.read(habitCategoriesProvider.notifier);

    // Group habits by category, only for existing categories
    final validCategories = categories.map((c) => c.name).toSet()
      ..add('General');
    final habitsByCategory = <String, List<Habit>>{};
    for (final habit in habits) {
      final cat =
          validCategories.contains(habit.category) && habit.category.isNotEmpty
          ? habit.category
          : 'General';
      habitsByCategory.putIfAbsent(cat, () => []).add(habit);
    }

    return Scaffold(
      appBar: LockinAppBar(
        title: 'Habits',
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
        child: habits.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No habits yet. Tap + to add.',
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
            : ListView(
                padding: AppConstants.sectionPadding,
                children: habits.map((habit) {
                  final habitKey = habit.key;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: HabitCard(
                      habit: habit,
                      onMarkDone: () {
                        final today = DateTime.now();
                        bool isToday(DateTime d) =>
                            d.year == today.year &&
                            d.month == today.month &&
                            d.day == today.day;
                        final wasDoneToday = habit.history.any(isToday);
                        Habit updated;
                        if (!wasDoneToday) {
                          final updatedHistory = List<DateTime>.from(
                            habit.history,
                          )..add(today);
                          updated = habit.copy()
                            ..history = updatedHistory
                            ..streak = habit.streak + 1;
                        } else {
                          final updatedHistory = List<DateTime>.from(
                            habit.history,
                          )..removeWhere(isToday);
                          updated = habit.copy()
                            ..history = updatedHistory
                            ..streak = habit.streak > 0 ? habit.streak - 1 : 0;
                        }
                        try {
                          notifier.updateHabitByKey(habitKey, updated, (
                            xpChange,
                          ) {
                            ref
                                .read(xpNotifierProvider.future)
                                .then((notifier) => notifier.addXP(xpChange));
                            LockinSnackBar.showSimple(
                              context: context,
                              message: xpChange > 0
                                  ? 'You earned $xpChange XP!'
                                  : '${-xpChange} XP removed.',
                            );
                          });
                        } catch (e) {
                          LockinSnackBar.showSimple(
                            context: context,
                            message: 'Failed to update habit: $e',
                          );
                        }
                      },
                      onEdit: () async {
                        await _showHabitDialog(
                          context: context,
                          habit: habit,
                          onSave: (result) =>
                              _handleUpdateHabit(habitKey, habit, result),
                          categories: categories,
                          categoriesNotifier: categoriesNotifier,
                        );
                      },
                      onDelete: () => _handleDeleteHabit(habitKey, habit),
                    ),
                  );
                }).toList(),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _showHabitDialog(
            context: context,
            onSave: (result) async {
              final habit = Habit()
                ..title = result['title']
                ..frequency = result['frequency']
                ..cue = result['frequency'] == 'custom'
                    ? (result['weekdays'] as List<int>).join(',')
                    : null
                ..category = result['category'] ?? 'General';
              notifier.addHabit(habit);
              // Schedule notification
              final time = result['reminder'] as TimeOfDay?;
              if (time != null) {
                await _scheduleHabitNotification(
                  habit.key.toString(),
                  habit.title,
                  time,
                  habit.frequency,
                  habit.cue,
                );
              }
            },
            categories: categories,
            categoriesNotifier: categoriesNotifier,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showHabitDialog({
    required BuildContext context,
    Habit? habit,
    required Function(Map<String, dynamic>) onSave,
    required List<HabitCategory> categories,
    required HabitCategoriesNotifier categoriesNotifier,
  }) async {
    final titleController = TextEditingController(text: habit?.title ?? '');
    var frequency = habit?.frequency ?? 'daily';
    final customWeekdays = List<bool>.filled(7, false);
    if (habit?.frequency == 'custom' && habit?.cue != null) {
      final indices = habit!.cue!
          .split(',')
          .map((e) => int.tryParse(e))
          .where((e) => e != null)
          .cast<int>();
      for (final i in indices) {
        customWeekdays[i] = true;
      }
    }
    var selectedTime = TimeOfDay.now();
    var selectedCategory =
        habit?.category ??
        (categories.isNotEmpty ? categories.first.name : 'General');

    await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return LockinDialog(
            title: Text(habit == null ? 'Add Habit' : 'Edit Habit'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(hintText: 'Habit title'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: frequency,
                    isExpanded: true,
                    decoration: InputDecoration(
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    items: ['daily', 'weekly', 'monthly', 'custom']
                        .map(
                          (f) => DropdownMenuItem(
                            value: f,
                            child: Text(f.capitalize()),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setState(() => frequency = val ?? 'daily'),
                  ),
                  if (frequency == 'custom')
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 4,
                        children: List.generate(
                          7,
                          (i) => FilterChip(
                            label: Text(
                              [
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                                'Sun',
                              ][i],
                            ),
                            selected: customWeekdays[i],
                            onSelected: (val) =>
                                setState(() => customWeekdays[i] = val),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Reminder Time:'),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (picked != null) {
                            setState(() => selectedTime = picked);
                          }
                        },
                        child: Text(selectedTime.format(context)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Category:'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedCategory,
                          isExpanded: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white12,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Colors.white24,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                          ),
                          items: categories
                              .map(
                                (cat) => DropdownMenuItem(
                                  value: cat.name,
                                  child: Text(cat.name),
                                ),
                              )
                              .toList(),
                          onChanged: (val) => setState(
                            () => selectedCategory = val ?? 'General',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        tooltip: 'Add Category',
                        onPressed: () async {
                          final controller = TextEditingController();
                          final result = await showDialog<String>(
                            context: context,
                            builder: (context) => LockinDialog(
                              title: const Text('New Category'),
                              content: TextField(
                                controller: controller,
                                decoration: const InputDecoration(
                                  hintText: 'Category name',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pop(context, controller.text),
                                  child: const Text('Add'),
                                ),
                              ],
                            ),
                          );
                          if (result != null && result.trim().isNotEmpty) {
                            categoriesNotifier.addCategory(result.trim());
                            setState(() => selectedCategory = result.trim());
                          }
                        },
                      ),
                    ],
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
                onPressed: () {
                  Navigator.pop(context, {
                    'title': titleController.text,
                    'frequency': frequency,
                    'weekdays': List<int>.generate(
                      7,
                      (i) => customWeekdays[i] ? i : -1,
                    ).where((i) => i != -1).toList(),
                    'reminder': TimeOfDay(
                      hour: selectedTime.hour,
                      minute: selectedTime.minute,
                    ),
                    'category': selectedCategory,
                  });
                  onSave({
                    'title': titleController.text,
                    'frequency': frequency,
                    'weekdays': List<int>.generate(
                      7,
                      (i) => customWeekdays[i] ? i : -1,
                    ).where((i) => i != -1).toList(),
                    'reminder': TimeOfDay(
                      hour: selectedTime.hour,
                      minute: selectedTime.minute,
                    ),
                    'category': selectedCategory,
                  });
                },
                child: Text(habit == null ? 'Add' : 'Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _scheduleHabitNotification(
    String habitId,
    String title,
    TimeOfDay time,
    String frequency,
    String? cue,
  ) async {
    await _habitNotificationManager.scheduleHabitReminder(
      habitId: habitId,
      habitTitle: title,
      reminderTime: time,
      frequency: frequency,
      customWeekdays: cue,
    );
  }

  Future<void> _handleDeleteHabit(dynamic habitKey, Habit habit) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => LockinDialog(
        title: const Text('Delete Habit'),
        content: const Text('Are you sure you want to delete this habit?'),
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
      final deletedHabit = habit;
      final notifier = ref.read(habitsListProvider.notifier);

      // Cancel the habit's notifications before deleting
      await _habitNotificationManager.cancelHabitReminders(
        habit.key.toString(),
        customWeekdays: habit.cue,
      );

      try {
        notifier.deleteHabitByKey(habitKey);

        if (!mounted) return;
        LockinSnackBar.showUndo(
          context: context,
          message: 'Habit deleted',
          onUndo: () {
            try {
              notifier.addHabit(deletedHabit.copy());
            } catch (e) {
              if (mounted) {
                LockinSnackBar.showSimple(
                  context: context,
                  message: 'Failed to restore habit: $e',
                );
              }
            }
          },
        );
      } catch (e) {
        if (mounted) {
          LockinSnackBar.showSimple(
            context: context,
            message: 'Failed to delete habit: $e',
          );
        }
      }
    }
  }

  Future<void> _handleUpdateHabit(
    dynamic habitKey,
    Habit habit,
    Map<String, dynamic> result,
  ) async {
    // Cancel old notifications first
    await _habitNotificationManager.cancelHabitReminders(
      habit.key.toString(),
      customWeekdays: habit.cue,
    );

    final updated = Habit()
      ..title = result['title']
      ..frequency = result['frequency']
      ..cue = result['frequency'] == 'custom'
          ? (result['weekdays'] as List<int>).join(',')
          : null
      ..reward = habit.reward
      ..streak = habit.streak
      ..history = List<DateTime>.from(habit.history)
      ..category = result['category'] ?? 'General';

    final notifier = ref.read(habitsListProvider.notifier);
    try {
      // If title changed, remove old notification ID
      if (habit.title != updated.title) {}

      notifier.updateHabitByKey(habitKey, updated, null);

      // Schedule new notifications
      final time = result['reminder'] as TimeOfDay?;
      if (time != null) {
        await _scheduleHabitNotification(
          updated.key.toString(),
          updated.title,
          time,
          updated.frequency,
          updated.cue,
        );
      }
    } catch (e) {
      if (!mounted) return;
      LockinSnackBar.showSimple(
        context: context,
        message: 'Failed to update habit: $e',
      );
    }
  }
}
