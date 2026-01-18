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
import 'package:lockin/constants/ui_constants.dart';
import 'package:lockin/widgets/card_header.dart';
import 'package:lockin/widgets/lockin_card.dart';

/// Widget that displays a monthly overview as a GitHub contributions-style heatmap
class MonthlyOverviewHeatmap extends StatelessWidget {
  const MonthlyOverviewHeatmap({required this.monthlyData, super.key});

  final Map<DateTime, int> monthlyData;

  List<Color> _getColorGradient(ColorScheme colorScheme) {
    return [
      colorScheme.surface, // No activity
      colorScheme.outline.withValues(alpha: 0.3), // Very low
      colorScheme.primary.withValues(alpha: 0.3), // Low
      colorScheme.primary.withValues(alpha: 0.5), // Medium-low
      colorScheme.primary.withValues(alpha: 0.7), // Medium
      colorScheme.primary, // High
    ];
  }

  Color _getColorForCount(int count, ColorScheme colorScheme) {
    final gradient = _getColorGradient(colorScheme);
    if (count == 0) return gradient[0];
    if (count == 1) return gradient[1];
    if (count <= 2) return gradient[2];
    if (count <= 4) return gradient[3];
    if (count <= 7) return gradient[4];
    return gradient[5];
  }

  int _getCountForDate(DateTime date) {
    return monthlyData[DateTime(date.year, date.month, date.day)] ?? 0;
  }

  String _getMonthYearString(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Get the current month's dates
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastDay.day;

    final totalActivity = monthlyData.values.fold<int>(0, (sum, v) => sum + v);
    final maxActivity = monthlyData.values.isEmpty
        ? 0
        : monthlyData.values.reduce((a, b) => a > b ? a : b);

    return LockinCard(
      padding: const EdgeInsets.all(UIConstants.largeSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          CardHeader(
            title: 'Monthly Overview',
            subtitle: _getMonthYearString(now),
            icon: Icons.calendar_month_rounded,
          ),
          const SizedBox(height: UIConstants.largeSpacing),

          // Heatmap Grid - GitHub style (grid of all days in the month)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: List.generate(daysInMonth, (index) {
                final day = index + 1;
                final date = DateTime(now.year, now.month, day);
                final count = _getCountForDate(date);

                return _HeatmapCell(
                  date: date,
                  count: count,
                  color: _getColorForCount(count, colorScheme),
                  colorScheme: colorScheme,
                );
              }),
            ),
          ),

          const SizedBox(height: UIConstants.largeSpacing),

          // Legend and stats
          Container(
            padding: const EdgeInsets.all(UIConstants.mediumSpacing),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      label: 'Total Activity',
                      value: totalActivity.toString(),
                      color: colorScheme.primary,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                    _StatItem(
                      label: 'Peak Day',
                      value: maxActivity.toString(),
                      color: colorScheme.secondary,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                    _StatItem(
                      label: 'Avg per Day',
                      value: (totalActivity / daysInMonth).toStringAsFixed(1),
                      color: colorScheme.tertiary,
                    ),
                  ],
                ),
                const SizedBox(height: UIConstants.mediumSpacing),
                // Color legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Less',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ..._getColorGradient(colorScheme).asMap().entries.map((
                      entry,
                    ) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: entry.value,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(
                              color: colorScheme.outline.withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                    Text(
                      'More',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual cell in the heatmap
class _HeatmapCell extends StatefulWidget {
  const _HeatmapCell({
    required this.date,
    required this.count,
    required this.color,
    required this.colorScheme,
  });

  final DateTime date;
  final int count;
  final Color color;
  final ColorScheme colorScheme;

  @override
  State<_HeatmapCell> createState() => _HeatmapCellState();
}

class _HeatmapCellState extends State<_HeatmapCell> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Tooltip(
        message:
            '${widget.count} activit${widget.count == 1 ? 'y' : 'ies'} on ${widget.date.day}',
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: _isHovered
                    ? widget.colorScheme.primary.withValues(alpha: 0.6)
                    : widget.colorScheme.outline.withValues(alpha: 0.2),
                width: _isHovered ? 1.5 : 0.5,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: widget.colorScheme.primary.withValues(
                          alpha: 0.3,
                        ),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// Stat item for the legend
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
