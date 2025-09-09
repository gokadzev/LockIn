// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xp_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class XPProfileAdapter extends TypeAdapter<XPProfile> {
  @override
  final typeId = 100;

  @override
  XPProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return XPProfile(
      xp: (fields[0] as num).toInt(),
      level: (fields[1] as num).toInt(),
      unlockedRewards: (fields[2] as List).cast<Reward>(),
      streakSaverAvailable: fields[3] == null ? false : fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, XPProfile obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.xp)
      ..writeByte(1)
      ..write(obj.level)
      ..writeByte(2)
      ..write(obj.unlockedRewards)
      ..writeByte(3)
      ..write(obj.streakSaverAvailable);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is XPProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RewardAdapter extends TypeAdapter<Reward> {
  @override
  final typeId = 101;

  @override
  Reward read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reward(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      unlockLevel: (fields[3] as num).toInt(),
      type: fields[4] as RewardType,
    );
  }

  @override
  void write(BinaryWriter writer, Reward obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.unlockLevel)
      ..writeByte(4)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RewardTypeAdapter extends TypeAdapter<RewardType> {
  @override
  final typeId = 102;

  @override
  RewardType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RewardType.theme;
      case 1:
        return RewardType.avatar;
      case 2:
        return RewardType.badge;
      case 3:
        return RewardType.feature;
      case 4:
        return RewardType.virtualItem;
      default:
        return RewardType.theme;
    }
  }

  @override
  void write(BinaryWriter writer, RewardType obj) {
    switch (obj) {
      case RewardType.theme:
        writer.writeByte(0);
      case RewardType.avatar:
        writer.writeByte(1);
      case RewardType.badge:
        writer.writeByte(2);
      case RewardType.feature:
        writer.writeByte(3);
      case RewardType.virtualItem:
        writer.writeByte(4);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
