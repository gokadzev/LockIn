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
  @HiveField(10)
  String? category;

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
    'category': category,
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
      ..fatigueScore = json['fatigueScore'] ?? 0
      ..category = json['category'];
    return s;
  }
}
