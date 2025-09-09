import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/features/habits/habit_category_provider.dart';
import 'package:lockin/themes/app_theme.dart';
import 'package:lockin/widgets/lockin_dialog.dart';

class CategoryManagerDialog extends ConsumerWidget {
  const CategoryManagerDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(habitCategoriesProvider);
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
            final cat = categories[index];
            final controller = TextEditingController(text: cat.name);
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
                      if (val.trim().isNotEmpty) {
                        notifier.editCategoryByKey(cat.key, val.trim());
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: scheme.onSurfaceVariant),
                  onPressed: () {
                    notifier.deleteCategoryByKey(cat.key, ref: ref);
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
