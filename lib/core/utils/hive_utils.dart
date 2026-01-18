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

import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

/// Safely return an opened Hive box or null if not available.
Box<T>? openBoxIfAvailable<T>(String name) {
  try {
    return Hive.isBoxOpen(name) ? Hive.box<T>(name) : null;
  } catch (e, st) {
    debugPrint('openBoxIfAvailable: failed to get box "$name": $e');
    debugPrint('$st');
    return null;
  }
}
