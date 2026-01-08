// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VaultItemAdapter extends TypeAdapter<VaultItem> {
  @override
  final int typeId = 1;

  @override
  VaultItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VaultItem(
      id: fields[0] as String,
      originalPath: fields[1] as String,
      encryptedPath: fields[2] as String,
      fileType: fields[3] as FileType,
      addedDate: fields[4] as DateTime?,
      thumbnail: fields[5] as Uint8List?,
      fileSizeBytes: fields[6] as int?,
      fileName: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, VaultItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.originalPath)
      ..writeByte(2)
      ..write(obj.encryptedPath)
      ..writeByte(3)
      ..write(obj.fileType)
      ..writeByte(4)
      ..write(obj.addedDate)
      ..writeByte(5)
      ..write(obj.thumbnail)
      ..writeByte(6)
      ..write(obj.fileSizeBytes)
      ..writeByte(7)
      ..write(obj.fileName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaultItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FileTypeAdapter extends TypeAdapter<FileType> {
  @override
  final int typeId = 4;

  @override
  FileType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FileType.image;
      case 1:
        return FileType.video;
      case 2:
        return FileType.audio;
      case 3:
        return FileType.document;
      case 4:
        return FileType.other;
      default:
        return FileType.image;
    }
  }

  @override
  void write(BinaryWriter writer, FileType obj) {
    switch (obj) {
      case FileType.image:
        writer.writeByte(0);
        break;
      case FileType.video:
        writer.writeByte(1);
        break;
      case FileType.audio:
        writer.writeByte(2);
        break;
      case FileType.document:
        writer.writeByte(3);
        break;
      case FileType.other:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
