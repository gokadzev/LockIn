import 'package:hive_ce/hive.dart';
part 'session.g.dart';

@HiveType(typeId: 3)
class Session extends HiveObject {
  @HiveField(0)
  int? taskId;
  @HiveField(1)
  late DateTime startTime;
  @HiveField(2)
  DateTime? endTime;
  @HiveField(3)
  int duration = 0;
  @HiveField(4)
  int? rating;
  @HiveField(5)
  int pomodoroCount = 0;
  @HiveField(6)
  int breakCount = 0;
  @HiveField(7)
  List<int> consecutiveTaskIds = [];
  @HiveField(8)
  int flowSessionDuration = 0; // in minutes
  @HiveField(9)
  int fatigueScore = 0; // 0-100

  Map<String, dynamic> toJson() => {
    'taskId': taskId,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'duration': duration,
    'rating': rating,
    'pomodoroCount': pomodoroCount,
    'breakCount': breakCount,
    'consecutiveTaskIds': consecutiveTaskIds,
    'flowSessionDuration': flowSessionDuration,
    'fatigueScore': fatigueScore,
  };

  static Session fromJson(Map<String, dynamic> json) {
    final s = Session()
      ..taskId = json['taskId']
      ..startTime = DateTime.parse(json['startTime'])
      ..endTime = json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : null
      ..duration = json['duration'] ?? 0
      ..rating = json['rating']
      ..pomodoroCount = json['pomodoroCount'] ?? 0
      ..breakCount = json['breakCount'] ?? 0
      ..consecutiveTaskIds =
          (json['consecutiveTaskIds'] as List?)
              ?.map((e) => int.parse(e.toString()))
              .toList() ??
          []
      ..flowSessionDuration = json['flowSessionDuration'] ?? 0
      ..fatigueScore = json['fatigueScore'] ?? 0;
    return s;
  }
}
