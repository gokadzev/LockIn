import 'package:flutter/material.dart';
import 'package:lockin/core/models/habit.dart';
import 'package:lockin/core/utils/category_icon.dart';
import 'package:lockin/features/habits/habits_home.dart';
import 'package:lockin/themes/app_theme.dart';
import 'package:lockin/widgets/action_icon_button.dart';
import 'package:lockin/widgets/icon_badge.dart';
import 'package:lockin/widgets/lockin_card.dart';

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
    final streak = habit.streak;
    final lastDone = habit.history.isNotEmpty
        ? habit.history.reduce((a, b) => a.isAfter(b) ? a : b)
        : null;

    return LockinCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconBadge(icon: categoryToIcon(habit.category)),
              ),
              Expanded(
                child: Text(
                  habit.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    height: 1.15,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ActionIconButton(
                    icon: Icons.check_circle_outline,
                    color: isDoneToday(habit, lastDone)
                        ? scheme.onSurfaceVariant
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
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Frequency: ${habit.frequency.capitalize()}${habit.frequency == 'custom' && habit.cue != null ? ' (${_weekdaysString(habit.cue!)})' : ''}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            'Streak: $streak',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (lastDone != null) ...[
            const SizedBox(height: 6),
            Text(
              'Last done: ${lastDone.day}/${lastDone.month}/${lastDone.year}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
      .where((i) => i >= 0 && i < 7);
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days.map((i) => names[i]).join(', ');
}
