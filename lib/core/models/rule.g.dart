// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RuleAdapter extends TypeAdapter<Rule> {
  @override
  final typeId = 5;

  @override
  Rule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Rule()
      ..trigger = fields[0] as String
      ..action = fields[1] as String
      ..active = fields[2] as bool;
  }

  @override
  void write(BinaryWriter writer, Rule obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.trigger)
      ..writeByte(1)
      ..write(obj.action)
      ..writeByte(2)
      ..write(obj.active);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RuleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
