import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:lockin/constants/app_constants.dart';
import 'package:lockin/constants/gamification_constants.dart';
import 'package:lockin/constants/ui_constants.dart';
import 'package:lockin/core/models/habit.dart';
import 'package:lockin/core/models/session.dart';
import 'package:lockin/core/models/task.dart';
import 'package:lockin/core/utils/category_icon.dart';
import 'package:lockin/features/dashboard/dashboard_provider.dart';
import 'package:lockin/features/journal/journal_provider.dart';
import 'package:lockin/features/sessions/session_provider.dart';
import 'package:lockin/features/xp/xp_provider.dart';
import 'package:lockin/widgets/average_mood_card.dart';
import 'package:lockin/widgets/card_header.dart';
import 'package:lockin/widgets/encouragement_card.dart';
import 'package:lockin/widgets/lockin_app_bar.dart';
import 'package:lockin/widgets/lockin_card.dart';
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
    final stats = ref.watch(dashboardStatsProvider);
    final weeklyStats = ref.watch(weeklyOverviewStatsProvider);
    final statsFull = stats;
    final focusCategoryStats = _buildFocusCategoryStats(
      ref.watch(sessionsListProvider),
      Theme.of(context).colorScheme,
    );
    final xpState = ref.watch(xpNotifierProvider);
    final xpProfile = xpState.asData?.value.profile;
    final userLevel = xpProfile?.level ?? 0;
    final scheme = Theme.of(context).colorScheme;

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
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pushNamed('/recommendations');
                },
              ),
            ),
            if (userLevel >= GamificationConstants.advancedLevel &&
                _buildStats(statsFull).isNotEmpty)
              LockinDashboardCard(title: 'Stats', items: _buildStats(statsFull))
            else
              QuickStatsCard(stats: stats),
            if (xpProfile != null) XPDashboardCard(xpProfile: xpProfile),
            WeeklyOverviewChart(stats: weeklyStats),
            if (focusCategoryStats.isNotEmpty)
              _buildFocusCategoryBreakdownCard(context, focusCategoryStats),
            MonthlyOverviewHeatmap(
              monthlyData: ref.watch(monthlyHeatmapProvider),
            ),
            LockinCard(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Goal Progress',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: stats.goalsProgress * 100,
                                  color: scheme.onSurface,
                                  title: '',
                                  radius: 40,
                                  borderSide: BorderSide.none,
                                ),
                                PieChartSectionData(
                                  value: 100 - (stats.goalsProgress * 100),
                                  color: scheme.surfaceContainerHigh,
                                  title: '',
                                  radius: 40,
                                  borderSide: BorderSide.none,
                                ),
                              ],
                              sectionsSpace: 0,
                              centerSpaceRadius: 55,
                              startDegreeOffset: -90,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(stats.goalsProgress * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Complete',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Completed',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Remaining',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

List<DashboardItem> _buildRecommendations(BuildContext context, WidgetRef ref) {
  final taskBox = Hive.box<Task>('tasks');
  final habitBox = Hive.box<Habit>('habits');
  final sessionBox = Hive.box<Session>('sessions');
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

class _FocusCategoryStat {
  const _FocusCategoryStat({
    required this.name,
    required this.count,
    required this.percent,
    required this.color,
  });

  final String name;
  final int count;
  final double percent;
  final Color color;
}

List<_FocusCategoryStat> _buildFocusCategoryStats(
  List<Session> sessions,
  ColorScheme scheme,
) {
  if (sessions.isEmpty) return [];

  String normalizeCategory(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? 'Uncategorized' : trimmed;
  }

  final counts = <String, int>{};
  for (final session in sessions) {
    final category = normalizeCategory(session.category);
    counts[category] = (counts[category] ?? 0) + 1;
  }

  final total = counts.values.fold<int>(0, (a, b) => a + b);
  if (total == 0) return [];

  final sorted = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final palette = <Color>[
    scheme.primary,
    scheme.secondary,
    scheme.tertiary,
    scheme.error,
    scheme.primaryContainer,
    scheme.secondaryContainer,
  ];

  final stats = <_FocusCategoryStat>[];
  for (var i = 0; i < sorted.length; i++) {
    final entry = sorted[i];
    stats.add(
      _FocusCategoryStat(
        name: entry.key,
        count: entry.value,
        percent: (entry.value / total) * 100,
        color: palette[i % palette.length],
      ),
    );
  }

  return stats;
}

Widget _buildFocusCategoryBreakdownCard(
  BuildContext context,
  List<_FocusCategoryStat> stats,
) {
  final totalSessions = stats.fold<int>(0, (sum, s) => sum + s.count);
  final top = stats.first;
  final scheme = Theme.of(context).colorScheme;

  return LockinCard(
    padding: const EdgeInsets.all(UIConstants.largeSpacing),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CardHeader(
          title: 'Focus Overview',
          subtitle: '$totalSessions sessions',
          icon: Icons.donut_large,
          containerColor: scheme.secondaryContainer,
          iconColor: scheme.onSecondaryContainer,
        ),
        const SizedBox(height: 12),
        Text(
          'Most focused: ${top.name} — ${top.percent.toStringAsFixed(0)}% (${top.count})',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                for (final stat in stats)
                  Expanded(
                    flex: stat.count,
                    child: Container(color: stat.color),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...stats.map(
          (stat) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      categoryToIcon(
                        stat.name == 'Uncategorized' ? null : stat.name,
                      ),
                      color: stat.color,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        stat.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${stat.percent.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${stat.count}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: stat.percent / 100,
                    minHeight: 6,
                    backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(stat.color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

// Build items for stats card
List<DashboardItem> _buildStats(DashboardStats statsFull) {
  final items = <DashboardItem>[];
  if (statsFull.avgDuration > 0) {
    items.add(
      DashboardItem(
        icon: Icons.timer,
        text:
            'Avg Task Duration: ${statsFull.avgDuration.toStringAsFixed(1)} min',
      ),
    );
  }
  if (statsFull.clusters.isNotEmpty) {
    items.add(
      DashboardItem(
        icon: Icons.bolt,
        text: 'Focus: ${statsFull.clusters.map((c) => '$c:00').join(', ')}',
      ),
    );
  }
  if (statsFull.streak > 1) {
    items.add(
      DashboardItem(
        icon: Icons.local_fire_department,
        text: 'Streak: ${statsFull.streak} days',
      ),
    );
  }
  if (statsFull.accuracy > 0 && statsFull.accuracy < 1) {
    items.add(
      DashboardItem(
        icon: Icons.insights,
        text:
            'Estimate Accuracy: ${(statsFull.accuracy * 100).toStringAsFixed(1)}%',
      ),
    );
  }
  if (statsFull.fatigue.abs() > 0.1) {
    items.add(
      DashboardItem(
        icon: Icons.battery_alert,
        text: 'Fatigue: ${statsFull.fatigue.toStringAsFixed(1)}',
      ),
    );
  }
  if (statsFull.heatmap.isNotEmpty) {
    final hourlyEntries = statsFull.heatmap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    items.add(
      DashboardItem(
        icon: Icons.grid_on,
        text:
            'Hourly: ${hourlyEntries.map((e) => '${e.key}:00→${e.value}').join(', ')}',
      ),
    );
  }
  if (statsFull.nudge.isNotEmpty &&
      statsFull.nudge != 'Keep up the good work!') {
    items.add(DashboardItem(icon: Icons.lightbulb, text: statsFull.nudge));
  }

  final habitBox = Hive.box<Habit>('habits');
  final taskBox = Hive.box<Task>('tasks');
  final weekCompletions = <DateTime, int>{};
  for (final habit in habitBox.values) {
    if (habit.abandoned) continue;
    for (final date in habit.history) {
      final weekStart = DateTime(
        date.year,
        date.month,
        date.day - date.weekday + 1,
      );
      weekCompletions[weekStart] = (weekCompletions[weekStart] ?? 0) + 1;
    }
  }
  for (final task in taskBox.values) {
    if (task.completed && !task.abandoned && task.completionTime != null) {
      final date = task.completionTime!;
      final weekStart = DateTime(
        date.year,
        date.month,
        date.day - date.weekday + 1,
      );
      weekCompletions[weekStart] = (weekCompletions[weekStart] ?? 0) + 1;
    }
  }
  if (weekCompletions.isNotEmpty) {
    final bestWeek = weekCompletions.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
    final weekStr =
        '${DateFormat.yMMMd().format(bestWeek.key)} - '
        '${DateFormat.yMMMd().format(bestWeek.key.add(const Duration(days: 6)))}';
    items.add(
      DashboardItem(
        icon: Icons.calendar_today,
        text: 'Best week: $weekStr\n${bestWeek.value} completions',
      ),
    );
  }

  Habit? topHabit;
  var topHabitCount = 0;
  for (final habit in habitBox.values) {
    if (habit.abandoned) continue;
    if (habit.history.length > topHabitCount) {
      topHabit = habit;
      topHabitCount = habit.history.length;
    }
  }
  Task? topTask;
  var topTaskCount = 0;
  final taskCounts = <String, int>{};
  for (final task in taskBox.values) {
    if (task.completed && !task.abandoned) {
      taskCounts[task.title] = (taskCounts[task.title] ?? 0) + 1;
    }
  }
  if (taskCounts.isNotEmpty) {
    final topEntry = taskCounts.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
    topTask = taskBox.values.firstWhere(
      (task) => task.completed && !task.abandoned && task.title == topEntry.key,
    );
    topTaskCount = topEntry.value;
  }
  if (topHabit != null || topTask != null) {
    var text = '';
    if (topHabit != null) {
      text += 'Most completed habit: ${topHabit.title} ($topHabitCount times)';
    }
    if (topTask != null) {
      if (text.isNotEmpty) text += '\n';
      text +=
          'Most completed task: ${topTask.title}'
          '${topTaskCount > 1 ? ' ($topTaskCount times)' : ''}';
    }
    items.add(DashboardItem(icon: Icons.star, text: text));
  }

  return items;
}
