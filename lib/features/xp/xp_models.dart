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
