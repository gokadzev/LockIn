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
import 'package:lockin/constants/hive_constants.dart';
import 'package:lockin/core/utils/hive_utils.dart';

final engagementTimeProvider =
    NotifierProvider<EngagementTimeNotifier, TimeOfDay>(
      EngagementTimeNotifier.new,
    );

class EngagementTimeNotifier extends Notifier<TimeOfDay> {
  @override
  TimeOfDay build() => _loadInitialTime();

  static TimeOfDay _loadInitialTime() {
    final box = openBoxIfAvailable(HiveBoxes.settings);
    if (box != null && box.containsKey(HiveKeys.engagementTime)) {
      final timeMap = box.get(HiveKeys.engagementTime) as Map?;
      if (timeMap != null &&
          timeMap['hour'] != null &&
          timeMap['minute'] != null) {
        return TimeOfDay(hour: timeMap['hour'], minute: timeMap['minute']);
      }
    }
    return const TimeOfDay(hour: 9, minute: 0); // default
  }

  void setTime(TimeOfDay time) {
    final box = openBoxIfAvailable(HiveBoxes.settings);
    if (box != null) {
      box.put(HiveKeys.engagementTime, {
        'hour': time.hour,
        'minute': time.minute,
      });
      state = time;
    }
  }
}
