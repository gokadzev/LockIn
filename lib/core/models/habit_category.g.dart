// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitCategoryAdapter extends TypeAdapter<HabitCategory> {
  @override
  final typeId = 20;

  @override
  HabitCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitCategory(name: fields[0] as String);
  }

  @override
  void write(BinaryWriter writer, HabitCategory obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
