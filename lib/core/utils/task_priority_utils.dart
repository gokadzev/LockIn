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
import 'package:lockin/constants/app_values.dart';

/// Utility class for handling task priority related operations
class TaskPriorityUtils {
  /// Build priority choice chips for task priority selection
  static List<Widget> buildPriorityChips({
    required int selectedPriority,
    required Function(int) onPrioritySelected,
    required BuildContext context,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return AppValues.taskPriorities.entries.map((e) {
      final selected = selectedPriority == e.key;
      final indicator = getPriorityColor(context, e.key);
      final labelColor = selected ? Colors.white : scheme.onSurface;
      final selectedColor = selected
          ? indicator
          : scheme.surfaceContainerHighest;
      final bgColor = scheme.surfaceContainerHighest;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: ChoiceChip(
          label: Text(
            e.value,
            style: TextStyle(color: labelColor, fontWeight: FontWeight.bold),
          ),
          selected: selected,
          selectedColor: selectedColor,
          checkmarkColor: labelColor,
          backgroundColor: bgColor,
          shape: StadiumBorder(
            side: BorderSide(
              color: selected ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
          onSelected: (_) => onPrioritySelected(e.key),
        ),
      );
    }).toList();
  }

  /// Get priority text from priority value
  static String getPriorityText(int priority) {
    return AppValues.taskPriorities[priority] ?? 'Unknown';
  }

  /// Get priority color from priority value
  static Color getPriorityColor(BuildContext context, int priority) {
    switch (priority) {
      case 3:
        return const Color(0xFFFF6B6B); // accent red
      case 2:
        return const Color(0xFFF4B400); // accent amber
      case 1:
      default:
        return const Color(0xFF06D6A0); // accent teal
    }
  }

  /// Build priority container widget (theme-aware)
  static Widget buildPriorityContainer(BuildContext context, int priority) {
    final scheme = Theme.of(context).colorScheme;
    final indicator = getPriorityColor(context, priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: indicator.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: indicator, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            getPriorityText(priority),
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
