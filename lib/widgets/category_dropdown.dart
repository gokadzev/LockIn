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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/features/categories/categories_provider.dart';

/// Reusable category dropdown used across Add/Edit dialogs.
class CategoryDropdown extends ConsumerWidget {
  const CategoryDropdown({
    required this.value,
    required this.onChanged,
    this.hint,
    super.key,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
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
      items: categories
          .map(
            (c) => DropdownMenuItem<String?>(
              value: c,
              child: Text(c, style: TextStyle(color: scheme.onSurface)),
            ),
          )
          .toList(),
    );
  }
}
