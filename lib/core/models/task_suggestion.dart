class TaskSuggestion {
  const TaskSuggestion({
    required this.title,
    this.category,
    this.description,
    this.priority = 2,
  });
  final String title;
  final String? category;
  final String? description;
  final int priority;
}
