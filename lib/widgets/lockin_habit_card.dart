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
import 'package:lockin/core/models/habit.dart';
import 'package:lockin/core/utils/category_icon.dart';
import 'package:lockin/features/habits/habits_home.dart';
import 'package:lockin/widgets/action_icon_button.dart';
import 'package:lockin/widgets/habit_activity_mosaic.dart';
import 'package:lockin/widgets/icon_badge.dart';
import 'package:lockin/widgets/lockin_card.dart';
import 'package:lockin/widgets/lockin_card_header.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({
    required this.habit,
    required this.onMarkDone,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });
  final Habit habit;
  final VoidCallback onMarkDone;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final streak = habit.streak;
    final lastDone = habit.history.isNotEmpty
        ? habit.history.reduce((a, b) => a.isAfter(b) ? a : b)
        : null;

    return LockinCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LockinCardHeader(
            leading: IconBadge(
              icon: categoryToIcon(habit.category),
              backgroundColor: scheme.secondaryContainer,
              color: scheme.onSecondaryContainer,
            ),
            title: Text(
              habit.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                height: 1.15,
                letterSpacing: 0.1,
              ),
            ),
            actions: [
              ActionIconButton(
                icon: Icons.check_circle_outline,
                color: isDoneToday(habit, lastDone)
                    ? scheme.onSurface.withValues(alpha: 0.38)
                    : scheme.onSurface,
                tooltip: 'Mark as done',
                onPressed: isDoneToday(habit, lastDone) ? null : onMarkDone,
              ),
              const SizedBox(width: 8),
              ActionIconButton(
                icon: Icons.edit_outlined,
                color: scheme.onSurface,
                tooltip: 'Edit',
                onPressed: onEdit,
              ),
              const SizedBox(width: 4),
              ActionIconButton(
                icon: Icons.delete_outline,
                color: scheme.onSurfaceVariant,
                tooltip: 'Delete',
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Streak',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: scheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$streak day${streak != 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              if (lastDone != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Last Completed',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${lastDone.day}/${lastDone.month}/${lastDone.year}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: scheme.outlineVariant),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.repeat, color: scheme.onSurfaceVariant, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Frequency: ${habit.frequency.capitalize()}${habit.frequency == 'custom' && habit.cue != null ? ' (${_weekdaysString(habit.cue!)})' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          HabitActivityMosaic(history: habit.history),
        ],
      ),
    );
  }
}

bool isDoneToday(Habit habit, DateTime? lastDone) {
  final now = DateTime.now();
  return habit.history.any(
    (d) => d.year == now.year && d.month == now.month && d.day == now.day,
  );
}

String _weekdaysString(String cue) {
  final days = cue
      .split(',')
      .map((e) => int.tryParse(e))
      .where((e) => e != null)
      .cast<int>()
      .map((i) {
        if (i >= 1 && i <= 7) return i - 1;
        if (i >= 0 && i < 7) return i;
        return null;
      })
      .whereType<int>()
      .where((i) => i >= 0 && i < 7);
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days.map((i) => names[i]).join(', ');
}
