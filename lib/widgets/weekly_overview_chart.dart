import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lockin/constants/ui_constants.dart';
import 'package:lockin/features/dashboard/dashboard_provider.dart';
import 'package:lockin/widgets/card_header.dart';
import 'package:lockin/widgets/lockin_card.dart';

/// Widget that displays a weekly overview bar chart
class WeeklyOverviewChart extends StatelessWidget {
  const WeeklyOverviewChart({required this.stats, super.key});

  final WeeklyOverviewStats stats;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Check if there's any activity this week
    final hasActivity =
        stats.tasksDone > 0 ||
        stats.habitsCompleted > 0 ||
        stats.focusSessions > 0;

    return LockinCard(
      padding: const EdgeInsets.all(UIConstants.largeSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const CardHeader(
            title: 'Weekly Overview',
            subtitle: 'Your productivity this week',
            icon: Icons.insights_rounded,
          ),
          const SizedBox(height: UIConstants.largeSpacing),

          // Chart or Empty State
          if (hasActivity)
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY() * 1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => colorScheme.inverseSurface,
                      tooltipBorderRadius: BorderRadius.circular(8),
                      tooltipPadding: const EdgeInsets.all(12),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final labels = ['Tasks', 'Habits', 'Sessions'];
                        return BarTooltipItem(
                          '${labels[group.x]}\n',
                          TextStyle(
                            color: colorScheme.onInverseSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: '${rod.toY.toInt()} completed',
                              style: TextStyle(
                                color: colorScheme.onInverseSurface.withValues(
                                  alpha: 0.8,
                                ),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: _getInterval(),
                        getTitlesWidget: (value, meta) {
                          // Only show if it's a multiple of the interval and not 0
                          if (value == 0 || value % _getInterval() != 0) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            value.toInt().toString(),
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.8,
                              ),
                              fontSize: 11,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          final labels = ['Tasks', 'Habits', 'Sessions'];
                          if (value.toInt() < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                labels[value.toInt()],
                                style: textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                  ),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: _getInterval(),
                    getDrawingHorizontalLine: (value) {
                      if (value == 0) {
                        return FlLine(
                          color: colorScheme.outline.withValues(alpha: 0.3),
                          strokeWidth: 1,
                        );
                      }
                      return FlLine(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.2,
                        ),
                        strokeWidth: 0.8,
                        dashArray: [4, 4],
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _buildBarGroup(
                      0,
                      stats.tasksDone.toDouble(),
                      colorScheme.primary,
                    ),
                    _buildBarGroup(
                      1,
                      stats.habitsCompleted.toDouble(),
                      colorScheme.secondary,
                    ),
                    _buildBarGroup(
                      2,
                      stats.focusSessions.toDouble(),
                      colorScheme.tertiary,
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      size: 48,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No activity this week',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Start a task, habit, or session to see your stats',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: UIConstants.largeSpacing),

          // Stats Summary
          Container(
            padding: const EdgeInsets.all(UIConstants.mediumSpacing),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  stats.tasksDone,
                  'Tasks',
                  colorScheme.primary,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
                _buildStatItem(
                  context,
                  stats.habitsCompleted,
                  'Habits',
                  colorScheme.secondary,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
                _buildStatItem(
                  context,
                  stats.focusSessions,
                  'Sessions',
                  colorScheme.tertiary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    int value,
    String label,
    Color color,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.toString(),
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 40,
          borderRadius: BorderRadius.circular(12),
        ),
      ],
    );
  }

  double _getMaxY() {
    final maxValue = [
      stats.tasksDone,
      stats.habitsCompleted,
      stats.focusSessions,
    ].reduce((a, b) => a > b ? a : b).toDouble();

    return maxValue == 0 ? 10 : maxValue;
  }

  double _getInterval() {
    final maxY = _getMaxY();
    if (maxY <= 5) return 2;
    if (maxY <= 10) return 5;
    if (maxY <= 20) return 5;
    if (maxY <= 50) return 10;
    return 20;
  }
}
