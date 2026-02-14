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
import 'package:lockin/features/habits/habit_category_provider.dart';
import 'package:lockin/widgets/lockin_dialog.dart';

class CategoryManagerDialog extends ConsumerWidget {
  const CategoryManagerDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final categories = ref.watch(habitCategoriesProvider);
    final box = ref.watch(habitCategoriesBoxProvider);
    final notifier = ref.read(habitCategoriesProvider.notifier);
    return LockinDialog(
      title: const Text('Manage Categories'),
      content: SizedBox(
        width: 360,
        height: 360,
        child: ListView.separated(
          itemCount: categories.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (context, index) {
            final name = categories[index];
            final key = box?.keyAt(index);
            final controller = TextEditingController(text: name);
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty && key != null) {
                        notifier.editCategoryByKey(key, val.trim());
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: scheme.onSurfaceVariant),
                  onPressed: () {
                    if (key != null) {
                      notifier.deleteCategoryByKey(key);
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Add'),
          onPressed: () async {
            final controller = TextEditingController();
            final result = await showDialog<String>(
              context: context,
              builder: (context) => LockinDialog(
                title: const Text('New Category'),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: 'Category name'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, controller.text),
                    child: const Text('Add'),
                  ),
                ],
              ),
            );
            if (result != null && result.trim().isNotEmpty) {
              notifier.addCategory(result.trim());
            }
          },
        ),
      ],
    );
  }
}
