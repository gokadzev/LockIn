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
