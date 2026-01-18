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
