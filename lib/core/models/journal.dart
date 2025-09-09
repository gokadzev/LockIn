import 'package:hive_ce/hive.dart';
part 'journal.g.dart';

@HiveType(typeId: 4)
class Journal extends HiveObject {
  @HiveField(0)
  late DateTime date;
  @HiveField(1)
  int mood = 0;
  @HiveField(2)
  List<String> prompts = [];
  @HiveField(3)
  String? entry;

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'mood': mood,
    'prompts': prompts,
    'entry': entry,
  };

  static Journal fromJson(Map<String, dynamic> json) {
    final j = Journal()
      ..date = DateTime.parse(json['date'])
      ..mood = json['mood'] ?? 0
      ..prompts =
          (json['prompts'] as List?)?.map((e) => e.toString()).toList() ?? []
      ..entry = json['entry'];
    return j;
  }
}
