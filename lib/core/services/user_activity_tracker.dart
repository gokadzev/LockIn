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
import 'package:lockin/constants/hive_constants.dart';
import 'package:lockin/core/utils/hive_utils.dart';

class UserActivityTracker {
  static Future<void> markActive() async {
    final box =
        openBoxIfAvailable<int>(HiveBoxes.userActivity) ??
        await Hive.openBox<int>(HiveBoxes.userActivity);
    await box.put(HiveKeys.lastActive, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<bool> wasActiveWithin(Duration window) async {
    final box =
        openBoxIfAvailable<int>(HiveBoxes.userActivity) ??
        await Hive.openBox<int>(HiveBoxes.userActivity);
    final lastActive = box.get(HiveKeys.lastActive);
    if (lastActive == null) return false;
    final lastActiveTime = DateTime.fromMillisecondsSinceEpoch(lastActive);
    return DateTime.now().difference(lastActiveTime) <= window;
  }
}
