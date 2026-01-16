import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/features/habits/habit_category_provider.dart';

/// Built-in default categories shown first.
const List<String> _builtInCategories = [
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
