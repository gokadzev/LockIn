import 'package:hive_ce/hive.dart';

part 'xp_models.g.dart';

@HiveType(typeId: 100)
class XPProfile {
  const XPProfile({
    required this.xp,
    required this.level,
    required this.unlockedRewards,
    this.streakSaverAvailable = false,
  });
  @HiveField(0)
  final int xp;
  @HiveField(1)
  final int level;
  @HiveField(2)
  final List<Reward> unlockedRewards;
  @HiveField(3)
  final bool streakSaverAvailable;
}

@HiveType(typeId: 101)
class Reward {
  const Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.unlockLevel,
    required this.type,
  });
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final int unlockLevel;
  @HiveField(4)
  final RewardType type;
}

@HiveType(typeId: 102)
enum RewardType {
  @HiveField(0)
  theme,
  @HiveField(1)
  avatar,
  @HiveField(2)
  badge,
  @HiveField(3)
  feature,
  @HiveField(4)
  virtualItem,
}
