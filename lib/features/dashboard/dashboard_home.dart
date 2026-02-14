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
import 'package:hive_ce/hive.dart';
import 'package:lockin/constants/app_constants.dart';
import 'package:lockin/constants/gamification_constants.dart';
import 'package:lockin/constants/hive_constants.dart';
import 'package:lockin/core/models/habit.dart';
import 'package:lockin/core/models/session.dart';
import 'package:lockin/core/models/task.dart';
import 'package:lockin/features/dashboard/dashboard_provider.dart';
import 'package:lockin/features/journal/journal_provider.dart';
import 'package:lockin/features/sessions/session_provider.dart';
import 'package:lockin/features/xp/xp_provider.dart';
import 'package:lockin/widgets/advanced_dashboard_section.dart';
import 'package:lockin/widgets/average_mood_card.dart';
import 'package:lockin/widgets/encouragement_card.dart';
import 'package:lockin/widgets/focus_overview_card.dart';
import 'package:lockin/widgets/goal_progress_card.dart';
import 'package:lockin/widgets/lockin_app_bar.dart';
import 'package:lockin/widgets/lockin_dashboard_card.dart';
import 'package:lockin/widgets/main_navigation.dart';
import 'package:lockin/widgets/monthly_overview_heatmap.dart';
import 'package:lockin/widgets/quick_stats_card.dart';
import 'package:lockin/widgets/weekly_overview_chart.dart';
import 'package:lockin/widgets/xp_dashboard_card.dart';

class DashboardHome extends ConsumerWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xpProfile = ref.watch(xpNotifierProvider);
    final userLevel = xpProfile.level;
    final isAdvanced = userLevel >= GamificationConstants.advancedLevel;
    final stats = ref.watch(dashboardStatsProvider);
    final weeklyStats = ref.watch(weeklyOverviewStatsProvider);
    final sessions = ref.watch(sessionsListProvider);
    final advancedInsights = isAdvanced
        ? ref.watch(advancedDashboardInsightsProvider)
        : null;

    return Scaffold(
      appBar: const LockinAppBar(title: 'Dashboard'),
      body: SingleChildScrollView(
        padding: AppConstants.bodyPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EncouragementCard(stats: stats, userLevel: userLevel),
            // Average Mood Card
            const AverageMoodCard(),
            LockinDashboardCard(
              title: 'Recommendations',
              items: _buildRecommendations(context, ref),
              trailing: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () {
                    Navigator.of(context).pushNamed('/recommendations');
                  },
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            if (isAdvanced) AdvancedDashboardSection(stats: advancedInsights!),
            QuickStatsCard(stats: stats),
            XPDashboardCard(xpProfile: xpProfile),
            WeeklyOverviewChart(stats: weeklyStats),
            FocusOverviewCard(sessions: sessions),
            MonthlyOverviewHeatmap(
              monthlyData: ref.watch(monthlyHeatmapProvider),
            ),
            GoalProgressCard(progress: stats.goalsProgress),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

List<DashboardItem> _buildRecommendations(BuildContext context, WidgetRef ref) {
  final taskBox = Hive.box<Task>(HiveBoxes.tasks);
  final habitBox = Hive.box<Habit>(HiveBoxes.habits);
  final sessionBox = Hive.box<Session>(HiveBoxes.sessions);
  final journals = ref.watch(journalsListProvider);
  final items = <DashboardItem>[];
  void navTo(int index) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => MainNavigation(initialIndex: index)),
    );
  }

  if (taskBox.isEmpty) {
    items.add(
      DashboardItem(
        icon: Icons.add_task,
        text: 'Add your first task to get started!',
        onTap: () => navTo(1),
      ),
    );
  } else if (taskBox.values.where((t) => !t.completed).isEmpty) {
    items.add(
      DashboardItem(
        icon: Icons.check_circle,
        text: 'Complete a task today!',
        onTap: () => navTo(1),
      ),
    );
  }
  if (habitBox.isEmpty) {
    items.add(
      DashboardItem(
        icon: Icons.repeat,
        text: 'Add a habit to build consistency.',
        onTap: () => navTo(2),
      ),
    );
  } else {
    final today = DateTime.now();
    final doneToday = habitBox.values.any(
      (h) => h.history.any(
        (d) =>
            d.year == today.year &&
            d.month == today.month &&
            d.day == today.day,
      ),
    );
    if (!doneToday) {
      items.add(
        DashboardItem(
          icon: Icons.check,
          text: 'Mark a habit as done today!',
          onTap: () => navTo(2),
        ),
      );
    }
  }
  if (sessionBox.isEmpty) {
    items.add(
      DashboardItem(
        icon: Icons.timer,
        text: 'Start a focus session to boost productivity.',
        onTap: () => navTo(4),
      ),
    );
  }
  if (journals.isEmpty) {
    items.add(
      DashboardItem(
        icon: Icons.book,
        text: 'Write your first journal entry.',
        onTap: () => navTo(5),
      ),
    );
  } else {
    final today = DateTime.now();
    final hasToday = journals.any(
      (j) =>
          j.date.year == today.year &&
          j.date.month == today.month &&
          j.date.day == today.day,
    );
    if (!hasToday) {
      items.add(
        DashboardItem(
          icon: Icons.edit,
          text: 'Reflect on your day with a journal entry.',
          onTap: () => navTo(5),
        ),
      );
    }
  }
  if (items.isEmpty) {
    items.add(
      const DashboardItem(
        icon: Icons.thumb_up,
        text: 'You are on track! Keep up the good work!',
      ),
    );
  }
  return items;
}
