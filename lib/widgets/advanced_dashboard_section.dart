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

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lockin/constants/ui_constants.dart';
import 'package:lockin/features/dashboard/dashboard_provider.dart';
import 'package:lockin/widgets/card_header.dart';
import 'package:lockin/widgets/lockin_card.dart';

class AdvancedDashboardSection extends StatelessWidget {
  const AdvancedDashboardSection({required this.stats, super.key});

  final AdvancedDashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final totalFocusMinutes = stats.focusMinutesByDay.fold<int>(
      0,
      (sum, v) => sum + v,
    );
    final avgPerDay = stats.focusMinutesByDay.isEmpty
        ? 0.0
        : totalFocusMinutes / stats.focusMinutesByDay.length;

    final peakIndex = _peakIndex(stats.focusMinutesByDay);
    final peakDate = peakIndex == null
        ? null
        : stats.windowStart.add(Duration(days: peakIndex));
    final peakValue = peakIndex == null
        ? 0
        : stats.focusMinutesByDay[peakIndex];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= UIConstants.tabletBreakpoint;
        final cardWidth = isWide
            ? (constraints.maxWidth - UIConstants.largeSpacing) / 2
            : constraints.maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LockinCard(
              padding: const EdgeInsets.all(UIConstants.largeSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardHeader(
                    title: 'Advanced Insights',
                    subtitle: 'Last 30 days',
                    icon: Icons.insights_rounded,
                    containerColor: scheme.primaryContainer,
                    iconColor: scheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: UIConstants.largeSpacing),
                  Text(
                    'Focus Trend',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 160,
                    child: _FocusTrendChart(
                      minutesByDay: stats.focusMinutesByDay,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 24,
                    runSpacing: 8,
                    children: [
                      _StatPill(
                        label: 'Total',
                        value: '${totalFocusMinutes}m',
                        color: scheme.primary,
                      ),
                      _StatPill(
                        label: 'Avg/day',
                        value: '${avgPerDay.toStringAsFixed(1)}m',
                        color: scheme.secondary,
                      ),
                      _StatPill(
                        label: 'Peak',
                        value: peakDate == null
                            ? 'No data'
                            : '${DateFormat.MMMd().format(peakDate)} (${peakValue}m)',
                        color: scheme.tertiary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: UIConstants.smallSpacing,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: LockinCard(
                    padding: const EdgeInsets.all(UIConstants.largeSpacing),
                    child: _SessionEfficiencyCard(stats: stats),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: LockinCard(
                    padding: const EdgeInsets.all(UIConstants.largeSpacing),
                    child: _HabitConsistencyCard(stats: stats),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: LockinCard(
                    padding: const EdgeInsets.all(UIConstants.largeSpacing),
                    child: _BestTimeCard(stats: stats),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  int? _peakIndex(List<int> values) {
    if (values.isEmpty) return null;
    var bestIndex = 0;
    var bestValue = values.first;
    for (var i = 1; i < values.length; i++) {
      if (values[i] > bestValue) {
        bestValue = values[i];
        bestIndex = i;
      }
    }
    return bestValue == 0 ? null : bestIndex;
  }
}

class _FocusTrendChart extends StatelessWidget {
  const _FocusTrendChart({required this.minutesByDay});

  final List<int> minutesByDay;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxValue = minutesByDay.isEmpty
        ? 10
        : minutesByDay.reduce((a, b) => a > b ? a : b).toDouble();
    final safeMax = maxValue == 0 ? 10 : maxValue;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: safeMax * 1.2,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(),
          rightTitles: AxisTitles(),
          topTitles: AxisTitles(),
          bottomTitles: AxisTitles(),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: _buildSpots(),
            isCurved: true,
            color: scheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: scheme.primary.withValues(alpha: 0.18),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _buildSpots() {
    if (minutesByDay.isEmpty) return const [FlSpot.zero];
    return List<FlSpot>.generate(
      minutesByDay.length,
      (i) => FlSpot(i.toDouble(), minutesByDay[i].toDouble()),
    );
  }
}

class _SessionEfficiencyCard extends StatelessWidget {
  const _SessionEfficiencyCard({required this.stats});

  final AdvancedDashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final completionPercent = (stats.sessionCompletionRate * 100)
        .clamp(0.0, 100.0)
        .toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CardHeader(
          title: 'Session Efficiency',
          icon: Icons.timer_rounded,
        ),
        const SizedBox(height: 16),
        Text(
          '${stats.avgSessionMinutes.toStringAsFixed(1)} min',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          'Average session length',
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Text(
          '$completionPercent% completed',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: stats.sessionCompletionRate.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: scheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
          ),
        ),
      ],
    );
  }
}

class _HabitConsistencyCard extends StatelessWidget {
  const _HabitConsistencyCard({required this.stats});

  final AdvancedDashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final consistencyPercent = (stats.habitConsistencyRate * 100)
        .clamp(0.0, 100.0)
        .toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CardHeader(
          title: 'Habit Consistency',
          icon: Icons.repeat_rounded,
        ),
        const SizedBox(height: 16),
        Text(
          '$consistencyPercent%',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          'Completions over 30 days',
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: stats.habitConsistencyRate.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: scheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(scheme.secondary),
          ),
        ),
      ],
    );
  }
}

class _BestTimeCard extends StatelessWidget {
  const _BestTimeCard({required this.stats});

  final AdvancedDashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CardHeader(title: 'Best Day & Time', icon: Icons.bolt_rounded),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _HighlightTile(
                label: 'Best day',
                value: stats.bestDayLabel,
                subtitle: stats.bestDayCount == 0
                    ? 'No activity'
                    : '${stats.bestDayCount} activities',
                color: scheme.tertiary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _HighlightTile(
                label: 'Best hour',
                value: stats.bestHourLabel,
                subtitle: stats.bestHourCount == 0
                    ? 'No sessions'
                    : '${stats.bestHourCount} sessions/tasks',
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HighlightTile extends StatelessWidget {
  const _HighlightTile({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final String label;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
