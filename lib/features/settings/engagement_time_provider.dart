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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/core/utils/hive_utils.dart';

final engagementTimeProvider =
    StateNotifierProvider<EngagementTimeNotifier, TimeOfDay>((ref) {
      return EngagementTimeNotifier();
    });

class EngagementTimeNotifier extends StateNotifier<TimeOfDay> {
  EngagementTimeNotifier() : super(_loadInitialTime());
  static const _boxName = 'settings';
  static const _key = 'engagementTime';

  static TimeOfDay _loadInitialTime() {
    final box = openBoxIfAvailable(_boxName);
    if (box != null && box.containsKey(_key)) {
      final timeMap = box.get(_key) as Map?;
      if (timeMap != null &&
          timeMap['hour'] != null &&
          timeMap['minute'] != null) {
        return TimeOfDay(hour: timeMap['hour'], minute: timeMap['minute']);
      }
    }
    return const TimeOfDay(hour: 9, minute: 0); // default
  }

  void setTime(TimeOfDay time) {
    final box = openBoxIfAvailable(_boxName);
    if (box != null) {
      box.put(_key, {'hour': time.hour, 'minute': time.minute});
      state = time;
    }
  }
}
