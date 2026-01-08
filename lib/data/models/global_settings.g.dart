// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GlobalSettingsAdapter extends TypeAdapter<GlobalSettings> {
  @override
  final int typeId = 2;

  @override
  GlobalSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GlobalSettings(
      masterPin: fields[0] as String,
      appTheme: fields[1] as String,
      reLockTimeout: fields[2] as int,
      fingerprintEnabled: fields[3] as bool,
      intruderSelfie: fields[4] as bool,
      preferredLanguage: fields[5] as String?,
      notificationsEnabled: fields[6] as bool,
      maxAttempts: fields[7] as int,
      hideAppIcon: fields[8] as bool,
      stealthMode: fields[9] as bool,
      hasCompletedOnboarding: fields[10] as bool,
      encryptionSalt: (fields[11] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, GlobalSettings obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.masterPin)
      ..writeByte(1)
      ..write(obj.appTheme)
      ..writeByte(2)
      ..write(obj.reLockTimeout)
      ..writeByte(3)
      ..write(obj.fingerprintEnabled)
      ..writeByte(4)
      ..write(obj.intruderSelfie)
      ..writeByte(5)
      ..write(obj.preferredLanguage)
      ..writeByte(6)
      ..write(obj.notificationsEnabled)
      ..writeByte(7)
      ..write(obj.maxAttempts)
      ..writeByte(8)
      ..write(obj.hideAppIcon)
      ..writeByte(9)
      ..write(obj.stealthMode)
      ..writeByte(10)
      ..write(obj.hasCompletedOnboarding)
      ..writeByte(11)
      ..write(obj.encryptionSalt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlobalSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
