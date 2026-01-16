import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:lockin/core/utils/box_crud_mixin.dart';
import 'package:lockin/core/utils/hive_utils.dart';
import 'package:lockin/features/habits/habit_provider.dart';

final habitCategoriesBoxProvider = Provider<Box<String>?>(
  (ref) => openBoxIfAvailable<String>('habit_categories'),
);

final habitCategoriesProvider =
    StateNotifierProvider<HabitCategoriesNotifier, List<String>>((ref) {
      final box = ref.watch(habitCategoriesBoxProvider);
      return HabitCategoriesNotifier(box)..startWatchingBox();
    });

class HabitCategoriesNotifier extends StateNotifier<List<String>>
    with BoxCrudMixin<String> {
  HabitCategoriesNotifier(this.box) : super(box?.values.toList() ?? []);
  @override
  final Box<String>? box;

  void addCategory(String name) {
    if (box == null) return;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    box!.add(trimmed);
    state = box!.values.toList();
  }

  void editCategoryByKey(dynamic key, String newName) {
    if (box == null) return;
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;
    if (!box!.containsKey(key)) return;
    box!.put(key, trimmed);
    state = box!.values.toList();
  }

  void deleteCategoryByKey(dynamic key, {WidgetRef? ref}) {
    if (box == null) return;
    if (!box!.containsKey(key)) return;
    final deletedCategory = box!.get(key);
    box!.delete(key);
    state = box!.values.toList();
    if (deletedCategory != null && ref != null) {
      final habitsBox = ref.read(habitsBoxProvider);
      if (habitsBox != null) {
        for (var i = 0; i < habitsBox.length; i++) {
          final habit = habitsBox.getAt(i);
          if (habit != null && habit.category == deletedCategory) {
            habit
              ..category = 'General'
              ..save();
          }
        }
        ref.read(habitsListProvider.notifier).state = habitsBox.values.toList();
      }
    }
  }

  @override
  void dispose() {
    stopWatchingBox();
    super.dispose();
  }
}
