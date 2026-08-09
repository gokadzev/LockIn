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
import 'package:lockin/constants/hive_constants.dart';
import 'package:lockin/core/utils/box_crud_mixin.dart';
import 'package:lockin/core/utils/hive_utils.dart';
import 'package:lockin/features/habits/habit_provider.dart';

final habitCategoriesBoxProvider = Provider<Box<String>?>(
  (ref) => openBoxIfAvailable<String>(HiveBoxes.habitCategories),
);

final habitCategoriesProvider =
    NotifierProvider<HabitCategoriesNotifier, List<String>>(
      HabitCategoriesNotifier.new,
    );

class HabitCategoriesNotifier extends BoxCrudNotifier<String> {
  @override
  String get boxName => HiveBoxes.habitCategories;

  Future<void> addCategory(String name) async {
    if (box == null) return;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await box!.add(trimmed);
    state = box!.values.toList();
  }

  Future<void> editCategoryByKey(dynamic key, String newName) async {
    if (box == null) return;
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;
    if (!box!.containsKey(key)) return;
    await box!.put(key, trimmed);
    state = box!.values.toList();
  }

  Future<void> deleteCategoryByKey(dynamic key) async {
    if (box == null) return;
    if (!box!.containsKey(key)) return;
    final deletedCategory = box!.get(key);
    await box!.delete(key);
    state = box!.values.toList();
    if (deletedCategory != null) {
      final habitsBox = ref.read(habitsBoxProvider);
      if (habitsBox != null) {
        for (var i = 0; i < habitsBox.length; i++) {
          final habit = habitsBox.getAt(i);
          if (habit != null && habit.category == deletedCategory) {
            habit.category = 'General';
            await habit.save();
          }
        }
        ref.read(habitsListProvider.notifier).state = habitsBox.values.toList();
      }
    }
  }
}
