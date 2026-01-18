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

final dynamicColorEnabledProvider =
    StateNotifierProvider<DynamicColorEnabledNotifier, bool>((ref) {
      final box = Hive.box<dynamic>('app_settings');
      return DynamicColorEnabledNotifier(box);
    });

class DynamicColorEnabledNotifier extends StateNotifier<bool> {
  DynamicColorEnabledNotifier(this.box)
    : super(box.get('dynamicColorEnabled', defaultValue: true) as bool);

  final Box<dynamic> box;

  void toggle() {
    state = !state;
    box.put('dynamicColorEnabled', state);
  }

  void set(bool value) {
    state = value;
    box.put('dynamicColorEnabled', value);
  }
}
