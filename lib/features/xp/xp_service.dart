import 'package:hive_ce/hive.dart';
import 'package:lockin/features/xp/xp_models.dart';

class XPService {
  XPService(this.profile);
  XPProfile profile;

  int xpForLevel(int level) => 100 * (level - 1);

  void addXP(int amount) {
    final newXP = (profile.xp + amount).clamp(0, 1000000); // Arbitrary max
    var newLevel = profile.level;
    final tempXP = newXP;
    while (tempXP >= xpForLevel(newLevel + 1)) {
      newLevel++;
    }
    // Unlock all rewards for levels <= newLevel
    final newUnlocked = List<Reward>.from(profile.unlockedRewards);
    for (final reward in XPData.rewards.where(
      (r) => r.unlockLevel <= newLevel,
    )) {
      if (!newUnlocked.any((ur) => ur.id == reward.id)) {
        newUnlocked.add(reward);
      }
    }
    profile = XPProfile(
      xp: newXP,
      level: newLevel,
      unlockedRewards: newUnlocked,
      streakSaverAvailable: profile.streakSaverAvailable,
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
