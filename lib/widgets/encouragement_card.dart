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
import 'package:lockin/constants/gamification_constants.dart';
import 'package:lockin/features/dashboard/dashboard_provider.dart';
import 'package:lockin/widgets/lockin_card.dart';

/// Widget that displays an encouraging message based on user progress
class EncouragementCard extends StatelessWidget {
  const EncouragementCard({
    required this.stats,
    required this.userLevel,
    super.key,
  });

  final DashboardStats stats;
  final int userLevel;

  String get encouragementMessage {
    final streak = stats.streak;

    // Check level-based encouragements
    if (userLevel >= GamificationConstants.legendaryLevel) {
      return "Legendary! You're setting new standards. Level $userLevel achieved!";
    } else if (userLevel >= GamificationConstants.incredibleLevel) {
      return 'Incredible! Your growth is unstoppable. Level $userLevel unlocked.';
    } else if (userLevel >= GamificationConstants.masterLevel) {
      return "You're a productivity master! Keep inspiring others.";
    }

    // Check streak-based encouragements
    if (streak >= GamificationConstants.longStreakDays) {
      return '${GamificationConstants.longStreakDays}-day streak! Your consistency is remarkable.';
    } else if (streak >= GamificationConstants.mediumStreakDays) {
      return 'Two weeks strong! $streak days in a row. Amazing dedication!';
    }

    // Check level-based (continued)
    if (userLevel >= GamificationConstants.advancedLevel) {
      return "Level $userLevel! You're making serious progress.";
    }

    // Check achievement-based encouragements
    if (stats.tasksDone >= GamificationConstants.tasksCompletedMilestone) {
      return '${GamificationConstants.tasksCompletedMilestone}+ tasks completed! Outstanding achievement.';
    } else if (stats.habitsCompleted >=
        GamificationConstants.habitsCompletedMilestone) {
      return '${GamificationConstants.habitsCompletedMilestone}+ habits completed! Your routines are solidifying.';
    }

    // More level checks
    if (userLevel >= GamificationConstants.intermediateLevel) {
      return 'Amazing! Your dedication is paying off. Level $userLevel unlocked.';
    } else if (streak >= GamificationConstants.shortStreakDays) {
      return 'Great streak! $streak days in a row. Your dedication is inspiring!';
    } else if (userLevel > GamificationConstants.beginnerLevel) {
      return 'Level $userLevel reached! Every step counts.';
    } else if (stats.tasksDone > 0 || stats.habitsCompleted > 0) {
      return 'Nice start! Keep building your momentum.';
    }

    return 'Welcome! Start your journey and level up your life.';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LockinCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              encouragementMessage,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
