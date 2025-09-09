// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final typeId = 1;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit()
      ..title = fields[0] as String
      ..frequency = fields[1] as String
      ..cue = fields[2] as String?
      ..reward = fields[3] as String?
      ..streak = (fields[4] as num).toInt()
      ..history = (fields[5] as List).cast<DateTime>()
      ..skipped = fields[6] as bool
      ..rescheduled = fields[7] as bool
      ..abandoned = fields[8] as bool
      ..fatigueScore = (fields[9] as num).toInt()
      ..category = fields[10] as String;
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.frequency)
      ..writeByte(2)
      ..write(obj.cue)
      ..writeByte(3)
      ..write(obj.reward)
      ..writeByte(4)
      ..write(obj.streak)
      ..writeByte(5)
      ..write(obj.history)
      ..writeByte(6)
      ..write(obj.skipped)
      ..writeByte(7)
      ..write(obj.rescheduled)
      ..writeByte(8)
      ..write(obj.abandoned)
      ..writeByte(9)
      ..write(obj.fatigueScore)
      ..writeByte(10)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
