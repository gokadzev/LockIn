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

import 'package:hive_ce/hive.dart';

part 'habit_category.g.dart';

@HiveType(typeId: 20)
class HabitCategory extends HiveObject {
  HabitCategory({required this.name});
  @HiveField(0)
  String name;
}

/// Default categories for first run
List<String> defaultHabitCategories = [
  'Health',
  'Productivity',
  'Learning',
  'Wellness',
  'Fitness',
  'Mindfulness',
  'Finance',
  'General',
];
