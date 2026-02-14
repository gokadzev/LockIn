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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:lockin/core/utils/box_crud_mixin.dart';
import 'package:lockin/core/utils/hive_utils.dart';
import 'package:lockin/features/habits/habit_provider.dart';

final habitCategoriesBoxProvider = Provider<Box<String>?>(
  (ref) => openBoxIfAvailable<String>('habit_categories'),
);

final habitCategoriesProvider =
    NotifierProvider<HabitCategoriesNotifier, List<String>>(
      HabitCategoriesNotifier.new,
    );

class HabitCategoriesNotifier extends Notifier<List<String>>
    with BoxCrudMixin<String> {
  Box<String>? _box;

  @override
  Box<String>? get box => _box;

  @override
  List<String> build() {
    stopWatchingBox();
    _box = ref.watch(habitCategoriesBoxProvider);
    startWatchingBox();
    ref.onDispose(stopWatchingBox);
    return _box?.values.toList() ?? [];
  }

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

  void deleteCategoryByKey(dynamic key) {
    if (box == null) return;
    if (!box!.containsKey(key)) return;
    final deletedCategory = box!.get(key);
    box!.delete(key);
    state = box!.values.toList();
    if (deletedCategory != null) {
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
}
