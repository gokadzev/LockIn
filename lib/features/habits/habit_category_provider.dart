import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:lockin/core/models/habit_category.dart';
import 'package:lockin/core/utils/box_crud_mixin.dart';
import 'package:lockin/core/utils/hive_utils.dart';
import 'package:lockin/features/habits/habit_provider.dart';

final habitCategoriesBoxProvider = Provider<Box<HabitCategory>?>(
  (ref) => openBoxIfAvailable<HabitCategory>('habit_categories'),
);

final habitCategoriesProvider =
    StateNotifierProvider<HabitCategoriesNotifier, List<HabitCategory>>((ref) {
      final box = ref.watch(habitCategoriesBoxProvider);
      return HabitCategoriesNotifier(box)..startWatchingBox();
    });

class HabitCategoriesNotifier extends StateNotifier<List<HabitCategory>>
    with BoxCrudMixin<HabitCategory> {
  HabitCategoriesNotifier(this.box) : super(box?.values.toList() ?? []);
  @override
  final Box<HabitCategory>? box;

  void addCategory(String name) {
    if (box == null) return;
    final category = HabitCategory(name: name);
    box!.add(category);
    state = box!.values.toList();
  }

  void editCategoryByKey(dynamic key, String newName) {
    if (box == null) return;
    final keys = box!.keys.toList();
    final index = keys.indexOf(key);
    if (index == -1) return;
    final category = box!.getAt(index);
    if (category != null) {
      category
        ..name = newName
        ..save();
      state = box!.values.toList();
    }
  }

  void deleteCategoryByKey(dynamic key, {WidgetRef? ref}) {
    if (box == null) return;
    final keys = box!.keys.toList();
    final index = keys.indexOf(key);
    if (index == -1) return;
    final deletedCategory = box!.getAt(index)?.name;
    deleteItem(index);
    state = box?.values.toList() ?? [];
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
