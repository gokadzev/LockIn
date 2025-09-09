// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionAdapter extends TypeAdapter<Session> {
  @override
  final typeId = 3;

  @override
  Session read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Session()
      ..taskId = (fields[0] as num?)?.toInt()
      ..startTime = fields[1] as DateTime
      ..endTime = fields[2] as DateTime?
      ..duration = (fields[3] as num).toInt()
      ..rating = (fields[4] as num?)?.toInt()
      ..pomodoroCount = (fields[5] as num).toInt()
      ..breakCount = (fields[6] as num).toInt()
      ..consecutiveTaskIds = (fields[7] as List).cast<int>()
      ..flowSessionDuration = (fields[8] as num).toInt()
      ..fatigueScore = (fields[9] as num).toInt();
  }

  @override
  void write(BinaryWriter writer, Session obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.taskId)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.duration)
      ..writeByte(4)
      ..write(obj.rating)
      ..writeByte(5)
      ..write(obj.pomodoroCount)
      ..writeByte(6)
      ..write(obj.breakCount)
      ..writeByte(7)
      ..write(obj.consecutiveTaskIds)
      ..writeByte(8)
      ..write(obj.flowSessionDuration)
      ..writeByte(9)
      ..write(obj.fatigueScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
