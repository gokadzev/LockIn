import 'package:hive_ce/hive.dart';
part 'habit.g.dart';

@HiveType(typeId: 1)
class Habit extends HiveObject {
  /// Default categories for habits
  static List<String> defaultCategories = [
    'Health',
    'Productivity',
    'Learning',
    'Wellness',
    'Fitness',
    'Mindfulness',
    'Finance',
    'General',
  ];
  Habit copy() {
    return Habit()
      ..title = title
      ..frequency = frequency
      ..cue = cue
      ..reward = reward
      ..streak = streak
      ..history = List<DateTime>.from(history)
      ..skipped = skipped
      ..rescheduled = rescheduled
      ..abandoned = abandoned
      ..fatigueScore = fatigueScore
      ..category = category;
  }

  @HiveField(0)
  late String title;
  @HiveField(1)
  String frequency = 'daily';
  @HiveField(2)
  String? cue;
  @HiveField(3)
  String? reward;
  @HiveField(4)
  int streak = 0;
  @HiveField(5)
  List<DateTime> history = [];
  @HiveField(6)
  bool skipped = false;
  @HiveField(7)
  bool rescheduled = false;
  @HiveField(8)
  bool abandoned = false;
  @HiveField(9)
  int fatigueScore = 0; // 0-100
  @HiveField(10)
  String category = 'General';

  Map<String, dynamic> toJson() => {
    'title': title,
    'frequency': frequency,
    'cue': cue,
    'reward': reward,
    'streak': streak,
    'history': history.map((d) => d.toIso8601String()).toList(),
    'skipped': skipped,
    'rescheduled': rescheduled,
    'abandoned': abandoned,
    'fatigueScore': fatigueScore,
    'category': category,
  };

  static Habit fromJson(Map<String, dynamic> json) {
    final h = Habit()
      ..title = json['title'] ?? ''
      ..frequency = json['frequency'] ?? 'daily'
      ..cue = json['cue']
      ..reward = json['reward']
      ..streak = json['streak'] ?? 0
      ..history =
          (json['history'] as List?)?.map((d) => DateTime.parse(d)).toList() ??
          []
      ..skipped = json['skipped'] ?? false
      ..rescheduled = json['rescheduled'] ?? false
      ..abandoned = json['abandoned'] ?? false
      ..fatigueScore = json['fatigueScore'] ?? 0
      ..category = json['category'] ?? 'General';
    return h;
  }
}
