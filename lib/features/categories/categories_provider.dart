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
import 'package:lockin/features/habits/habit_category_provider.dart';

/// Built-in default categories shown first.
const List<String> _builtInCategories = [
  'General',
  'Health',
  'Productivity',
  'Learning',
  'Wellness',
  'Fitness',
  'Mindfulness',
  'Finance',
  'Planning',
  'Career',
  'Social',
  'Personal',
];

/// Provides a merged list of built-in + user-defined habit categories.
/// Built-ins appear first; user categories appended (case-insensitive de-dup).
final categoriesProvider = Provider<List<String>>((ref) {
  final userCats = ref.watch(habitCategoriesProvider);
  final result = <String>[..._builtInCategories];
  for (final nameRaw in userCats) {
    final name = nameRaw.trim();
    if (name.isEmpty) continue;
    final exists = result.any((r) => r.toLowerCase() == name.toLowerCase());
    if (!exists) result.add(name);
  }
  return result;
});
