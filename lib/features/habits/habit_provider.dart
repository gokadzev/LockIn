import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:lockin/constants/app_values.dart';
import 'package:lockin/core/models/habit.dart';
import 'package:lockin/core/utils/box_crud_mixin.dart';

/// Provides access to the Hive box for habits.
final habitsBoxProvider = Provider<Box<Habit>?>((ref) {
  try {
    return Hive.isBoxOpen('habits') ? Hive.box<Habit>('habits') : null;
  } catch (e) {
    return null;
  }
});

/// Main provider for the list of habits, using [HabitsNotifier].
final habitsListProvider = StateNotifierProvider<HabitsNotifier, List<Habit>>((
  ref,
) {
  final box = ref.watch(habitsBoxProvider);
  return HabitsNotifier(box)..startWatchingBox();
});

/// StateNotifier for managing the list of habits, including streak logic and XP updates.
class HabitsNotifier extends StateNotifier<List<Habit>>
    with BoxCrudMixin<Habit> {
  /// Creates a HabitsNotifier backed by the given Hive [box].
  HabitsNotifier(this.box) : super(box?.values.toList() ?? []);
  @override
  final Box<Habit>? box;

  /// Checks all habits for missed days and resets streaks if needed.
  /// If [streakSaverAvailable] is true and a streak is missed by 1-3 days, calls [onStreakSaverUsed].
  void checkStreaksWithStreakSaver(
    bool streakSaverAvailable,
    void Function(bool used)? onStreakSaverUsed,
  ) {
    if (box == null) return;
    final now = DateTime.now();
    for (var i = 0; i < box!.length; i++) {
      final habit = box!.getAt(i);
      if (habit == null || habit.history.isEmpty) continue;
      final lastDone = habit.history.last;
      final daysMissed = now.difference(lastDone).inDays;
      if (daysMissed > 1) {
        if (streakSaverAvailable && daysMissed <= 3) {
          onStreakSaverUsed?.call(true);
        } else {
          habit.streak = 0;
          updateItem(i, habit);
        }
      }
    }
    syncStateFromBox();
  }

  /// Adds a new habit to the box and updates state.
  void addHabit(Habit habit) => addItem(habit);

  /// Updates a habit at [index], recalculates streak, and manages XP for today's completion.
  void updateHabit(
    int index,
    Habit habit,
    void Function(int xpChange)? onXPChange,
  ) {
    if (box == null) return;
    if (index < 0 || index >= box!.length) return;
    final prevHabit = box!.getAt(index);
    final today = DateTime.now();
    bool isSameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    bool isToday(DateTime d) => isSameDay(d, today);

    final normalizedToday = DateTime(today.year, today.month, today.day);
    // Normalize all history entries to date-only and remove duplicates.
    habit.history =
        (habit.history
            .map((d) => DateTime(d.year, d.month, d.day))
            .toSet()
            .toList()
          ..sort());
    final prevHistory =
        prevHabit?.history
                  .map((d) => DateTime(d.year, d.month, d.day))
                  .toList() ??
              []
          ..sort();

    final wasDoneToday = prevHistory.any(isToday);
    final isDoneToday = habit.history.any(isToday);

    // Ensure only one entry for today in history.
    if (isDoneToday) {
      habit.history = [
        ...habit.history.where((d) => !isToday(d)),
        normalizedToday,
      ]..sort();
    }

    // Recalculate streak: count consecutive days up to today.
    int computeStreak(List<DateTime> history) {
      if (history.isEmpty) return 0;
      history.sort();
      var streak = 0;
      var cursor = normalizedToday;
      while (true) {
        final found = history.any((d) => isSameDay(d, cursor));
        if (!found) break;
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      }
      return streak;
    }

    habit.streak = computeStreak(habit.history);

    updateItem(index, habit);

    // Award or remove XP if today's completion status changed.
    if (!wasDoneToday && isDoneToday) {
      onXPChange?.call(AppValues.habitCompletionXP);
    } else if (wasDoneToday && !isDoneToday) {
      onXPChange?.call(-AppValues.habitCompletionXP);
    }
  }

  /// Deletes a habit at [index] from the box and updates state.
  void deleteHabit(int index) => deleteItem(index);

  /// Update habit by Hive [key] instead of index.
  void updateHabitByKey(
    dynamic key,
    Habit habit,
    void Function(int xpChange)? onXPChange,
  ) {
    if (box == null) return;
    final keys = box!.keys.toList();
    final index = keys.indexOf(key);
    if (index == -1) return;
    updateHabit(index, habit, onXPChange);
  }

  /// Delete habit by Hive [key] instead of index.
  void deleteHabitByKey(dynamic key) {
    if (box == null) return;
    final keys = box!.keys.toList();
    final index = keys.indexOf(key);
    if (index == -1) return;
    deleteHabit(index);
  }

  @override
  void dispose() {
    stopWatchingBox();
    super.dispose();
  }
}
