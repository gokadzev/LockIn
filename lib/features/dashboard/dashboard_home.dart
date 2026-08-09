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
import 'package:lockin/constants/app_constants.dart';
import 'package:lockin/constants/gamification_constants.dart';
import 'package:lockin/core/utils/extensions/date_time_extensions.dart';
import 'package:lockin/features/dashboard/dashboard_provider.dart';
import 'package:lockin/features/habits/habit_provider.dart';
import 'package:lockin/features/journal/journal_provider.dart';
import 'package:lockin/features/sessions/session_provider.dart';
import 'package:lockin/features/tasks/task_provider.dart';
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

class DashboardHome extends ConsumerStatefulWidget {
  const DashboardHome({super.key});

  @override
  ConsumerState<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends ConsumerState<DashboardHome> {
  var _subscriptionsReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
        ..read(xpNotifierProvider)
        ..read(dashboardStatsProvider)
        ..read(weeklyOverviewStatsProvider)
        ..read(advancedDashboardInsightsProvider)
        ..read(monthlyHeatmapProvider);
      if (mounted) setState(() => _subscriptionsReady = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_subscriptionsReady) return const SizedBox.shrink();

    return const Scaffold(
      appBar: LockinAppBar(title: 'Dashboard'),
      body: SingleChildScrollView(
        padding: AppConstants.bodyPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DashboardSummary(),
            // Average Mood Card
            AverageMoodCard(),
            _DashboardRecommendations(),
            _AdvancedDashboard(),
            _DashboardQuickStats(),
            _DashboardXP(),
            _DashboardActivity(),
            _DashboardGoalProgress(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _DashboardSummary extends ConsumerWidget {
  const _DashboardSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xpProfile = ref.watch(xpNotifierProvider);
    final stats = ref.watch(dashboardStatsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [EncouragementCard(stats: stats, userLevel: xpProfile.level)],
    );
  }
}

class _DashboardQuickStats extends ConsumerWidget {
  const _DashboardQuickStats();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return QuickStatsCard(stats: ref.watch(dashboardStatsProvider));
  }
}

class _DashboardXP extends ConsumerWidget {
  const _DashboardXP();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return XPDashboardCard(xpProfile: ref.watch(xpNotifierProvider));
  }
}

class _AdvancedDashboard extends ConsumerWidget {
  const _AdvancedDashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userLevel = ref.watch(xpNotifierProvider).level;
    if (userLevel < GamificationConstants.advancedLevel) {
      return const SizedBox.shrink();
    }
    return AdvancedDashboardSection(
      stats: ref.watch(advancedDashboardInsightsProvider),
    );
  }
}

class _DashboardActivity extends ConsumerWidget {
  const _DashboardActivity();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WeeklyOverviewChart(stats: ref.watch(weeklyOverviewStatsProvider)),
        FocusOverviewCard(sessions: ref.watch(sessionsListProvider)),
        MonthlyOverviewHeatmap(monthlyData: ref.watch(monthlyHeatmapProvider)),
      ],
    );
  }
}

class _DashboardRecommendations extends ConsumerWidget {
  const _DashboardRecommendations();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = _buildRecommendations(context, ref);
    return LockinDashboardCard(
      title: 'Recommendations',
      items: items,
      trailing: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => Navigator.of(context).pushNamed('/recommendations'),
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
    );
  }
}

class _DashboardGoalProgress extends ConsumerWidget {
  const _DashboardGoalProgress();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GoalProgressCard(
      progress: ref.watch(dashboardStatsProvider).goalsProgress,
    );
  }
}

List<DashboardItem> _buildRecommendations(BuildContext context, WidgetRef ref) {
  final tasks = ref.watch(tasksListProvider);
  final habits = ref.watch(habitsListProvider);
  final sessions = ref.watch(sessionsListProvider);
  final journals = ref.watch(journalsListProvider);
  final items = <DashboardItem>[];
  void navTo(int index) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => MainNavigation(initialIndex: index)),
    );
  }

  if (tasks.isEmpty) {
    items.add(
      DashboardItem(
        icon: Icons.add_task,
        text: 'Add your first task to get started!',
        onTap: () => navTo(1),
      ),
    );
  } else if (tasks.every((t) => t.completed)) {
    items.add(
      DashboardItem(
        icon: Icons.check_circle,
        text: 'Complete a task today!',
        onTap: () => navTo(1),
      ),
    );
  }
  if (habits.isEmpty) {
    items.add(
      DashboardItem(
        icon: Icons.repeat,
        text: 'Add a habit to build consistency.',
        onTap: () => navTo(2),
      ),
    );
  } else {
    final today = DateTime.now();
    final doneToday = habits.any(
      (h) => h.history.any((d) => d.isSameDay(today)),
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
  if (sessions.isEmpty) {
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
    final hasToday = journals.any((j) => j.date.isSameDay(today));
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
