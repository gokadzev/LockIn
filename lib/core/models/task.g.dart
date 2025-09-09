// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task()
      ..title = fields[0] as String
      ..description = fields[1] as String?
      ..priority = (fields[2] as num).toInt()
      ..dueDate = fields[3] as DateTime?
      ..tags = (fields[4] as List).cast<String>()
      ..completed = fields[5] as bool
      ..linkedGoalId = (fields[6] as num?)?.toInt()
      ..startTime = fields[7] as DateTime?
      ..completionTime = fields[8] as DateTime?
      ..estimatedDuration = (fields[9] as num?)?.toInt()
      ..actualDuration = (fields[10] as num?)?.toInt()
      ..skipped = fields[11] as bool
      ..rescheduled = fields[12] as bool
      ..abandoned = fields[13] as bool;
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.priority)
      ..writeByte(3)
      ..write(obj.dueDate)
      ..writeByte(4)
      ..write(obj.tags)
      ..writeByte(5)
      ..write(obj.completed)
      ..writeByte(6)
      ..write(obj.linkedGoalId)
      ..writeByte(7)
      ..write(obj.startTime)
      ..writeByte(8)
      ..write(obj.completionTime)
      ..writeByte(9)
      ..write(obj.estimatedDuration)
      ..writeByte(10)
      ..write(obj.actualDuration)
      ..writeByte(11)
      ..write(obj.skipped)
      ..writeByte(12)
      ..write(obj.rescheduled)
      ..writeByte(13)
      ..write(obj.abandoned);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
