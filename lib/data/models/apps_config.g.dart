// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apps_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppsConfigAdapter extends TypeAdapter<AppsConfig> {
  @override
  final int typeId = 0;

  @override
  AppsConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppsConfig(
      packageName: fields[0] as String,
      appName: fields[1] as String,
      isLocked: fields[2] as bool,
      isHidden: fields[3] as bool,
      lockType: fields[4] as LockType,
      customPin: fields[5] as String?,
      blockInternet: fields[6] as NetBlock,
      eyeIconVisible: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppsConfig obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.packageName)
      ..writeByte(1)
      ..write(obj.appName)
      ..writeByte(2)
      ..write(obj.isLocked)
      ..writeByte(3)
      ..write(obj.isHidden)
      ..writeByte(4)
      ..write(obj.lockType)
      ..writeByte(5)
      ..write(obj.customPin)
      ..writeByte(6)
      ..write(obj.blockInternet)
      ..writeByte(7)
      ..write(obj.eyeIconVisible);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppsConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
