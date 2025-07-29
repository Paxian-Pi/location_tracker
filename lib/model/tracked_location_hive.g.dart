// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracked_location_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackedLocationAdapter extends TypeAdapter<TrackedLocation> {
  @override
  final int typeId = 0;

  @override
  TrackedLocation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackedLocation(
      name: fields[0] as String,
      latitude: fields[1] as double,
      longitude: fields[2] as double,
      radius: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, TrackedLocation obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.latitude)
      ..writeByte(2)
      ..write(obj.longitude)
      ..writeByte(3)
      ..write(obj.radius);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackedLocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
