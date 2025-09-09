class HabitSuggestion {
  const HabitSuggestion({
    required this.title,
    this.frequency = 'daily',
    this.category,
    this.description,
  });
  final String title;
  final String frequency;
  final String? category;
  final String? description;
}
