import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/core/models/habit.dart';
import 'package:lockin/features/habits/habit_provider.dart';

final sortedHabitsProvider = Provider<List<Habit>>((ref) {
  final habitsRaw = ref.watch(habitsListProvider);
  final habits = habitsRaw.toList()
    ..sort((a, b) => b.streak.compareTo(a.streak));
  return habits;
});
