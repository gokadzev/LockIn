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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/core/utils/hive_utils.dart';
import 'package:lockin/features/xp/xp_models.dart';
import 'package:lockin/features/xp/xp_service.dart';

class XPNotifier extends StateNotifier<XPProfile> {
  XPNotifier(this.service) : super(service.profile);
  final XPService service;

  XPProfile get profile => state;
  int get xp => state.xp;
  int get level => state.level;
  List<Reward> get unlockedRewards => state.unlockedRewards;

  final box = openBoxIfAvailable<XPProfile>('xp_profile');

  void addXP(int amount) {
    try {
      service.addXP(amount);
      state = service.profile;
      box?.put('profile', state);
    } catch (e, stackTrace) {
      debugPrint('Error adding XP: $e');
      debugPrint('StackTrace: $stackTrace');
      // State remains unchanged on error
    }
  }

  Future<void> consumeStreakSaver(int xpLoss) async {
    service.addXP(-xpLoss);
    final updatedProfile = XPProfile(
      xp: service.profile.xp,
      level: service.profile.level,
      unlockedRewards: service.profile.unlockedRewards,
    );
    service.profile = updatedProfile;
    state = updatedProfile;
    if (box != null) await box?.put('profile', updatedProfile);
  }

  static Future<XPNotifier> create() async {
    final box = openBoxIfAvailable<XPProfile>('xp_profile');

    final profile =
        box?.get('profile') ??
        const XPProfile(xp: 0, level: 1, unlockedRewards: []);
    return XPNotifier(XPService(profile));
  }
}

final xpNotifierProvider = FutureProvider<XPNotifier>((ref) async {
  return XPNotifier.create();
});
