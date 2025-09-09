import 'package:flutter/material.dart';
import 'package:lockin/constants/app_values.dart';
import 'package:lockin/themes/app_theme.dart';

/// Utility class for handling task priority related operations
class TaskPriorityUtils {
  /// Build priority choice chips for task priority selection
  static List<Widget> buildPriorityChips({
    required int selectedPriority,
    required Function(int) onPrioritySelected,
  }) {
    return AppValues.taskPriorities.entries.map((e) {
      final selected = selectedPriority == e.key;
      final labelColor = selected ? scheme.onPrimary : scheme.onSurface;
      final selectedColor = selected
          ? scheme.primary
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
          backgroundColor: bgColor,
          shape: StadiumBorder(
            side: BorderSide(
              color: selected ? scheme.onPrimary : Colors.transparent,
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
    final scheme = Theme.of(context).colorScheme;
    switch (priority) {
      case 3:
        return scheme.primary;
      case 2:
        return scheme.surfaceContainerHighest;
      case 1:
      default:
        return scheme.surface;
    }
  }

  /// Build priority container widget (theme-aware)
  static Widget buildPriorityContainer(BuildContext context, int priority) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        getPriorityText(priority),
        style: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
