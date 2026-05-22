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
import 'package:lockin/core/models/goal.dart';
import 'package:lockin/core/utils/category_icon.dart';
import 'package:lockin/widgets/action_icon_button.dart';
import 'package:lockin/widgets/icon_badge.dart';
import 'package:lockin/widgets/lockin_card.dart';
import 'package:lockin/widgets/lockin_card_header.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.goal,
    required this.index,
    required this.isFinished,
    this.onDelete,
    this.onEdit,
    this.onMilestoneAdd,
    this.onMilestoneRemove,
    this.onFinish,
  });

  final Goal goal;
  final int index;
  final bool isFinished;
  final void Function(int)? onDelete;
  final void Function(int)? onEdit;
  final void Function(int)? onMilestoneAdd;
  final void Function(int)? onMilestoneRemove;
  final void Function(int)? onFinish;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mainColor = isFinished
        ? colorScheme.onSurfaceVariant
        : colorScheme.onSurface;
    final secondaryColor = isFinished
        ? colorScheme.onSurface.withValues(alpha: 0.6)
        : colorScheme.onSurfaceVariant;

    return LockinCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LockinCardHeader(
            leading: IconBadge(
              icon: categoryToIcon(goal.category),
              backgroundColor: colorScheme.secondaryContainer,
              color: colorScheme.onSecondaryContainer,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal.title,
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(height: 1.15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                ),
                if (goal.smart != null && goal.smart!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    goal.smart!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: secondaryColor,
                      height: 1.25,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
            actions: [
              ActionIconButton(
                icon: isFinished
                    ? Icons.cancel_outlined
                    : Icons.check_circle_outline,
                color: colorScheme.onSurface,
                tooltip: isFinished ? 'Finished' : 'Mark as finished',
                onPressed: (onFinish != null && !isFinished)
                    ? () => onFinish!(index)
                    : null,
              ),
              const SizedBox(width: 8),
              if (onEdit != null)
                ActionIconButton(
                  icon: Icons.edit_outlined,
                  color: colorScheme.onSurface,
                  tooltip: 'Edit',
                  onPressed: () => onEdit!(index),
                ),
              const SizedBox(width: 4),
              if (onDelete != null)
                ActionIconButton(
                  icon: Icons.delete_outline,
                  color: colorScheme.onSurfaceVariant,
                  tooltip: 'Delete',
                  onPressed: () => onDelete!(index),
                ),
            ],
          ),
          // Deadline section
          if (goal.deadline != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deadline: '
                    '${goal.deadline!.year}-'
                    '${goal.deadline!.month.toString().padLeft(2, '0')}-'
                    '${goal.deadline!.day.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: mainColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Builder(
                    builder: (context) {
                      final now = DateTime.now();
                      final deadline = goal.deadline!;
                      final daysLeft = deadline
                          .difference(DateTime(now.year, now.month, now.day))
                          .inDays;
                      String leftText;
                      Color textColor;
                      if (daysLeft > 0) {
                        leftText =
                            '$daysLeft day${daysLeft == 1 ? '' : 's'} left';
                        textColor = colorScheme.onSurfaceVariant;
                      } else if (daysLeft == 0) {
                        leftText = 'Due today';
                        textColor = colorScheme.onSurface.withValues(
                          alpha: 0.85,
                        );
                      } else {
                        leftText = 'Past due';
                        textColor = colorScheme.error;
                      }
                      return Text(
                        leftText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
          // Milestones
          _buildMilestoneRow(context),
        ],
      ),
    );
  }

  Widget _buildMilestoneRow(BuildContext context) {
    if (goal.milestones.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final completed = goal.milestones.where((m) => m.completed).length;
    final total = goal.milestones.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('Milestones:'),
            const Spacer(),
            // counter
            Text('$completed/$total'),
            const SizedBox(width: 8),
            if (onMilestoneAdd != null)
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GestureDetector(
                  onTap: () => onMilestoneAdd!(index),
                  child: Icon(
                    Icons.add,
                    size: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            if (onMilestoneRemove != null)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GestureDetector(
                  onTap: () => onMilestoneRemove!(index),
                  child: Icon(
                    Icons.remove,
                    size: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Slim progress indicator
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: total > 0 ? completed / total : 0,
            minHeight: 4,
            backgroundColor: colorScheme.onSurface.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: goal.milestones.map((milestone) {
            final isCompleted = milestone.completed;
            final bg = isCompleted
                ? colorScheme.onSurface
                : colorScheme.surfaceContainerHighest;
            final textColor = isCompleted
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isCompleted) ...[
                    Icon(Icons.check, size: 14, color: colorScheme.onPrimary),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      milestone.title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
