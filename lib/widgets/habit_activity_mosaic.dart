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

class HabitActivityMosaic extends StatefulWidget {
  const HabitActivityMosaic({required this.history, this.onTileTap, super.key});

  final List<DateTime> history;
  final void Function(DateTime date)? onTileTap;

  @override
  State<HabitActivityMosaic> createState() => _HabitActivityMosaicState();
}

class _HabitActivityMosaicState extends State<HabitActivityMosaic> {
  late DateTime _currentMonth;
  late Set<DateTime> _completedDates;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _updateCompletedDates(widget.history);
  }

  void _previousMonth() {
    var month = _currentMonth.month - 1;
    var year = _currentMonth.year;
    if (month < 1) {
      month = 12;
      year--;
    }
    setState(() {
      _currentMonth = DateTime(year, month);
    });
  }

  void _nextMonth() {
    var month = _currentMonth.month + 1;
    var year = _currentMonth.year;
    if (month > 12) {
      month = 1;
      year++;
    }
    setState(() {
      _currentMonth = DateTime(year, month);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();

    final lastDay = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;
    final firstDayWeekday = DateTime(
      _currentMonth.year,
      _currentMonth.month,
    ).weekday;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.chevron_left),
                onPressed: _previousMonth,
                tooltip: 'Previous month',
              ),
            ),
            SizedBox(
              width: 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getMonthName(_currentMonth.month),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    _currentMonth.year.toString(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextMonth,
                tooltip: 'Next month',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
              .map(
                (day) => SizedBox(
                  width: 40,
                  child: Text(
                    day,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 4),
        ..._buildCalendarRows(lastDay, firstDayWeekday, now),
      ],
    );
  }

  List<Widget> _buildCalendarRows(
    int lastDay,
    int firstDayWeekday,
    DateTime now,
  ) {
    final rows = <Widget>[];
    final totalCells = firstDayWeekday - 1 + lastDay;
    final weeksCount = (totalCells / 7).ceil();

    for (var weekIndex = 0; weekIndex < weeksCount; weekIndex++) {
      final weekStart = weekIndex * 7;
      final cells = <Widget>[];

      for (var dayIndex = 0; dayIndex < 7; dayIndex++) {
        final cellIndex = weekStart + dayIndex;
        final dayNumber = cellIndex - (firstDayWeekday - 1) + 1;

        if (dayNumber < 1 || dayNumber > lastDay) {
          cells.add(const SizedBox(width: 40, height: 40));
        } else {
          final date = DateTime(
            _currentMonth.year,
            _currentMonth.month,
            dayNumber,
          );
          final isCompleted = _completedDates.contains(date);
          final isToday =
              date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;

          cells.add(
            _DayTile(
              dayNumber: dayNumber,
              isCompleted: isCompleted,
              isToday: isToday,
              date: date,
              onTap: () => widget.onTileTap?.call(date),
            ),
          );
        }
      }

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: cells,
          ),
        ),
      );
    }

    return rows;
  }

  @override
  void didUpdateWidget(covariant HabitActivityMosaic oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newSet = widget.history
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
    if (newSet.length != _completedDates.length ||
        !newSet.containsAll(_completedDates)) {
      setState(() {
        _completedDates = newSet;
      });
    }
  }

  void _updateCompletedDates(List<DateTime> history) {
    _completedDates = history
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.dayNumber,
    required this.isCompleted,
    required this.isToday,
    required this.date,
    required this.onTap,
  });

  final int dayNumber;
  final bool isCompleted;
  final bool isToday;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: isCompleted
                ? Border.all(color: scheme.primary, width: 2)
                : isToday
                ? Border.all(color: scheme.outline)
                : null,
          ),
          child: Center(
            child: Text(
              dayNumber.toString(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
