import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/core/models/goal.dart';
import 'package:lockin/features/goals/goal_provider.dart';

class SortedGoals {
  SortedGoals({
    required this.active,
    required this.finished,
    required this.all,
  });
  final List<Goal> active;
  final List<Goal> finished;
  final List<Goal> all;
}

final sortedGoalsProvider = Provider<SortedGoals>((ref) {
  final goalsRaw = ref.watch(goalsListProvider);
  final goals = goalsRaw.toList();
  final activeGoals = goals
      .where(
        (g) =>
            (g.milestones.isEmpty && g.progress < 1.0) ||
            (g.milestones.isNotEmpty && g.milestones.any((m) => !m.completed)),
      )
      .toList();
  final finishedGoals = goals
      .where(
        (g) =>
            (g.milestones.isEmpty && g.progress >= 1.0) ||
            (g.milestones.isNotEmpty && g.milestones.every((m) => m.completed)),
      )
      .toList();
  return SortedGoals(active: activeGoals, finished: finishedGoals, all: goals);
});
