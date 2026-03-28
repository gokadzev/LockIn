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
import 'package:lockin/features/xp/xp_models.dart';

class XPService {
  XPService(this.profile);
  XPProfile profile;

  int xpForLevel(int level) => 100 * (level - 1);

  void addXP(int amount) {
    final newXP = (profile.xp + amount).clamp(0, 1000000); // Arbitrary max
    var newLevel = 1;
    while (newXP >= xpForLevel(newLevel + 1)) {
      newLevel++;
    }
    var newUnlocked = List<Reward>.from(profile.unlockedRewards);
    var streakSaverAvailable = profile.streakSaverAvailable;

    if (newLevel > profile.level) {
      // Level-up: unlock any newly eligible rewards.
      for (final reward in XPData.rewards.where(
        (r) => r.unlockLevel <= newLevel,
      )) {
        if (!newUnlocked.any((ur) => ur.id == reward.id)) {
          newUnlocked.add(reward);
          if (reward.id == 'streak_saver') {
            streakSaverAvailable = true;
          }
        }
      }
    } else if (newLevel < profile.level) {
      // Level-down: revoke rewards that require a level above the new level.
      newUnlocked = newUnlocked
          .where((ur) {
            final def = XPData.rewards.where((r) => r.id == ur.id).firstOrNull;
            return def == null || def.unlockLevel <= newLevel;
          })
          .toList();
      // Reset streak saver if it was revoked.
      final hasStreakSaver = newUnlocked.any((ur) => ur.id == 'streak_saver');
      if (!hasStreakSaver) {
        streakSaverAvailable = false;
      }
    }

    profile = XPProfile(
      xp: newXP,
      level: newLevel,
      unlockedRewards: newUnlocked,
      streakSaverAvailable: streakSaverAvailable,
    );
  }

  // Hive persistence helpers
  Future<void> saveToHive(Box<XPProfile>? box) async {
    if (box == null) return;
    await box.put('profile', profile);
  }

  static Future<XPProfile> loadFromHive(Box<XPProfile>? box) async {
    if (box == null) {
      return const XPProfile(xp: 0, level: 1, unlockedRewards: []);
    }
    return box.get('profile') ??
        const XPProfile(xp: 0, level: 1, unlockedRewards: []);
  }
}

class XPData {
  static final List<Reward> rewards = [
    const Reward(
      id: 'streak_saver',
      name: 'Streak Saver',
      description:
          'Save a habit streak if you miss up to 3 days. One use per unlock.',
      unlockLevel: 5,
      type: RewardType.feature,
    ),
    const Reward(
      id: 'advanced_stats',
      name: 'Advanced Stats',
      description: 'Unlock advanced statistics and insights.',
      unlockLevel: 8,
      type: RewardType.feature,
    ),
  ];
}
