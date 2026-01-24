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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/constants/app_constants.dart';
import 'package:lockin/core/models/habit.dart';
import 'package:lockin/core/notifications/habit_notification_manager.dart';
import 'package:lockin/features/categories/categories_provider.dart';
import 'package:lockin/features/categories/category_manager_dialog.dart';
import 'package:lockin/features/habits/habit_category_provider.dart';
import 'package:lockin/features/habits/habit_provider.dart';
import 'package:lockin/features/habits/habits_sorted_provider.dart';
import 'package:lockin/features/xp/xp_provider.dart';
import 'package:lockin/widgets/category_dropdown.dart';
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
    final categories = ref.watch(categoriesProvider);
    final categoriesNotifier = ref.read(habitCategoriesProvider.notifier);

    // Group habits by category, only for existing categories
    final validCategories = categories.toSet()..add('General');
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
            : ListView(
                padding: AppConstants.listContentPadding,
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
                          if (!wasDoneToday) {
                            unawaited(
                              _habitNotificationManager
                                  .skipTodayReminderIfCompleted(
                                    habit: updated,
                                    habitId: habitKey.toString(),
                                    completedAt: today,
                                  ),
                            );
                          } else {
                            final reminderTime = _minutesToTime(
                              updated.reminderMinutes,
                            );
                            if (reminderTime != null) {
                              unawaited(
                                _habitNotificationManager
                                    .rescheduleHabitReminder(
                                      habitId: habitKey.toString(),
                                      habitTitle: updated.title,
                                      reminderTime: reminderTime,
                                      frequency: updated.frequency,
                                      customWeekdays: updated.cue,
                                    ),
                              );
                            }
                          }
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
              final reminder = result['reminder'] as TimeOfDay?;
              final frequency = result['frequency'] as String;
              final cue = frequency == 'custom'
                  ? (result['weekdays'] as List<int>).join(',')
                  : frequency == 'weekly'
                  ? DateTime.now().weekday.toString()
                  : frequency == 'monthly'
                  ? DateTime.now().day.toString()
                  : null;
              final habit = Habit()
                ..title = result['title']
                ..frequency = frequency
                ..cue = cue
                ..reminderMinutes = _timeToMinutes(reminder)
                ..category = result['category'] ?? 'General';
              notifier.addHabit(habit);
              // Schedule notification
              if (reminder != null) {
                await _scheduleHabitNotification(
                  habit.key.toString(),
                  habit.title,
                  reminder,
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
    required List<String> categories,
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
        int? index;
        if (i >= 1 && i <= 7) {
          index = i - 1;
        } else if (i >= 0 && i < 7) {
          index = i;
        }
        if (index != null && index >= 0 && index < customWeekdays.length) {
          customWeekdays[index] = true;
        }
      }
    }
    // Initialize selectedTime with the habit's reminder time if available
    final reminderMinutes = habit?.reminderMinutes;
    final initialReminderTime = _minutesToTime(reminderMinutes);
    var selectedTime = initialReminderTime ?? TimeOfDay.now();
    var selectedCategory =
        habit?.category ??
        (categories.isNotEmpty ? categories.first : 'General');
    final categoryNames = {
      if (categories.isNotEmpty) ...categories,
      selectedCategory,
    }.toList();
    if (categoryNames.isEmpty) {
      categoryNames.add('General');
    }
    if (!categoryNames.contains(selectedCategory)) {
      selectedCategory = categoryNames.first;
    }

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
                      Expanded(
                        child: CategoryDropdown(
                          value: selectedCategory,
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
                  if (frequency == 'custom' &&
                      !customWeekdays.any((day) => day)) {
                    LockinSnackBar.showSimple(
                      context: context,
                      message: 'Select at least one day for custom frequency.',
                    );
                    return;
                  }
                  final result = {
                    'title': titleController.text,
                    'frequency': frequency,
                    'weekdays': List<int>.generate(
                      7,
                      (i) => customWeekdays[i] ? i + 1 : -1,
                    ).where((i) => i != -1).toList(),
                    'reminder': TimeOfDay(
                      hour: selectedTime.hour,
                      minute: selectedTime.minute,
                    ),
                    'category': selectedCategory,
                  };
                  Navigator.pop(context, result);
                  onSave(result);
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
              final restored = deletedHabit.copy();
              notifier.addHabit(restored);
              final reminderTime = _minutesToTime(restored.reminderMinutes);
              if (reminderTime != null) {
                unawaited(
                  _scheduleHabitNotification(
                    restored.key.toString(),
                    restored.title,
                    reminderTime,
                    restored.frequency,
                    restored.cue,
                  ),
                );
              }
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

    String? weeklyCue;
    if (result['frequency'] == 'weekly') {
      final existingCue = habit.frequency == 'weekly' ? habit.cue : null;
      final parsed = int.tryParse(existingCue ?? '');
      if (parsed != null) {
        if (parsed >= 1 && parsed <= 7) {
          weeklyCue = parsed.toString();
        } else if (parsed >= 0 && parsed <= 6) {
          weeklyCue = (parsed + 1).toString();
        }
      }
      weeklyCue ??= DateTime.now().weekday.toString();
    }

    String? monthlyCue;
    if (result['frequency'] == 'monthly') {
      final existingCue = habit.frequency == 'monthly' ? habit.cue : null;
      final parsed = int.tryParse(existingCue ?? '');
      if (parsed != null && parsed >= 1 && parsed <= 31) {
        monthlyCue = parsed.toString();
      }
      monthlyCue ??= DateTime.now().day.toString();
    }

    final updated = Habit()
      ..title = result['title']
      ..frequency = result['frequency']
      ..cue = result['frequency'] == 'custom'
          ? (result['weekdays'] as List<int>).join(',')
          : result['frequency'] == 'weekly'
          ? weeklyCue
          : result['frequency'] == 'monthly'
          ? monthlyCue
          : null
      ..reward = habit.reward
      ..streak = habit.streak
      ..history = List<DateTime>.from(habit.history)
      ..reminderMinutes = _timeToMinutes(result['reminder'] as TimeOfDay?)
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
          habitKey.toString(),
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

  int? _timeToMinutes(TimeOfDay? time) {
    if (time == null) return null;
    return time.hour * 60 + time.minute;
  }

  TimeOfDay? _minutesToTime(int? minutes) {
    if (minutes == null) return null;
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }
}
