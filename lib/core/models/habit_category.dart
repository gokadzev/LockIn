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
