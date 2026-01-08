import 'dart:typed_data';
import 'package:hive/hive.dart';

part 'vault_item.g.dart';

/// Enum for file types in vault
@HiveType(typeId: 4)
enum FileType {
  @HiveField(0)
  image, // صورة
  @HiveField(1)
  video, // فيديو
  @HiveField(2)
  audio, // صوت
  @HiveField(3)
  document, // مستند
  @HiveField(4)
  other, // أخرى
}

@HiveType(typeId: 1)
class VaultItem extends HiveObject {
  /// معرف فريد للعنصر
  @HiveField(0)
  final String id;

  /// المسار الأصلي للملف (قبل التشفير)
  @HiveField(1)
  final String originalPath;

  /// المسار المشفر للملف
  @HiveField(2)
  String encryptedPath;

  /// نوع الملف
  @HiveField(3)
  FileType fileType;

  /// تاريخ الإضافة
  @HiveField(4)
  DateTime addedDate;

  /// صورة مصغرة (thumbnail)
  @HiveField(5)
  Uint8List? thumbnail;

  /// حجم الملف بالبايتات
  @HiveField(6)
  int? fileSizeBytes;

  /// اسم الملف
  @HiveField(7)
  String? fileName;

  VaultItem({
    required this.id,
    required this.originalPath,
    required this.encryptedPath,
    this.fileType = FileType.image,
    DateTime? addedDate,
    this.thumbnail,
    this.fileSizeBytes,
    this.fileName,
  }) : addedDate = addedDate ?? DateTime.now();

  /// Create a copy with modified fields
  VaultItem copyWith({
    String? id,
    String? originalPath,
    String? encryptedPath,
    FileType? fileType,
    DateTime? addedDate,
    Uint8List? thumbnail,
    int? fileSizeBytes,
    String? fileName,
  }) {
    return VaultItem(
      id: id ?? this.id,
      originalPath: originalPath ?? this.originalPath,
      encryptedPath: encryptedPath ?? this.encryptedPath,
      fileType: fileType ?? this.fileType,
      addedDate: addedDate ?? this.addedDate,
      thumbnail: thumbnail ?? this.thumbnail,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      fileName: fileName ?? this.fileName,
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'originalPath': originalPath,
      'encryptedPath': encryptedPath,
      'fileType': fileType.index,
      'addedDate': addedDate.toIso8601String(),
      'thumbnail': thumbnail,
      'fileSizeBytes': fileSizeBytes,
      'fileName': fileName,
    };
  }

  /// Create from Map
  factory VaultItem.fromMap(Map<String, dynamic> map) {
    return VaultItem(
      id: map['id'] as String,
      originalPath: map['originalPath'] as String,
      encryptedPath: map['encryptedPath'] as String,
      fileType: FileType.values[map['fileType'] as int? ?? 0],
      addedDate: map['addedDate'] != null
          ? DateTime.parse(map['addedDate'] as String)
          : DateTime.now(),
      thumbnail: map['thumbnail'] as Uint8List?,
      fileSizeBytes: map['fileSizeBytes'] as int?,
      fileName: map['fileName'] as String?,
    );
  }

  /// Get file size in human-readable format
  String get fileSizeFormatted {
    if (fileSizeBytes == null) return 'Unknown';

    final bytes = fileSizeBytes!;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  String toString() {
    return 'VaultItem(id: $id, originalPath: $originalPath, encryptedPath: $encryptedPath, fileType: $fileType, addedDate: $addedDate, fileName: $fileName, fileSize: $fileSizeFormatted)';
  }
}
