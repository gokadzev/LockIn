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
part 'goal.g.dart';

@HiveType(typeId: 10)
class Milestone {
  Milestone(this.title, {this.completed = false});
  @HiveField(0)
  String title;
  @HiveField(1)
  bool completed;

  Map<String, dynamic> toJson() => {'title': title, 'completed': completed};

  static Milestone fromJson(Map<String, dynamic> json) =>
      Milestone(json['title'] ?? '', completed: json['completed'] ?? false);
}

@HiveType(typeId: 2)
class Goal extends HiveObject {
  Goal copy() {
    return Goal()
      ..title = title
      ..smart = smart
      ..milestones = milestones
          .map((m) => Milestone(m.title, completed: m.completed))
          .toList()
      ..progress = progress
      ..linkedTasks = List<int>.from(linkedTasks)
      ..deadline = deadline
      ..category = category;
  }

  @HiveField(0)
  late String title;
  @HiveField(1)
  String? smart;
  @HiveField(2)
  List<Milestone> milestones = [];
  @HiveField(3)
  double progress = 0;
  @HiveField(4)
  List<int> linkedTasks = [];
  @HiveField(5)
  DateTime? deadline;
  @HiveField(6)
  String? category;

  double get milestoneProgress => milestones.isEmpty
      ? 0.0
      : milestones.where((m) => m.completed).length / milestones.length;

  Map<String, dynamic> toJson() => {
    'title': title,
    'smart': smart,
    'milestones': milestones.map((m) => m.toJson()).toList(),
    'progress': progress,
    'linkedTasks': linkedTasks,
    'deadline': deadline?.toIso8601String(),
    'category': category,
  };

  static Goal fromJson(Map<String, dynamic> json) {
    final g = Goal()
      ..title = json['title'] ?? ''
      ..smart = json['smart']
      ..milestones =
          (json['milestones'] as List?)
              ?.map((m) => Milestone.fromJson(m))
              .toList() ??
          []
      ..progress = (json['progress'] ?? 0.0).toDouble()
      ..linkedTasks =
          (json['linkedTasks'] as List?)
              ?.map((e) => int.tryParse(e.toString()))
              .whereType<int>()
              .toList() ??
          []
      ..deadline = json['deadline'] != null
          ? DateTime.tryParse(json['deadline'])
          : null
      ..category = json['category'] as String?;
    return g;
  }
}
