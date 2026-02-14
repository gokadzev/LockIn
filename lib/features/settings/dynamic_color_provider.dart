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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:lockin/constants/hive_constants.dart';

final dynamicColorEnabledProvider =
    NotifierProvider<DynamicColorEnabledNotifier, bool>(
      DynamicColorEnabledNotifier.new,
    );

class DynamicColorEnabledNotifier extends Notifier<bool> {
  late Box<dynamic> box;

  @override
  bool build() {
    box = Hive.box<dynamic>(HiveBoxes.appSettings);
    return box.get(HiveKeys.dynamicColorEnabled, defaultValue: true) as bool;
  }

  void toggle() {
    state = !state;
    box.put(HiveKeys.dynamicColorEnabled, state);
  }

  void set(bool value) {
    state = value;
    box.put(HiveKeys.dynamicColorEnabled, value);
  }
}
