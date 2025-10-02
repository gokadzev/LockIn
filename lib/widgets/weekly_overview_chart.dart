import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lockin/constants/ui_constants.dart';
import 'package:lockin/features/dashboard/dashboard_provider.dart';
import 'package:lockin/themes/app_theme.dart';
import 'package:lockin/widgets/lockin_card.dart';

/// Widget that displays a weekly overview bar chart
class WeeklyOverviewChart extends StatelessWidget {
  const WeeklyOverviewChart({required this.stats, super.key});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return LockinCard(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.mediumSpacing),
        child: Column(
          children: [
            const Text(
              'Weekly Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: UIConstants.mediumSpacing),
            SizedBox(
              height: UIConstants.chartHeight,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: const BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: UIConstants.chartLeftReservedSize,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: TextStyle(color: scheme.onSurface),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final labels = ['Tasks', 'Habits', 'Sessions'];
                          if (value.toInt() < labels.length) {
                            return Text(
                              labels[value.toInt()],
                              style: TextStyle(color: scheme.onSurface),
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
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: scheme.onSurface.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(),
                  barGroups: [
                    _buildBarGroup(0, stats.tasksDone.toDouble()),
                    _buildBarGroup(1, stats.habitsCompleted.toDouble()),
                    _buildBarGroup(2, stats.focusSessions.toDouble()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: scheme.primary,
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }
}
