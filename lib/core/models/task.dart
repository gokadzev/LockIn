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
part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  Task copy() {
    return Task()
      ..title = title
      ..description = description
      ..priority = priority
      ..dueDate = dueDate
      ..tags = List<String>.from(tags)
      ..completed = completed
      ..linkedGoalId = linkedGoalId
      ..startTime = startTime
      ..completionTime = completionTime
      ..estimatedDuration = estimatedDuration
      ..actualDuration = actualDuration
      ..skipped = skipped
      ..rescheduled = rescheduled
      ..abandoned = abandoned;
  }

  @HiveField(0)
  late String title;
  @HiveField(1)
  String? description;
  @HiveField(2)
  int priority = 0;
  @HiveField(3)
  DateTime? dueDate;
  @HiveField(4)
  List<String> tags = [];
  @HiveField(5)
  bool completed = false;
  @HiveField(6)
  int? linkedGoalId;
  @HiveField(7)
  DateTime? startTime;
  @HiveField(8)
  DateTime? completionTime;
  @HiveField(9)
  int? estimatedDuration; // in minutes
  @HiveField(10)
  int? actualDuration; // in minutes
  @HiveField(11)
  bool skipped = false;
  @HiveField(12)
  bool rescheduled = false;
  @HiveField(13)
  bool abandoned = false;

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'priority': priority,
    'dueDate': dueDate?.toIso8601String(),
    'tags': tags,
    'completed': completed,
    'linkedGoalId': linkedGoalId,
    'startTime': startTime?.toIso8601String(),
    'completionTime': completionTime?.toIso8601String(),
    'estimatedDuration': estimatedDuration,
    'actualDuration': actualDuration,
    'skipped': skipped,
    'rescheduled': rescheduled,
    'abandoned': abandoned,
  };

  static Task fromJson(Map<String, dynamic> json) {
    final t = Task()
      ..title = json['title'] ?? ''
      ..description = json['description']
      ..priority = json['priority'] ?? 0
      ..dueDate = json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : null
      ..tags = (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? []
      ..completed = json['completed'] ?? false
      ..linkedGoalId = json['linkedGoalId']
      ..startTime = json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : null
      ..completionTime = json['completionTime'] != null
          ? DateTime.parse(json['completionTime'])
          : null
      ..estimatedDuration = json['estimatedDuration']
      ..actualDuration = json['actualDuration']
      ..skipped = json['skipped'] ?? false
      ..rescheduled = json['rescheduled'] ?? false
      ..abandoned = json['abandoned'] ?? false;
    return t;
  }
}
