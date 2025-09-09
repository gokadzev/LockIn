import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/features/categories/categories_provider.dart';
import 'package:lockin/themes/app_theme.dart';

/// Reusable category dropdown used across Add/Edit dialogs.
class CategoryDropdown extends ConsumerWidget {
  const CategoryDropdown({
    required this.value,
    required this.onChanged,
    this.includeNone = true,
    this.hint,
    super.key,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final bool includeNone;
  final String? hint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    return DropdownButtonFormField<String?>(
      initialValue: value,
      isExpanded: true,
      borderRadius: BorderRadius.circular(16),
      decoration: InputDecoration(
        labelText: hint ?? 'Category',
        filled: true,
        fillColor: scheme.onSurface.withValues(alpha: 0.04),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: scheme.onSurface.withValues(alpha: 0.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.onSurface),
        ),
      ),
      dropdownColor: scheme.surfaceContainerHighest,
      style: TextStyle(color: scheme.onSurface),
      onChanged: onChanged,
      items: [
        if (includeNone)
          DropdownMenuItem<String?>(
            child: Text(
              'None',
              style: TextStyle(color: scheme.onSurface.withValues(alpha: .75)),
            ),
          ),
        ...categories.map(
          (c) => DropdownMenuItem<String?>(
            value: c,
            child: Text(c, style: TextStyle(color: scheme.onSurface)),
          ),
        ),
      ],
    );
  }
}
